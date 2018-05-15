/* AMX Mod X
*	[ZP] Admin Models.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "admin models"
#define VERSION "5.2.6.1"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_cs_weap_models_api>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_assassin>
#include <ck_zp50_class_survivor>
#include <ck_zp50_class_sniper>

#define PLAYER_MODELS_MAX_LENGTH 32
#define MODELS_MAX_LENGTH 64
#define ACCESS_FLAG_MAX_LENGTH 2

new const g_Models_Admin_Human_Player[][] =
{
	"vip"
};

new const g_Models_Admin_Human_Knife[][] =
{
	"models/v_knife.mdl"
};

new const g_Models_Admin_Zombie_Player[][] =
{
	"zombie_source"
};

new const g_Models_Admin_Zombie_Claw[][] =
{
	"models/zombie_plague/v_knife_zombie.mdl"
};

// Access flags
new g_Access_Admin_Models_Human_Player[ACCESS_FLAG_MAX_LENGTH] = "d";
new g_Access_Admin_Models_Human_Knife[ACCESS_FLAG_MAX_LENGTH] = "d";
new g_Access_Admin_Models_Zombie_Player[ACCESS_FLAG_MAX_LENGTH] = "d";
new g_Access_Admin_Models_Zombie_Knife[ACCESS_FLAG_MAX_LENGTH] = "d";

// Custom models
new Array:g_aModels_Admin_Human_Player;
new Array:g_aModels_Admin_Human_Knife;
new Array:g_aModels_Admin_Zombie_Player;
new Array:g_aModels_Admin_Zombie_Claw;

new g_pCvar_Admin_Models_Human_Player;
new g_pCvar_Admin_Models_Human_Knife;
new g_pCvar_Admin_Models_Zombie_Player;
new g_pCvar_Admin_Models_Zombie_Knife;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Admin_Models_Human_Player = register_cvar("zm_admin_models_human_player", "1");
	g_pCvar_Admin_Models_Human_Knife = register_cvar("zm_admin_models_human_knife", "1");
	g_pCvar_Admin_Models_Zombie_Player = register_cvar("zm_admin_models_zombie_player", "1");
	g_pCvar_Admin_Models_Zombie_Knife = register_cvar("zm_admin_models_zombie_knife", "1");
}

public plugin_precache()
{
	// Initialize arrays
	g_aModels_Admin_Human_Player = ArrayCreate(PLAYER_MODELS_MAX_LENGTH, 1);
	g_aModels_Admin_Human_Knife = ArrayCreate(MODELS_MAX_LENGTH, 1);
	g_aModels_Admin_Zombie_Player = ArrayCreate(PLAYER_MODELS_MAX_LENGTH, 1);
	g_aModels_Admin_Zombie_Claw = ArrayCreate(MODELS_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Player Models", "ADMIN HUMAN", g_aModels_Admin_Human_Player);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Weapon Models", "V_KNIFE ADMIN HUMAN", g_aModels_Admin_Human_Knife);

	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Player Models", "ADMIN ZOMBIE", g_aModels_Admin_Zombie_Player);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Weapon Models", "V_KNIFE ADMIN ZOMBIE", g_aModels_Admin_Zombie_Claw);

	// If we couldn't load from file, use and save default ones
	if (ArraySize(g_aModels_Admin_Human_Player) == 0)
	{
		for (new i = 0; i < sizeof g_Models_Admin_Human_Player; i++)
		{
			ArrayPushString(g_aModels_Admin_Human_Player, g_Models_Admin_Human_Player[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Player Models", "ADMIN HUMAN", g_aModels_Admin_Human_Player);
	}

	if (ArraySize(g_aModels_Admin_Human_Knife) == 0)
	{
		for (new i = 0; i < sizeof g_Models_Admin_Human_Knife; i++)
		{
			ArrayPushString(g_aModels_Admin_Human_Knife, g_Models_Admin_Human_Knife[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Weapon Models", "V_KNIFE ADMIN HUMAN", g_aModels_Admin_Human_Knife);
	}

	if (ArraySize(g_aModels_Admin_Zombie_Player) == 0)
	{
		for (new i = 0; i < sizeof g_Models_Admin_Zombie_Player; i++)
		{
			ArrayPushString(g_aModels_Admin_Zombie_Player, g_Models_Admin_Zombie_Player[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Player Models", "ADMIN ZOMBIE", g_aModels_Admin_Zombie_Player);
	}

	if (ArraySize(g_aModels_Admin_Zombie_Claw) == 0)
	{
		for (new i = 0; i < sizeof g_Models_Admin_Zombie_Claw; i++)
		{
			ArrayPushString(g_aModels_Admin_Zombie_Claw, g_Models_Admin_Zombie_Claw[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Weapon Models", "V_KNIFE ADMIN ZOMBIE", g_aModels_Admin_Zombie_Claw);
	}

	// Load from external file, save if not found
	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Access Flags", "ADMIN MODELS HUMAN PLAYER", g_Access_Admin_Models_Human_Player, charsmax(g_Access_Admin_Models_Human_Player)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Access Flags", "ADMIN MODELS HUMAN PLAYER", g_Access_Admin_Models_Human_Player);
	}

	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Access Flags", "ADMIN MODELS HUMAN KNIFE", g_Access_Admin_Models_Human_Knife, charsmax(g_Access_Admin_Models_Human_Knife)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Access Flags", "ADMIN MODELS HUMAN KNIFE", g_Access_Admin_Models_Human_Knife);
	}

	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Access Flags", "ADMIN MODELS ZOMBIE PLAYER", g_Access_Admin_Models_Zombie_Player, charsmax(g_Access_Admin_Models_Zombie_Player)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Access Flags", "ADMIN MODELS ZOMBIE PLAYER", g_Access_Admin_Models_Zombie_Player);
	}

	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Access Flags", "ADMIN MODELS ZOMBIE KNIFE", g_Access_Admin_Models_Zombie_Knife, charsmax(g_Access_Admin_Models_Zombie_Knife)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Access Flags", "ADMIN MODELS ZOMBIE KNIFE", g_Access_Admin_Models_Zombie_Knife);
	}

	new szPlayer_Model[PLAYER_MODELS_MAX_LENGTH];
	new szModel[MODELS_MAX_LENGTH];

	new	szModel_Path[128];

	for (new i = 0; i < ArraySize(g_aModels_Admin_Human_Player); i++)
	{
		ArrayGetString(g_aModels_Admin_Human_Player, i, szPlayer_Model, charsmax(szPlayer_Model));

		formatex(szModel_Path, charsmax(szModel_Path), "models/player/%s/%s.mdl", szPlayer_Model, szPlayer_Model);

		precache_model(szModel_Path);
	}

	for (new i = 0; i < ArraySize(g_aModels_Admin_Human_Knife); i++)
	{
		ArrayGetString(g_aModels_Admin_Human_Knife, i, szModel, charsmax(szModel));

		precache_model(szModel);
	}

	for (new i = 0; i < ArraySize(g_aModels_Admin_Zombie_Player); i++)
	{
		ArrayGetString(g_aModels_Admin_Zombie_Player, i, szPlayer_Model, charsmax(szPlayer_Model));

		formatex(szModel_Path, charsmax(szModel_Path), "models/player/%s/%s.mdl", szPlayer_Model, szPlayer_Model);

		precache_model(szModel_Path);
	}

	for (new i = 0; i < ArraySize(g_aModels_Admin_Zombie_Claw); i++)
	{
		ArrayGetString(g_aModels_Admin_Zombie_Claw, i, szModel, charsmax(szModel));

		precache_model(szModel);
	}
}

public zp_fw_core_infect_post(iPlayer, iAttacker)
{
	// Skip for Nemesis
	if (zp_class_nemesis_get(iPlayer))
	{
		return;
	}

	// Skip for Assassin
	else if (zp_class_assassin_get(iPlayer))
	{
		return;
	}

	new iUser_Flags = get_user_flags(iPlayer);

	// Apply admin zombie player model?
	if (get_pcvar_num(g_pCvar_Admin_Models_Zombie_Player))
	{
		if (iUser_Flags & read_flags(g_Access_Admin_Models_Zombie_Player))
		{
			new szPlayer_Model[PLAYER_MODELS_MAX_LENGTH];

			ArrayGetString(g_aModels_Admin_Zombie_Player, random_num(0, ArraySize(g_aModels_Admin_Zombie_Player) - 1), szPlayer_Model, charsmax(szPlayer_Model));

			rg_set_user_model(iPlayer, szPlayer_Model);
		}
	}

	// Apply admin zombie claw model?
	if (get_pcvar_num(g_pCvar_Admin_Models_Zombie_Knife))
	{
		if (iUser_Flags & read_flags(g_Access_Admin_Models_Zombie_Knife))
		{
			new szModel[MODELS_MAX_LENGTH];

			ArrayGetString(g_aModels_Admin_Zombie_Claw, random_num(0, ArraySize(g_aModels_Admin_Zombie_Claw) - 1), szModel, charsmax(szModel));

			cs_set_player_view_model(iPlayer, CSW_KNIFE, szModel);
		}
	}
}

public zp_fw_core_cure_post(iPlayer, iAttacker)
{
	// Skip for Survivor
	if (zp_class_survivor_get(iPlayer))
	{
		return;
	}

	// Skip for Sniper
	else if (zp_class_sniper_get(iPlayer))
	{
		return;
	}

	new iUser_Flags = get_user_flags(iPlayer);

	// Apply admin human player model?
	if (get_pcvar_num(g_pCvar_Admin_Models_Human_Player))
	{
		if (iUser_Flags & read_flags(g_Access_Admin_Models_Human_Player))
		{
			new szPlayer_Model[PLAYER_MODELS_MAX_LENGTH];

			ArrayGetString(g_aModels_Admin_Human_Player, random_num(0, ArraySize(g_aModels_Admin_Human_Player) - 1), szPlayer_Model, charsmax(szPlayer_Model));

			rg_set_user_model(iPlayer, szPlayer_Model);
		}
	}

	// Apply admin human knife model?
	if (get_pcvar_num(g_pCvar_Admin_Models_Human_Knife))
	{
		if (iUser_Flags & read_flags(g_Access_Admin_Models_Human_Knife))
		{
			new szModel[MODELS_MAX_LENGTH];

			ArrayGetString(g_aModels_Admin_Human_Knife, random_num(0, ArraySize(g_aModels_Admin_Human_Knife) - 1), szModel, charsmax(szModel));

			cs_set_player_view_model(iPlayer, CSW_KNIFE, szModel);
		}
	}
}