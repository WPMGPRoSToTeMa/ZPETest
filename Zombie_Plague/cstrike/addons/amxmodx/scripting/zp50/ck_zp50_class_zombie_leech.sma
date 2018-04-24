/* AMX Mod X
*	[ZP] Class Zombie Leech.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "class zombie leech"
#define VERSION "5.2.3.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_zombieclasses.ini"

#define CLASS_ZOMBIE_LEECH_NAME "Leech Zombie"
#define CLASS_ZOMBIE_LEECH_INFO "HP- Knockback+ Leech++"
#define CLASS_ZOMBIE_LEECH_HEALTH 1300
#define CLASS_ZOMBIE_LEECH_SPEED 0.75
#define CLASS_ZOMBIE_LEECH_GRAVITY 1.0
#define CLASS_ZOMBIE_LEECH_KNOCKBACK 1.25

new const g_Class_Zombie_Leech_Models[][] =
{
	"zombie_source"
};

new const g_Class_Zombie_Leech_Clawmodels[][] =
{
	"models/zombie_plague/v_knife_zombie.mdl"
};

new const g_Class_Zombie_Leech_Pain_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_pain0.wav",
	"zombie_plague/zombie_sounds/zombie_pain1.wav"
};

new const g_Class_Zombie_Leech_Die_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_die0.wav",
	"zombie_plague/zombie_sounds/zombie_die1.wav",
	"zombie_plague/zombie_sounds/zombie_die2.wav"
};

new const g_Class_Zombie_Leech_Fall_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_fall0.wav"
};

new const g_Class_Zombie_Leech_Miss_Slash_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_miss_slash0.wav",
	"zombie_plague/zombie_sounds/zombie_miss_slash1.wav"
};

new const g_Class_Zombie_Leech_Miss_Wall_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_miss_wall0.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall1.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall2.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall3.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall4.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall5.wav"
};

new const g_Class_Zombie_Leech_Hit_Normal_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_hit_normal0.wav",
	"zombie_plague/zombie_sounds/zombie_hit_normal1.wav"
};

new const g_Class_Zombie_Leech_Hit_Stab_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_hit_stab0.wav"
};

new const g_Class_Zombie_Leech_Idle_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_idle0.wav",
	"zombie_plague/zombie_sounds/zombie_idle1.wav"
};

new const g_Class_Zombie_Leech_Infect_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_infect0.wav",
	"zombie_plague/zombie_sounds/zombie_infect1.wav"
};

new const g_Class_Zombie_Leech_Burning_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_burn0.wav",
	"zombie_plague/zombie_sounds/zombie_burn1.wav",
	"zombie_plague/zombie_sounds/zombie_burn2.wav",
	"zombie_plague/zombie_sounds/zombie_burn3.wav",
	"zombie_plague/zombie_sounds/zombie_burn4.wav"
};

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_zp50_class_zombie>

#define LIBRARY_NEMESIS "ck_zp50_class_nemesis"
#include <ck_zp50_class_nemesis>

#define LIBRARY_ASSASSIN "ck_zp50_class_assassin"
#include <ck_zp50_class_assassin>

#include <ck_zp50_kernel>
#include <zp_sounds_api>

#define SOUND_MAX_LENGTH 64

new Array:g_aClass_Zombie_Leech_Pain_Sounds;
new Array:g_aClass_Zombie_Leech_Die_Sounds;
new Array:g_aClass_Zombie_Leech_Fall_Sounds;
new Array:g_aClass_Zombie_Leech_Miss_Slash_Sounds;
new Array:g_aClass_Zombie_Leech_Miss_Wall_Sounds;
new Array:g_aClass_Zombie_Leech_Hit_Normal_Sounds;
new Array:g_aClass_Zombie_Leech_Hit_Stab_Sounds;
new Array:g_aClass_Zombie_Leech_Idle_Sounds;
new Array:g_aClass_Zombie_Leech_Infect_Sounds;
new Array:g_aClass_Zombie_Leech_Burning_Sounds;

new g_pCvar_Class_Zombie_Leech_HP_Reward;

new g_Class_Zombie_ID;

new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Class_Zombie_Leech_HP_Reward = register_cvar("zm_class_zombie_leech_hp_reward", "200");

	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_Post", 1);
}

public plugin_precache()
{
	g_Class_Zombie_ID = zp_class_zombie_register(CLASS_ZOMBIE_LEECH_NAME, CLASS_ZOMBIE_LEECH_INFO, CLASS_ZOMBIE_LEECH_HEALTH, CLASS_ZOMBIE_LEECH_SPEED, CLASS_ZOMBIE_LEECH_GRAVITY);

	zp_class_zombie_register_kb(g_Class_Zombie_ID, CLASS_ZOMBIE_LEECH_KNOCKBACK);

	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Models; i++)
	{
		zp_class_zombie_register_model(g_Class_Zombie_ID, g_Class_Zombie_Leech_Models[i]);
	}

	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Clawmodels; i++)
	{
		zp_class_zombie_register_claw(g_Class_Zombie_ID, g_Class_Zombie_Leech_Clawmodels[i]);
	}

	// Initialize arrays
	g_aClass_Zombie_Leech_Pain_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Leech_Die_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Leech_Fall_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Leech_Miss_Slash_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Leech_Miss_Wall_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Leech_Hit_Normal_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Leech_Hit_Stab_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Leech_Idle_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Leech_Infect_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Leech_Burning_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);

	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH PAIN", g_aClass_Zombie_Leech_Pain_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH DIE", g_aClass_Zombie_Leech_Die_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH FALL", g_aClass_Zombie_Leech_Fall_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH MISS SLASH", g_aClass_Zombie_Leech_Miss_Slash_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH MISS WALL", g_aClass_Zombie_Leech_Miss_Wall_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH HIT NORMAL", g_aClass_Zombie_Leech_Hit_Normal_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH HIT STAB", g_aClass_Zombie_Leech_Hit_Stab_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH IDLE", g_aClass_Zombie_Leech_Idle_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH INFECT", g_aClass_Zombie_Leech_Infect_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH BURNING", g_aClass_Zombie_Leech_Burning_Sounds);

	// If we couldn't load from file, use and save default ones
	if (ArraySize(g_aClass_Zombie_Leech_Pain_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Pain_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Pain_Sounds, g_Class_Zombie_Leech_Pain_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH PAIN", g_aClass_Zombie_Leech_Pain_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Leech_Die_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Die_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Die_Sounds, g_Class_Zombie_Leech_Die_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH DIE", g_aClass_Zombie_Leech_Die_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Leech_Fall_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Fall_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Fall_Sounds, g_Class_Zombie_Leech_Fall_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH FALL", g_aClass_Zombie_Leech_Fall_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Leech_Miss_Slash_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Miss_Slash_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Miss_Slash_Sounds, g_Class_Zombie_Leech_Miss_Slash_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH MISS SLASH", g_aClass_Zombie_Leech_Miss_Slash_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Leech_Miss_Wall_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Miss_Wall_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Miss_Wall_Sounds, g_Class_Zombie_Leech_Miss_Wall_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH MISS WALL", g_aClass_Zombie_Leech_Miss_Wall_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Leech_Hit_Normal_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Hit_Normal_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Hit_Normal_Sounds, g_Class_Zombie_Leech_Hit_Normal_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH HIT NORMAL", g_aClass_Zombie_Leech_Hit_Normal_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Leech_Hit_Stab_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Hit_Stab_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Hit_Stab_Sounds, g_Class_Zombie_Leech_Hit_Stab_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH HIT STAB", g_aClass_Zombie_Leech_Hit_Stab_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Leech_Idle_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Idle_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Idle_Sounds, g_Class_Zombie_Leech_Idle_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH IDLE", g_aClass_Zombie_Leech_Idle_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Leech_Infect_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Infect_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Infect_Sounds, g_Class_Zombie_Leech_Infect_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH INFECT", g_aClass_Zombie_Leech_Infect_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Leech_Burning_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Leech_Burning_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Leech_Burning_Sounds, g_Class_Zombie_Leech_Burning_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE LEECH BURNING", g_aClass_Zombie_Leech_Burning_Sounds);
	}

	// Pain sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Pain_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_PAIN, g_Class_Zombie_Leech_Pain_Sounds[i]);
	}

	// Die sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Die_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_DIE, g_Class_Zombie_Leech_Die_Sounds[i]);
	}

	// Fall sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Fall_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_FALL, g_Class_Zombie_Leech_Fall_Sounds[i]);
	}

	// Miss slash sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Miss_Slash_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_MISS_SLASH, g_Class_Zombie_Leech_Miss_Slash_Sounds[i]);
	}

	// Miss wall sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Miss_Wall_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_MISS_WALL, g_Class_Zombie_Leech_Miss_Wall_Sounds[i]);
	}

	// Hit normal sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Hit_Normal_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_HIT_NORMAL, g_Class_Zombie_Leech_Hit_Normal_Sounds[i]);
	}

	// Hit stab sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Hit_Stab_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_HIT_STAB, g_Class_Zombie_Leech_Hit_Stab_Sounds[i]);
	}

	// Idle sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Idle_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_IDLE, g_Class_Zombie_Leech_Idle_Sounds[i]);
	}

	// Infect sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Infect_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_INFECT, g_Class_Zombie_Leech_Infect_Sounds[i]);
	}

	// Burning sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Leech_Burning_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_FLAME, g_Class_Zombie_Leech_Burning_Sounds[i]);
	}
}

public zp_fw_core_infect_post(iPlayer, iAttacker)
{
	// Infected by a valid attacker?
	if (BIT_VALID(g_iBit_Alive, iAttacker) && iAttacker != iPlayer && zp_core_is_zombie(iAttacker))
	{
		// Leech Zombie infection hp bonus
		if (zp_class_zombie_get_current(iAttacker) == g_Class_Zombie_ID)
		{
			SET_USER_HEALTH(iAttacker, Float:GET_USER_HEALTH(iAttacker) + float(get_pcvar_num(g_pCvar_Class_Zombie_Leech_HP_Reward)));
		}
	}
}

public RG_CSGameRules_PlayerKilled_Post(iVictim, iAttacker)
{
	// Killed by a non-player entity or self killed
	if (iVictim == iAttacker || BIT_NOT_VALID(g_iBit_Alive, iAttacker))
	{
		return;
	}

	// Leech Zombie kill hp bonus
	if (zp_core_is_zombie(iAttacker) && zp_class_zombie_get_current(iAttacker) == g_Class_Zombie_ID)
	{
		// Unless nemesis and assassin
		if (!LibraryExists(LIBRARY_NEMESIS, LibType_Library) || !zp_class_nemesis_get(iAttacker) || !LibraryExists(LIBRARY_ASSASSIN, LibType_Library) || !zp_class_assassin_get(iAttacker))
		{
			SET_USER_HEALTH(iAttacker, GET_USER_HEALTH(iAttacker) + float(get_pcvar_num(g_pCvar_Class_Zombie_Leech_HP_Reward)));
		}
	}
}

public client_disconnected(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}