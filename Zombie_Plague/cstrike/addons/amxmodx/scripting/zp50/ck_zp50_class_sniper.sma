/* AMX Mod X
*	[ZPE] Class Sniper.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	https://git.ckcorp.ru/CK/AMXX-MODES - development.
*
*	Support is provided only on the site.
*/

#define PLUGIN "class sniper"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_cs_maxspeed_api>
#include <ck_zp50_kernel>
#include <ck_zp50_items>

#define ZPE_SETTINGS_FILE "ZPE/classes/other/zpe_sniper.ini"

#define TASK_AURA 100
#define ID_AURA (iTask_ID - TASK_AURA)

#define PLAYERMODEL_MAX_LENGTH 32
#define SOUND_MAX_LENGTH 64

new const g_Models_Sniper_Player[][] =
{
	"leet",
	"sas"
};

new const g_Sound_Sniper_Die[][] =
{
	"player/die1.wav"
};

new const g_Sound_Sniper_Fall[][] =
{
	"player/pl_fallpain1.wav"
};

new const g_Sound_Sniper_Pain[][] =
{
	"player/pl_pain7.wav"
};

new Array:g_aModels_Sniper_Player;

new Array:g_aSound_Sniper_Die;
new Array:g_aSound_Sniper_Fall;
new Array:g_aSound_Sniper_Pain;

new g_Forward;
new g_Forward_Result;

new g_pCvar_Sniper_Health;
new g_pCvar_Sniper_Base_Health;
new g_pCvar_Sniper_Speed;
new g_pCvar_Sniper_Gravity;

new g_pCvar_Sniper_Glow;
new g_pCvar_Sniper_Aura;
new g_pCvar_Sniper_Aura_Radius;
new g_pCvar_Sniper_Aura_Color_R;
new g_pCvar_Sniper_Aura_Color_G;
new g_pCvar_Sniper_Aura_Color_B;
new g_pCvar_Sniper_Aura_Life;
new g_pCvar_Sniper_Aura_Decay_Rate;

new g_pCvar_Sniper_Damage;
new g_pCvar_Sniper_Kill_Explode;

new g_pCvar_Sniper_Weapon_Block;
new g_pCvar_Sniper_Weapon_Ammo;

new g_iBit_Sniper;

new g_iBit_Alive;
new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Sniper_Health = register_cvar("zpe_sniper_health", "0");
	g_pCvar_Sniper_Base_Health = register_cvar("zpe_sniper_base_health", "100");
	g_pCvar_Sniper_Speed = register_cvar("zpe_sniper_speed", "0.95");
	g_pCvar_Sniper_Gravity = register_cvar("zpe_sniper_gravity", "0.75");

	g_pCvar_Sniper_Glow = register_cvar("zpe_sniper_glow", "1");
	g_pCvar_Sniper_Aura = register_cvar("zpe_sniper_aura", "1");
	g_pCvar_Sniper_Aura_Radius = register_cvar("zpe_sniper_aura_radius", "20");
	g_pCvar_Sniper_Aura_Color_R = register_cvar("zpe_sniper_aura_color_R", "200");
	g_pCvar_Sniper_Aura_Color_G = register_cvar("zpe_sniper_aura_color_G", "200");
	g_pCvar_Sniper_Aura_Color_B = register_cvar("zpe_sniper_aura_color_B", "0");
	g_pCvar_Sniper_Aura_Life = register_cvar("zpe_sniper_aura_life", "2");
	g_pCvar_Sniper_Aura_Decay_Rate = register_cvar("zpe_sniper_aura_decay_rate", "0");

	g_pCvar_Sniper_Damage = register_cvar("zpe_sniper_damage", "55555");
	g_pCvar_Sniper_Kill_Explode = register_cvar("zpe_sniper_kill_explode", "0");

	g_pCvar_Sniper_Weapon_Block = register_cvar("zpe_sniper_weapon_block", "1");
	g_pCvar_Sniper_Weapon_Ammo = register_cvar("zpe_sniper_weapon_ammo", "30");

	g_Forward = CreateMultiForward("zp_fw_class_sniper_bit_change", ET_CONTINUE, FP_CELL);

	register_clcmd("drop", "Client_Command_Drop");

	RegisterHookChain(RG_CSGameRules_CanHavePlayerItem, "RG_CSGameRules_CanHavePlayerItem_");
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_");

	// Dont use ReAPI, in the form of code - load
	register_forward(FM_EmitSound, "FM_EmitSound_");

	register_forward(FM_ClientDisconnect, "FM_ClientDisconnect_Post", 1);
}

public plugin_precache()
{
	// Initialize arrays
	g_aModels_Sniper_Player = ArrayCreate(PLAYERMODEL_MAX_LENGTH, 1);

	g_aSound_Sniper_Die = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Sniper_Fall = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Sniper_Pain = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Player Models", "SNIPER", g_aModels_Sniper_Player);

	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "SNIPER DIE", g_aSound_Sniper_Die);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "SNIPER FALL", g_aSound_Sniper_Fall);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "SNIPER PAIN", g_aSound_Sniper_Pain);

	new szBuffer[128];

	for (new i = 0; i < sizeof g_Models_Sniper_Player; i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", g_Models_Sniper_Player[i], g_Models_Sniper_Player[i]);

		precache_model(szBuffer);
	}

	for (new i = 0; i < sizeof g_Sound_Sniper_Die; i++)
	{
		precache_sound(g_Sound_Sniper_Die[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Sniper_Fall; i++)
	{
		precache_sound(g_Sound_Sniper_Fall[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Sniper_Pain; i++)
	{
		precache_sound(g_Sound_Sniper_Pain[i]);
	}
}

public plugin_cfg()
{
	server_cmd("exec addons/amxmodx/configs/ZPE/classes/other/zpe_sniper.cfg");
}

public plugin_natives()
{
	register_library("ck_zp50_class_sniper");

	register_native("zp_class_sniper_set", "native_class_sniper_set");
	register_native("zp_class_sniper_get_count", "native_class_sniper_get_count");
}

public Client_Command_Drop(iPlayer)
{
	// Should sniper stick to his weapon?
	if (get_pcvar_num(g_pCvar_Sniper_Weapon_Block) && BIT_VALID(g_iBit_Sniper, iPlayer))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public RG_CSGameRules_CanHavePlayerItem_(iWeapon, iPlayer)
{
	// Should sniper stick to his weapon?
	if (get_pcvar_num(g_pCvar_Sniper_Weapon_Block) && BIT_VALID(g_iBit_Sniper, iPlayer) && BIT_VALID(g_iBit_Alive, iPlayer))
	{
		return HC_SUPERCEDE;
	}

	return HC_CONTINUE;
}

public zp_fw_core_spawn_post(iPlayer)
{
	if (BIT_VALID(g_iBit_Sniper, iPlayer))
	{
		// Remove sniper glow
		if (get_pcvar_num(g_pCvar_Sniper_Glow))
		{
			rg_set_user_rendering(iPlayer);
		}

		// Remove sniper aura
		if (get_pcvar_num(g_pCvar_Sniper_Aura))
		{
			remove_task(iPlayer + TASK_AURA);
		}

		// Remove sniper flag
		BIT_SUB(g_iBit_Sniper, iPlayer);

		ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Sniper);
	}
}

public zp_fw_core_infect(iPlayer)
{
	if (BIT_VALID(g_iBit_Sniper, iPlayer))
	{
		// Remove sniper glow
		if (get_pcvar_num(g_pCvar_Sniper_Glow))
		{
			rg_set_user_rendering(iPlayer);
		}

		// Remove sniper aura
		if (get_pcvar_num(g_pCvar_Sniper_Aura))
		{
			remove_task(iPlayer + TASK_AURA);
		}

		// Remove sniper flag
		BIT_SUB(g_iBit_Sniper, iPlayer);

		ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Sniper);
	}
}

public RG_CBasePlayer_TakeDamage_(iVictim, iInflictor, iAttacker, Float:fDamage)
{
	// Non-player damage or self damage
	if (!(1 <= iAttacker <= MaxClients) || iVictim == iAttacker || BIT_NOT_VALID(g_iBit_Alive, iAttacker))
	{
		return HC_CONTINUE;
	}

	// Sniper attacking zombie
	if (BIT_VALID(g_iBit_Sniper, iAttacker) && zp_core_is_zombie(iVictim))
	{
		// Ignore assassin damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (iInflictor == iAttacker)
		{
			if (CS_GET_WEAPON_ID(iAttacker) == CSW_AWP)
			{
				SetHookChainArg(4, ATYPE_FLOAT, fDamage * get_pcvar_float(g_pCvar_Sniper_Damage));
			}
		}
	}

	return HC_CONTINUE;
}

public zp_fw_core_cure_post(iPlayer, iAttacker)
{
	// Apply sniper attributes?
	if (BIT_NOT_VALID(g_iBit_Sniper, iPlayer))
	{
		return;
	}

	// Health
	if (get_pcvar_num(g_pCvar_Sniper_Health) == 0)
	{
		SET_USER_HEALTH(iPlayer, get_pcvar_float(g_pCvar_Sniper_Base_Health) * Get_Alive_Count());
	}

	else
	{
		SET_USER_HEALTH(iPlayer, get_pcvar_float(g_pCvar_Sniper_Health));
	}

	// Gravity
	SET_USER_GRAVITY(iPlayer, get_pcvar_float(g_pCvar_Sniper_Gravity));

	// Speed (if value between 0 and 10, consider it a multiplier)
	cs_set_player_maxspeed_auto(iPlayer, get_pcvar_float(g_pCvar_Sniper_Speed));

	// Apply sniper player model
	rg_set_user_model(iPlayer, g_Models_Sniper_Player[random(sizeof g_Models_Sniper_Player)]);

	// Sniper glow
	if (get_pcvar_num(g_pCvar_Sniper_Glow))
	{
		rg_set_user_rendering(iPlayer, kRenderFxGlowShell, get_pcvar_num(g_pCvar_Sniper_Aura_Color_R), get_pcvar_num(g_pCvar_Sniper_Aura_Color_G), get_pcvar_num(g_pCvar_Sniper_Aura_Color_B), kRenderNormal, 25);
	}

	// Sniper aura task
	if (get_pcvar_num(g_pCvar_Sniper_Aura))
	{
		set_task(0.1, "Sniper_Aura", iPlayer + TASK_AURA, _, _, "b");
	}

	rg_give_item(iPlayer, "weapon_awp", GT_DROP_AND_REPLACE);
	rg_set_user_bpammo(iPlayer, WEAPON_AWP, get_pcvar_num(g_pCvar_Sniper_Weapon_Ammo));
}

public native_class_sniper_set(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	if (BIT_VALID(g_iBit_Sniper, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Player already a sniper (%d)", iPlayer);

		return false;
	}

	BIT_ADD(g_iBit_Sniper, iPlayer);

	ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Sniper);

	zp_core_force_cure(iPlayer);

	return true;
}

public native_class_sniper_get_count(iPlugin_ID, iNum_Params)
{
	return Get_Sniper_Count();
}

// Sniper aura task
public Sniper_Aura(iTask_ID)
{
	// Get player's origin
	static iOrigin[3];

	get_user_origin(ID_AURA, iOrigin);

	// Colored aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
	write_byte(TE_DLIGHT); // TE player
	write_coord(iOrigin[0]); // x
	write_coord(iOrigin[1]); // y
	write_coord(iOrigin[2]); // z
	write_byte(get_pcvar_num(g_pCvar_Sniper_Aura_Radius)); // radius
	write_byte(get_pcvar_num(g_pCvar_Sniper_Aura_Color_R)); // r
	write_byte(get_pcvar_num(g_pCvar_Sniper_Aura_Color_G)); // g
	write_byte(get_pcvar_num(g_pCvar_Sniper_Aura_Color_B)); // b
	write_byte(get_pcvar_num(g_pCvar_Sniper_Aura_Life)); // life
	write_byte(get_pcvar_num(g_pCvar_Sniper_Aura_Decay_Rate)); // decay rate
	message_end();
}

public FM_EmitSound_(iPlayer, iChannel, szSample[], Float:fVolume, Float:fAttn, iFlags, iPitch)
{
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer) || !zp_core_is_zombie(iPlayer))
	{
		return FMRES_IGNORED;
	}

	if (BIT_VALID(g_iBit_Sniper, iPlayer))
	{
		if (szSample[7] == 'd' && ((szSample[8] == 'i' && szSample[9] == 'e') || (szSample[8] == 'e' && szSample[9] == 'a')))
		{
			emit_sound(iPlayer, iChannel, g_Sound_Sniper_Die[random(sizeof g_Sound_Sniper_Die)], fVolume, fAttn, iFlags, iPitch);

			return FMRES_SUPERCEDE;
		}

		if (szSample[10] == 'f' && szSample[11] == 'a' && szSample[12] == 'l' && szSample[13] == 'l')
		{
			emit_sound(iPlayer, iChannel, g_Sound_Sniper_Fall[random(sizeof g_Sound_Sniper_Fall)], fVolume, fAttn, iFlags, iPitch);

			return FMRES_SUPERCEDE;
		}

		if (szSample[7] == 'b' && szSample[8] == 'h' && szSample[9] == 'i' && szSample[10] == 't')
		{
			emit_sound(iPlayer, iChannel, g_Sound_Sniper_Pain[random(sizeof g_Sound_Sniper_Pain)], fVolume, fAttn, iFlags, iPitch);

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
	if (BIT_VALID(g_iBit_Sniper, iPlayer))
	{
		// Remove sniper aura
		if (get_pcvar_num(g_pCvar_Sniper_Aura))
		{
			remove_task(iPlayer + TASK_AURA);
		}
	}

	BIT_SUB(g_iBit_Alive, iPlayer);
	BIT_SUB(g_iBit_Connected, iPlayer);
}

public FM_ClientDisconnect_Post(iPlayer)
{
	// Reset flags AFTER disconnect (to allow checking if the player was sniper before disconnecting)
	BIT_SUB(g_iBit_Sniper, iPlayer);

	ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Sniper);
}

// This is RG_CSGameRules_PlayerKilled Pre. Simply optimization.
public zpe_fw_kill_pre_bit_sub(iVictim, iAttacker)
{
	if (BIT_VALID(g_iBit_Sniper, iVictim))
	{
		// Remove sniper aura
		if (get_pcvar_num(g_pCvar_Sniper_Aura))
		{
			remove_task(iVictim + TASK_AURA);
		}
	}

	// When killed by a sniper victim explodes
	if (BIT_VALID(g_iBit_Sniper, iAttacker))
	{
		if (get_pcvar_num(g_pCvar_Sniper_Kill_Explode))
		{
			new iOrigin[3];

			get_user_origin(iVictim, iOrigin);

			message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin, 0);
			write_byte(TE_LAVASPLASH);
			write_coord(iOrigin[0]);
			write_coord(iOrigin[1]);
			write_coord(iOrigin[2] - 26);

			message_end();
		}
	}

	BIT_SUB(g_iBit_Alive, iVictim);
}

public zpe_fw_spawn_post_bit_add(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}

// Get Alive Count returns -alive players number-
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

// Get sniper Count returns -alive sniper number-
Get_Sniper_Count()
{
	new iSniper;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (BIT_VALID(g_iBit_Alive, i) && BIT_VALID(g_iBit_Sniper, i))
		{
			iSniper++;
		}
	}

	return iSniper;
}