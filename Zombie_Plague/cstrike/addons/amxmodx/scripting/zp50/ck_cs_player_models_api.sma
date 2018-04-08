/* AMX Mod X
*	CS Player Models API.
*	Author: WiLS. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "cs player models api"
#define VERSION "6.2.3.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>

#define MODEL_NAME_MAX_LENGTH 32

new g_Custom_Player_Model[MAX_PLAYERS + 1][MODEL_NAME_MAX_LENGTH];
new g_Custom_Model_Index[MAX_PLAYERS + 1];

new g_Set_Model_Index_Offset = 0;

new g_Has_Custom_Model;

new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward(FM_SetClientKeyValue, "FM_SetClientKeyValue_");

	if (!amx_load_setting_int(ZP_SETTINGS_FILE, "SVC_BAD Prevention", "SET MODELINDEX OFFSET", g_Set_Model_Index_Offset))
	{
		amx_save_setting_int(ZP_SETTINGS_FILE, "SVC_BAD Prevention", "SET MODELINDEX OFFSET", g_Set_Model_Index_Offset);
	}
}

public plugin_natives()
{
	register_library("ck_cs_player_models_api");

	register_native("cs_set_player_model", "native_set_player_model");
	register_native("cs_reset_player_model", "native_reset_player_model");
}

public native_set_player_model(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[CS] Player is not in game (%d)", iPlayer);

		return false;
	}

	new szNew_Model[MODEL_NAME_MAX_LENGTH];

	get_string(2, szNew_Model, charsmax(szNew_Model));

	BIT_ADD(g_Has_Custom_Model, iPlayer);

	copy(g_Custom_Player_Model[iPlayer], charsmax(g_Custom_Player_Model[]), szNew_Model);

	if (g_Set_Model_Index_Offset)
	{
		new szModel_Path[128];

		formatex(szModel_Path, charsmax(szModel_Path), "models/player/%s/%s.mdl", szNew_Model, szNew_Model);

		g_Custom_Model_Index[iPlayer] = engfunc(EngFunc_ModelIndex, szModel_Path);
	}

	new szCurrent_Model[MODEL_NAME_MAX_LENGTH];

	fm_cs_get_user_model(iPlayer, szCurrent_Model, charsmax(szCurrent_Model));

	fm_cs_set_user_model(iPlayer);

	return true;
}

public native_reset_player_model(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[CS] Player is not in game (%d)", iPlayer);

		return false;
	}

	// Player doesn't have a custom model, no need to reset
	if (BIT_NOT_VALID(g_Has_Custom_Model, iPlayer))
	{
		return true;
	}

	BIT_SUB(g_Has_Custom_Model, iPlayer);

	fm_cs_reset_user_model(iPlayer);

	return true;
}

public FM_SetClientKeyValue_(iPlayer, const szInfo_Buffer[], const szKey[])
{
	if (BIT_VALID(g_Has_Custom_Model, iPlayer) && equal(szKey, "model"))
	{
		static szCurrent_Model[32];

		fm_cs_get_user_model(iPlayer, szCurrent_Model, charsmax(szCurrent_Model));

		if (!equal(szCurrent_Model, g_Custom_Player_Model[iPlayer]))
		{
			fm_cs_set_user_model(iPlayer);
		}

		if (g_Set_Model_Index_Offset)
		{
			fm_cs_set_user_model_index(iPlayer)
		}

		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public fm_cs_set_user_model(iPlayer)
{
	set_user_info(iPlayer, "model", g_Custom_Player_Model[iPlayer]);
}

stock fm_cs_get_user_model(iPlayer, szModel[], sLen)
{
	get_user_info(iPlayer, "model", szModel, sLen);
}

stock fm_cs_set_user_model_index(iPlayer)
{
	set_member(iPlayer, m_modelIndexPlayer, g_Custom_Model_Index[iPlayer]); // set_pdata_int
}

stock fm_cs_reset_user_model(iPlayer)
{
	// Set some generic model and let CS automatically reset player model to default
	copy(g_Custom_Player_Model[iPlayer], charsmax(g_Custom_Player_Model[]), "gordon");

	if (g_Set_Model_Index_Offset)
	{
		switch (CS_GET_USER_TEAM(iPlayer))
		{
			case CS_TEAM_T:
			{
				set_member(iPlayer, m_modelIndexPlayer, engfunc(EngFunc_ModelIndex, "models/player/terror/terror.mdl"));
			}

			case CS_TEAM_CT:
			{
				set_member(iPlayer, m_modelIndexPlayer, engfunc(EngFunc_ModelIndex, "models/player/urban/urban.mdl"));
			}
		}
	}
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	BIT_SUB(g_Has_Custom_Model, iPlayer);

	BIT_SUB(g_iBit_Connected, iPlayer);
}