/* AMX Mod X
*	[ZPE] Class Assassin.
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

#define PLUGIN "class assassin"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_cs_maxspeed_api>
#include <ck_cs_weap_models_api>
#include <ck_zp50_kernel>

#define ZPE_SETTINGS_FILE "ZPE/classes/other/zpe_assassin.ini"

#define TASK_AURA 100
#define ID_AURA (iTask_ID - TASK_AURA)

#define PLAYERMODEL_MAX_LENGTH 32
#define MODEL_MAX_LENGTH 64
#define SOUND_MAX_LENGTH 64

new const g_Models_Assassin_Player[][] =
{
	"zombie_source"
};

new const g_Models_Assassin_Claw[][] =
{
	"models/zombie_plague/v_knife_zombie.mdl"
};

new const g_Sound_Assassin_Die[][] =
{
	"zombie_plague/zombie_sounds/zombie_die0.wav",
	"zombie_plague/zombie_sounds/zombie_die1.wav"
};

new const g_Sound_Assassin_Fall[][] =
{
	"zombie_plague/zombie_sounds/zombie_fall0.wav"
};

new const g_Sound_Assassin_Pain[][] =
{
	"zombie_plague/zombie_sounds/zombie_pain0.wav",
	"zombie_plague/zombie_sounds/zombie_pain1.wav"
};

new const g_Sound_Assassin_Miss_Slash[][] =
{
	"zombie_plague/zombie_sounds/zombie_miss_slash0.wav",
	"zombie_plague/zombie_sounds/zombie_miss_slash1.wav"
};

new const g_Sound_Assassin_Miss_Wall[][] =
{
	"zombie_plague/zombie_sounds/zombie_miss_wall0.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall1.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall2.wav"
};

new const g_Sound_Assassin_Hit_Normal[][] =
{
	"zombie_plague/zombie_sounds/zombie_hit_normal0.wav",
	"zombie_plague/zombie_sounds/zombie_hit_normal1.wav"
};

new const g_Sound_Assassin_Hit_Stab[][] =
{
	"zombie_plague/zombie_sounds/zombie_hit_stab0.wav"
};

new Array:g_aModels_Assassin_Player;
new Array:g_aModels_Assassin_Claw;

new Array:g_aSound_Assassin_Die;
new Array:g_aSound_Assassin_Fall;
new Array:g_aSound_Assassin_Pain;
new Array:g_aSound_Assassin_Miss_Slash;
new Array:g_aSound_Assassin_Miss_Wall;
new Array:g_aSound_Assassin_Hit_Normal;
new Array:g_aSound_Assassin_Hit_Stab;

new g_Forward;
new g_Forward_Result;

new g_pCvar_Assassin_Health;
new g_pCvar_Assassin_Base_Health;
new g_pCvar_Assassin_Speed;
new g_pCvar_Assassin_Gravity;

new g_pCvar_Assassin_Glow;
new g_pCvar_Assassin_Aura;
new g_pCvar_Assassin_Aura_Radius;
new g_pCvar_Assassin_Aura_Color_R;
new g_pCvar_Assassin_Aura_Color_G;
new g_pCvar_Assassin_Aura_Color_B;
new g_pCvar_Assassin_Aura_Life;
new g_pCvar_Assassin_Aura_Decay_Rate;

new g_pCvar_Assassin_Kill_Explode;
new g_pCvar_Assassin_Damage;

new g_pCvar_Assassin_Grenade_Frost;
new g_pCvar_Assassin_Grenade_Fire;

new g_iBit_Assassin;

new g_iBit_Alive;
new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Assassin_Health = register_cvar("zpe_assassin_health", "0.0");
	g_pCvar_Assassin_Base_Health = register_cvar("zpe_assassin_base_health", "2000.0");
	g_pCvar_Assassin_Speed = register_cvar("zpe_assassin_speed", "1.05");
	g_pCvar_Assassin_Gravity = register_cvar("zpe_assassin_gravity", "0.5");

	g_pCvar_Assassin_Glow = register_cvar("zpe_assassin_glow", "1");
	g_pCvar_Assassin_Aura = register_cvar("zpe_assassin_aura", "1");
	g_pCvar_Assassin_Aura_Radius = register_cvar("zpe_assassin_aura_radius", "1");
	g_pCvar_Assassin_Aura_Color_R = register_cvar("zpe_assassin_aura_color_R", "150");
	g_pCvar_Assassin_Aura_Color_G = register_cvar("zpe_assassin_aura_color_G", "0");
	g_pCvar_Assassin_Aura_Color_B = register_cvar("zpe_assassin_aura_color_B", "0");
	g_pCvar_Assassin_Aura_Life = register_cvar("zpe_assassin_aura_life", "2");
	g_pCvar_Assassin_Aura_Decay_Rate = register_cvar("zpe_assassin_aura_decay_rate", "0");

	g_pCvar_Assassin_Kill_Explode = register_cvar("zpe_assassin_kill_explode", "1");
	g_pCvar_Assassin_Damage = register_cvar("zpe_assassin_damage", "1000.0");

	g_pCvar_Assassin_Grenade_Frost = register_cvar("zpe_assassin_grenade_frost", "0");
	g_pCvar_Assassin_Grenade_Fire = register_cvar("zpe_assassin_grenade_fire", "1");

	g_Forward = CreateMultiForward("zpe_fw_class_asassin_bit_change", ET_CONTINUE, FP_CELL);

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_");

	// Dont use ReAPI, in the form of code - load
	register_forward(FM_EmitSound, "FM_EmitSound_");

	register_forward(FM_ClientDisconnect, "FM_ClientDisconnect_Post", 1);
}

public plugin_precache()
{
	// Initialize arrays
	g_aModels_Assassin_Player = ArrayCreate(PLAYERMODEL_MAX_LENGTH, 1);
	g_aModels_Assassin_Claw = ArrayCreate(MODEL_MAX_LENGTH, 1);

	g_aSound_Assassin_Die = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Assassin_Fall = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Assassin_Pain = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Assassin_Miss_Slash = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Assassin_Miss_Wall = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Assassin_Hit_Normal = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Assassin_Hit_Stab = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Player Models", "ASSASSIN", g_aModels_Assassin_Player);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Weapon Models", "V_KNIFE ASSASSIN", g_aModels_Assassin_Claw);

	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ASSASSIN DIE", g_aSound_Assassin_Die);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ASSASSIN FALL", g_aSound_Assassin_Fall);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ASSASSIN PAIN", g_aSound_Assassin_Pain);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ASSASSIN MISS SLASH", g_aSound_Assassin_Miss_Slash);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ASSASSIN MISS WALL", g_aSound_Assassin_Miss_Wall);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ASSASSIN HIT NORMAL", g_aSound_Assassin_Hit_Normal);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ASSASSIN HIT STAB", g_aSound_Assassin_Hit_Stab);

	new szBuffer[128];

	for (new i = 0; i < sizeof g_Models_Assassin_Player; i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", g_Models_Assassin_Player[i], g_Models_Assassin_Player[i]);

		precache_model(szBuffer);
	}

	for (new i = 0; i < sizeof g_Models_Assassin_Claw; i++)
	{
		precache_model(g_Models_Assassin_Claw[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Assassin_Die; i++)
	{
		precache_sound(g_Sound_Assassin_Die[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Assassin_Fall; i++)
	{
		precache_sound(g_Sound_Assassin_Fall[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Assassin_Pain; i++)
	{
		precache_sound(g_Sound_Assassin_Pain[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Assassin_Miss_Slash; i++)
	{
		precache_sound(g_Sound_Assassin_Miss_Slash[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Assassin_Miss_Wall; i++)
	{
		precache_sound(g_Sound_Assassin_Miss_Wall[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Assassin_Hit_Normal; i++)
	{
		precache_sound(g_Sound_Assassin_Hit_Normal[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Assassin_Hit_Stab; i++)
	{
		precache_sound(g_Sound_Assassin_Hit_Stab[i]);
	}
}

public plugin_cfg()
{
	server_cmd("exec addons/amxmodx/configs/ZPE/classes/other/zpe_assassin.cfg");
}

public plugin_natives()
{
	register_library("ck_zp50_class_assassin");

	register_native("zp_class_assassin_set", "native_class_assassin_set");
	register_native("zp_class_assassin_get_count", "native_class_assassin_get_count");
}

public RG_CBasePlayer_TakeDamage_(iVictim, iInflictor, iAttacker, Float:fDamage)
{
	// Non-player damage or self damage
	if (!(1 <= iAttacker <= MaxClients) || iVictim == iAttacker || BIT_NOT_VALID(g_iBit_Alive, iAttacker))
	{
		return HC_CONTINUE;
	}

	// Assassin attacking human
	if (BIT_VALID(g_iBit_Assassin, iAttacker) && !zp_core_is_zombie(iVictim))
	{
		// Ignore assassin damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (iInflictor == iAttacker)
		{
			// Set assassin damage
			SetHookChainArg(4, ATYPE_FLOAT, fDamage * get_pcvar_float(g_pCvar_Assassin_Damage)); // ExecuteHamB(Ham_Killed, victim, attacker, 0)
		}
	}

	return HC_CONTINUE;
}

public FM_EmitSound_(iPlayer, iChannel, const szSample[], Float:fVolume, Float:fAttn, iFlags, iPitch)
{
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer) || !zp_core_is_zombie(iPlayer))
	{
		return FMRES_IGNORED;
	}

	if (BIT_VALID(g_iBit_Assassin, iPlayer))
	{
		if (szSample[7] == 'd' && ((szSample[8] == 'i' && szSample[9] == 'e') || (szSample[8] == 'e' && szSample[9] == 'a')))
		{
			emit_sound(iPlayer, iChannel, g_Sound_Assassin_Die[random(sizeof g_Sound_Assassin_Die)], fVolume, fAttn, iFlags, iPitch);

			return FMRES_SUPERCEDE;
		}

		if (szSample[10] == 'f' && szSample[11] == 'a' && szSample[12] == 'l' && szSample[13] == 'l')
		{
			emit_sound(iPlayer, iChannel, g_Sound_Assassin_Fall[random(sizeof g_Sound_Assassin_Fall)], fVolume, fAttn, iFlags, iPitch);

			return FMRES_SUPERCEDE;
		}

		if (szSample[7] == 'b' && szSample[8] == 'h' && szSample[9] == 'i' && szSample[10] == 't')
		{
			emit_sound(iPlayer, iChannel, g_Sound_Assassin_Pain[random(sizeof g_Sound_Assassin_Pain)], fVolume, fAttn, iFlags, iPitch);

			return FMRES_SUPERCEDE;
		}

		if (szSample[8] == 'k' && szSample[9] == 'n' && szSample[10] == 'i')
		{
			if (szSample[14] == 's' && szSample[15] == 'l' && szSample[16] == 'a')
			{
				emit_sound(iPlayer, iChannel, g_Sound_Assassin_Miss_Slash[random(sizeof g_Sound_Assassin_Miss_Slash)], fVolume, fAttn, iFlags, iPitch);

				return FMRES_SUPERCEDE;
			}

			if (szSample[14] == 'h' && szSample[15] == 'i' && szSample[16] == 't')
			{
				if (szSample[17] == 'w')
				{
					emit_sound(iPlayer, iChannel, g_Sound_Assassin_Miss_Wall[random(sizeof g_Sound_Assassin_Miss_Wall)], fVolume, fAttn, iFlags, iPitch);

					return FMRES_SUPERCEDE;
				}

				else
				{
					emit_sound(iPlayer, iChannel, g_Sound_Assassin_Hit_Normal[random(sizeof g_Sound_Assassin_Hit_Normal)], fVolume, fAttn, iFlags, iPitch);

					return FMRES_SUPERCEDE;
				}
			}

			if (szSample[14] == 's' && szSample[15] == 't' && szSample[16] == 'a')
			{
				emit_sound(iPlayer, iChannel, g_Sound_Assassin_Hit_Stab[random(sizeof g_Sound_Assassin_Hit_Stab)], fVolume, fAttn, iFlags, iPitch);

				return FMRES_SUPERCEDE;
			}
		}
	}

	return FMRES_IGNORED;
}

public zp_fw_grenade_frost_pre(iPlayer)
{
	// Prevent frost for assassin
	if (BIT_VALID(g_iBit_Assassin, iPlayer) && !get_pcvar_num(g_pCvar_Assassin_Grenade_Frost))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_grenade_fire_pre(iPlayer)
{
	// Prevent burning for assassin
	if (BIT_VALID(g_iBit_Assassin, iPlayer) && !get_pcvar_num(g_pCvar_Assassin_Grenade_Fire))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_core_spawn_post(iPlayer)
{
	if (BIT_VALID(g_iBit_Assassin, iPlayer))
	{
		// Remove assassin glow
		if (get_pcvar_num(g_pCvar_Assassin_Glow))
		{
			rg_set_user_rendering(iPlayer);
		}

		// Remove assassin aura
		if (get_pcvar_num(g_pCvar_Assassin_Aura))
		{
			remove_task(iPlayer + TASK_AURA);
		}

		// Remove assassin flag
		BIT_SUB(g_iBit_Assassin, iPlayer);

		ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Assassin);
	}
}

public zp_fw_core_cure(iPlayer)
{
	if (BIT_VALID(g_iBit_Assassin, iPlayer))
	{
		// Remove assassin glow
		if (get_pcvar_num(g_pCvar_Assassin_Glow))
		{
			rg_set_user_rendering(iPlayer);
		}

		// Remove assassin aura
		if (get_pcvar_num(g_pCvar_Assassin_Aura))
		{
			remove_task(iPlayer + TASK_AURA);
		}

		// Remove assassin flag
		BIT_SUB(g_iBit_Assassin, iPlayer);

		ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Assassin);
	}
}

public zp_fw_core_infect_post(iPlayer)
{
	// Apply assassin attributes?
	if (BIT_NOT_VALID(g_iBit_Assassin, iPlayer))
	{
		return;
	}

	// Health
	if (get_pcvar_float(g_pCvar_Assassin_Health) == 0.0)
	{
		SET_USER_HEALTH(iPlayer, get_pcvar_float(g_pCvar_Assassin_Base_Health) * Get_Alive_Count());
	}

	else
	{
		SET_USER_HEALTH(iPlayer, get_pcvar_float(g_pCvar_Assassin_Health));
	}

	// Gravity
	SET_USER_GRAVITY(iPlayer, get_pcvar_float(g_pCvar_Assassin_Gravity));

	// Speed
	cs_set_player_maxspeed_auto(iPlayer, get_pcvar_float(g_pCvar_Assassin_Speed));

	// Apply assassin player model
	rg_set_user_model(iPlayer, g_Models_Assassin_Player[random(sizeof g_Models_Assassin_Player)]);

	// Apply assassin claw model
	cs_set_player_view_model(iPlayer, CSW_KNIFE, g_Models_Assassin_Claw[random(sizeof g_Models_Assassin_Claw)]);

	// Assassin glow
	if (get_pcvar_num(g_pCvar_Assassin_Glow))
	{
		rg_set_user_rendering(iPlayer, kRenderFxGlowShell, get_pcvar_num(g_pCvar_Assassin_Aura_Color_R), get_pcvar_num(g_pCvar_Assassin_Aura_Color_G), get_pcvar_num(g_pCvar_Assassin_Aura_Color_B), kRenderNormal, 25);
	}

	// Assassin aura task
	if (get_pcvar_num(g_pCvar_Assassin_Aura))
	{
		set_task(0.1, "Assassin_Aura", iPlayer + TASK_AURA, _, _, "b");
	}
}

public native_class_assassin_set(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	if (BIT_VALID(g_iBit_Assassin, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Player already a assassin (%d)", iPlayer);

		return false;
	}

	BIT_ADD(g_iBit_Assassin, iPlayer);

	ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Assassin);

	zp_core_force_infect(iPlayer);

	return true;
}

public native_class_assassin_get_count(iPlugin_ID, iNum_Params)
{
	return Get_Assassin_Count();
}

// Assassin aura task
public Assassin_Aura(iTask_ID)
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
	write_byte(get_pcvar_num(g_pCvar_Assassin_Aura_Radius)); // radius
	write_byte(get_pcvar_num(g_pCvar_Assassin_Aura_Color_R)); // r
	write_byte(get_pcvar_num(g_pCvar_Assassin_Aura_Color_G)); // g
	write_byte(get_pcvar_num(g_pCvar_Assassin_Aura_Color_B)); // b
	write_byte(get_pcvar_num(g_pCvar_Assassin_Aura_Life)); // life
	write_byte(get_pcvar_num(g_pCvar_Assassin_Aura_Decay_Rate)); // decay rate
	message_end();
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	if (BIT_VALID(g_iBit_Assassin, iPlayer))
	{
		// Remove assassin aura
		if (get_pcvar_num(g_pCvar_Assassin_Aura))
		{
			remove_task(iPlayer + TASK_AURA);
		}
	}

	BIT_SUB(g_iBit_Alive, iPlayer);
	BIT_SUB(g_iBit_Connected, iPlayer);
}

public FM_ClientDisconnect_Post(iPlayer)
{
	// Reset flags AFTER disconnect (to allow checking if the player was assassin before disconnecting)
	BIT_SUB(g_iBit_Assassin, iPlayer);

	ExecuteForward(g_Forward, g_Forward_Result, g_iBit_Assassin);
}

// This is RG_CSGameRules_PlayerKilled Pre. Simply optimization.
public zpe_fw_kill_pre_bit_sub(iVictim)
{
	if (BIT_VALID(g_iBit_Assassin, iVictim))
	{
		// Assassin explodes!
		if (get_pcvar_num(g_pCvar_Assassin_Kill_Explode))
		{
			SetHookChainArg(3, ATYPE_INTEGER, 2);
		}

		// Remove assassin aura
		if (get_pcvar_num(g_pCvar_Assassin_Aura))
		{
			remove_task(iVictim + TASK_AURA);
		}
	}

	BIT_SUB(g_iBit_Alive, iVictim);
}

public zpe_fw_spawn_post_bit_add(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}

// Get alive count -returns alive players number-
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

// Get assassin count -returns alive assassin number-
Get_Assassin_Count()
{
	new iAssassin;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (BIT_VALID(g_iBit_Alive, i) && BIT_VALID(g_iBit_Assassin, i))
		{
			iAssassin++;
		}
	}

	return iAssassin;
}