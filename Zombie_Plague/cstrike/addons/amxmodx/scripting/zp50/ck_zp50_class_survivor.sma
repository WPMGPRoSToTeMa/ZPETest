/* AMX Mod X
*	[ZP] Class Survivor.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "class survivor"
#define VERSION "5.3.2.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

new const g_Models_Survivor_Player[][] =
{
	"leet",
	"sas"
};

new const g_Sound_Survivor_Die[][] =
{
	"player/die1.wav"
};

new const g_Sound_Survivor_Fall[][] =
{
	"player/pl_fallpain1.wav"
};

new const g_Sound_Survivor_Pain[][] =
{
	"player/pl_pain7.wav"
};

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_cs_maxspeed_api>
#include <fakemeta>
#include <ck_cs_player_models_api>
#include <ck_zp50_kernel>

#define TASK_AURA 100
#define ID_AURA (iTask_ID - TASK_AURA)

#define PLAYERMODEL_MAX_LENGTH 32
#define SOUND_MAX_LENGTH 64

new Array:g_aModels_Survivor_Player

new Array:g_aSound_Survivor_Die;
new Array:g_aSound_Survivor_Fall;
new Array:g_aSound_Survivor_Pain;

new g_Forward;
new g_Forward_Result;

new g_pCvar_Survivor_Health;
new g_pCvar_Survivor_Base_Health;
new g_pCvar_Survivor_Speed;
new g_pCvar_Survivor_Gravity;

new g_pCvar_Survivor_Glow;
new g_pCvar_Survivor_Aura;
new g_pCvar_Survivor_Aura_Radius;
new g_pCvar_Survivor_Aura_Color_R;
new g_pCvar_Survivor_Aura_Color_G;
new g_pCvar_Survivor_Aura_Color_B;
new g_pCvar_Survivor_Aura_Life;
new g_pCvar_Survivor_Aura_Decay_Rate;

new g_pCvar_Survivor_Weapon_Block;
new g_pCvar_Survivor_Weapon_Ammo;

new g_iBit_Survivor;

new g_iBit_Alive;
new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Survivor_Health = register_cvar("zm_survivor_health", "0");
	g_pCvar_Survivor_Base_Health = register_cvar("zm_survivor_base_health", "100");
	g_pCvar_Survivor_Speed = register_cvar("zm_survivor_speed", "0.95");
	g_pCvar_Survivor_Gravity = register_cvar("zm_survivor_gravity", "1.25");

	g_pCvar_Survivor_Glow = register_cvar("zm_survivor_glow", "1");
	g_pCvar_Survivor_Aura = register_cvar("zm_survivor_aura", "1");
	g_pCvar_Survivor_Aura_Radius = register_cvar("zm_survivor_aura_radius", "20");
	g_pCvar_Survivor_Aura_Color_R = register_cvar("zm_survivor_aura_color_R", "0");
	g_pCvar_Survivor_Aura_Color_G = register_cvar("zm_survivor_aura_color_G", "0");
	g_pCvar_Survivor_Aura_Color_B = register_cvar("zm_survivor_aura_color_B", "150");
	g_pCvar_Survivor_Aura_Life = register_cvar("zm_survivor_aura_life", "2");
	g_pCvar_Survivor_Aura_Decay_Rate = register_cvar("zm_survivor_aura_decay_rate", "0");

	g_pCvar_Survivor_Weapon_Block = register_cvar("zm_survivor_weapon_block", "1");
	g_pCvar_Survivor_Weapon_Ammo = register_cvar("zm_survivor_weapon_ammo", "200");

	g_Forward = CreateMultiForward("zp_fw_class_survivor_bit_change", ET_CONTINUE, FP_CELL);

	register_clcmd("drop", "Client_Command_Drop");

	RegisterHookChain(RG_CSGameRules_CanHavePlayerItem, "RG_CSGameRules_CanHavePlayerItem_");

	// TODO: Dont use ReAPI, in the form of code - load.
	register_forward(FM_EmitSound, "FM_EmitSound_");

	register_forward(FM_ClientDisconnect, "FM_ClientDisconnect_Post", 1);
}

public plugin_precache()
{
	// Initialize arrays
	g_aModels_Survivor_Player = ArrayCreate(PLAYERMODEL_MAX_LENGTH, 1);

	g_aSound_Survivor_Die = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Survivor_Fall = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Survivor_Pain = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Player Models", "SURVIVOR", g_aModels_Survivor_Player);

	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "SURVIVOR DIE", g_aSound_Survivor_Die);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "SURVIVOR FALL", g_aSound_Survivor_Fall);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "SURVIVOR PAIN", g_aSound_Survivor_Pain);

	// If we couldn't load from file, use and save default ones
	if (ArraySize(g_aModels_Survivor_Player) == 0)
	{
		for (new i = 0; i < sizeof g_Models_Survivor_Player; i++)
		{
			ArrayPushString(g_aModels_Survivor_Player, g_Models_Survivor_Player[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Player Models", "SURVIVOR", g_aModels_Survivor_Player);
	}

	if (ArraySize(g_aSound_Survivor_Die) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Survivor_Die; i++)
		{
			ArrayPushString(g_aSound_Survivor_Die, g_Sound_Survivor_Die[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "SURVIVOR DIE", g_aSound_Survivor_Die);
	}

	if (ArraySize(g_aSound_Survivor_Fall) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Survivor_Fall; i++)
		{
			ArrayPushString(g_aSound_Survivor_Fall, g_Sound_Survivor_Fall[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "SURVIVOR FALL", g_aSound_Survivor_Fall);
	}

	if (ArraySize(g_aSound_Survivor_Pain) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Survivor_Pain; i++)
		{
			ArrayPushString(g_aSound_Survivor_Pain, g_Sound_Survivor_Pain[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "SURVIVOR PAIN", g_aSound_Survivor_Pain)
	}

	new szBuffer[128];

	for (new i = 0; i < sizeof g_Models_Survivor_Player; i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", g_Models_Survivor_Player[i], g_Models_Survivor_Player[i]);

		precache_model(szBuffer);
	}

	for (new i = 0; i < sizeof g_Sound_Survivor_Die; i++)
	{
		precache_sound(g_Sound_Survivor_Die[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Survivor_Fall; i++)
	{
		precache_sound(g_Sound_Survivor_Fall[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Survivor_Pain; i++)
	{
		precache_sound(g_Sound_Survivor_Pain[i]);
	}
}

public plugin_natives()
{
	register_library("ck_zp50_class_survivor");

	register_native("zp_class_survivor_set", "native_class_survivor_set");
	register_native("zp_class_survivor_get_count", "native_class_survivor_get_count");
}

public Client_Command_Drop(iPlayer)
{
	// Should survivor stick to his weapon?
	if (BIT_VALID(g_iBit_Survivor, iPlayer) && get_pcvar_num(g_pCvar_Survivor_Weapon_Block))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public RG_CSGameRules_CanHavePlayerItem_(iWeapon, iPlayer)
{
	// Should survivor stick to his weapon?
	if (get_pcvar_num(g_pCvar_Survivor_Weapon_Block) && BIT_VALID(g_iBit_Alive, iPlayer) && BIT_VALID(g_iBit_Survivor, iPlayer))
	{
		return HC_SUPERCEDE;
	}

	return HC_CONTINUE;
}

public zp_fw_core_spawn_post(iPlayer)
{
	if (BIT_VALID(g_iBit_Survivor, iPlayer))
	{
		// Remove survivor glow
		if (get_pcvar_num(g_pCvar_Survivor_Glow))
		{
			rh_set_user_rendering(iPlayer);
		}

		// Remove survivor aura
		if (get_pcvar_num(g_pCvar_Survivor_Aura))
		{
			remove_task(iPlayer + TASK_AURA);
		}

		// Remove survivor flag
		BIT_SUB(g_iBit_Survivor, iPlayer);

		ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Survivor);
	}
}

public zp_fw_core_infect(iPlayer)
{
	if (BIT_VALID(g_iBit_Survivor, iPlayer))
	{
		// Remove survivor glow
		if (get_pcvar_num(g_pCvar_Survivor_Glow))
		{
			rh_set_user_rendering(iPlayer);
		}

		// Remove survivor aura
		if (get_pcvar_num(g_pCvar_Survivor_Aura))
		{
			remove_task(iPlayer + TASK_AURA);
		}

		// Remove survivor flag
		BIT_SUB(g_iBit_Survivor, iPlayer);

		ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Survivor);
	}
}

public zp_fw_core_cure_post(iPlayer)
{
	// Apply survivor attributes?
	if (BIT_NOT_VALID(g_iBit_Survivor, iPlayer))
	{
		return;
	}

	// Health
	if (get_pcvar_num(g_pCvar_Survivor_Health) == 0)
	{
		SET_USER_HEALTH(iPlayer, float(get_pcvar_num(g_pCvar_Survivor_Base_Health)) * Get_Alive_Count());
	}

	else
	{
		SET_USER_HEALTH(iPlayer, float(get_pcvar_num(g_pCvar_Survivor_Health)));
	}

	// Gravity
	SET_USER_GRAVITY(iPlayer, get_pcvar_float(g_pCvar_Survivor_Gravity));

	// Speed (if value between 0 and 10, consider it a multiplier)
	cs_set_player_maxspeed_auto(iPlayer, get_pcvar_float(g_pCvar_Survivor_Speed));

	// Apply survivor player model
	cs_set_player_model(iPlayer, g_Models_Survivor_Player[random_num(0, sizeof g_Models_Survivor_Player - 1)]);

	// Survivor glow
	if (get_pcvar_num(g_pCvar_Survivor_Glow))
	{
		rh_set_user_rendering(iPlayer, kRenderFxGlowShell, get_pcvar_num(g_pCvar_Survivor_Aura_Color_R), get_pcvar_num(g_pCvar_Survivor_Aura_Color_G), get_pcvar_num(g_pCvar_Survivor_Aura_Color_B), kRenderNormal, 25);
	}

	// Survivor aura task
	if (get_pcvar_num(g_pCvar_Survivor_Aura))
	{
		set_task(0.1, "Survivor_Aura", iPlayer + TASK_AURA, _, _, "b");
	}

	rg_give_item(iPlayer, "weapon_m249", GT_DROP_AND_REPLACE);
	rg_set_user_bpammo(iPlayer, WEAPON_M249, get_pcvar_num(g_pCvar_Survivor_Weapon_Ammo));
}

public native_class_survivor_set(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	if (BIT_VALID(g_iBit_Survivor, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Player already a survivor (%d)", iPlayer);

		return false;
	}

	BIT_ADD(g_iBit_Survivor, iPlayer);

	ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Survivor);

	zp_core_force_cure(iPlayer);

	return true;
}

public native_class_survivor_get_count(iPlugin_ID, iNum_Params)
{
	return Get_Survivor_Count();
}

// Survivor aura task
public Survivor_Aura(iTask_ID)
{
	// Get player's origin
	static iOrigin[3];

	get_user_origin(ID_AURA, iOrigin);

	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
	write_byte(TE_DLIGHT); // TE player
	write_coord(iOrigin[0]); // x
	write_coord(iOrigin[1]); // y
	write_coord(iOrigin[2]); // z
	write_byte(get_pcvar_num(g_pCvar_Survivor_Aura_Radius)); // radius
	write_byte(get_pcvar_num(g_pCvar_Survivor_Aura_Color_R)); // r
	write_byte(get_pcvar_num(g_pCvar_Survivor_Aura_Color_G)); // g
	write_byte(get_pcvar_num(g_pCvar_Survivor_Aura_Color_B)); // b
	write_byte(get_pcvar_num(g_pCvar_Survivor_Aura_Life)); // life
	write_byte(get_pcvar_num(g_pCvar_Survivor_Aura_Decay_Rate)); // decay rate
	message_end();
}

public FM_EmitSound_(iPlayer, iChannel, const szSample[], Float:fVolume, Float:fAttn, iFlags, iPitch)
{
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer) || !zp_core_is_zombie(iPlayer))
	{
		return FMRES_IGNORED;
	}

	if (BIT_VALID(g_iBit_Survivor, iPlayer))
	{
		if (szSample[7] == 'd' && ((szSample[8] == 'i' && szSample[9] == 'e') || (szSample[8] == 'e' && szSample[9] == 'a')))
		{
			emit_sound(iPlayer, iChannel, g_Sound_Survivor_Die[random(sizeof g_Sound_Survivor_Die)], fVolume, fAttn, iFlags, iPitch);

			return FMRES_SUPERCEDE;
		}

		if (szSample[10] == 'f' && szSample[11] == 'a' && szSample[12] == 'l' && szSample[13] == 'l')
		{
			emit_sound(iPlayer, iChannel, g_Sound_Survivor_Fall[random(sizeof g_Sound_Survivor_Fall)], fVolume, fAttn, iFlags, iPitch);

			return FMRES_SUPERCEDE;
		}

		if (szSample[7] == 'b' && szSample[8] == 'h' && szSample[9] == 'i' && szSample[10] == 't')
		{
			emit_sound(iPlayer, iChannel, g_Sound_Survivor_Pain[random(sizeof g_Sound_Survivor_Pain)], fVolume, fAttn, iFlags, iPitch);

			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	if (BIT_VALID(g_iBit_Survivor, iPlayer))
	{
		// Remove survivor aura
		if (get_pcvar_num(g_pCvar_Survivor_Glow))
		{
			remove_task(iPlayer + TASK_AURA);
		}
	}

	BIT_SUB(g_iBit_Alive, iPlayer);
	BIT_SUB(g_iBit_Connected, iPlayer);
}

public FM_ClientDisconnect_Post(iPlayer)
{
	// Reset flags AFTER disconnect (to allow checking if the player was survivor before disconnecting)
	BIT_SUB(g_iBit_Survivor, iPlayer);

	ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Survivor);
}

public zp_fw_kill_pre_bit_sub(iVictim)
{
	if (BIT_VALID(g_iBit_Survivor, iVictim))
	{
		// Remove survivor aura
		if (get_pcvar_num(g_pCvar_Survivor_Aura))
		{
			remove_task(iVictim + TASK_AURA);
		}
	}

	BIT_SUB(g_iBit_Alive, iVictim);
}

public zp_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}

// Get Alive Count -returns alive players number-
Get_Alive_Count()
{
	new iAlive;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (BIT_VALID(g_iBit_Alive, i))
		{
			iAlive++;
		}
	}

	return iAlive;
}

// Get Survivor Count -returns alive survivors number-
Get_Survivor_Count()
{
	new iSurvivors;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (BIT_VALID(g_iBit_Alive, i) && BIT_VALID(g_iBit_Survivor, i))
		{
			iSurvivors++;
		}
	}

	return iSurvivors;
}