/* AMX Mod X
*	[ZP] Class Zombie Raptor.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "class zombie raptor"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_zombieclasses.ini"

#define CLASS_ZOMBIE_RAPTOR_NAME "Raptor Zombie"
#define CLASS_ZOMBIE_RAPTOR_INFO "HP-- Speed++ Knockback++"
#define CLASS_ZOMBIE_RAPTOR_HEALTH 900
#define CLASS_ZOMBIE_RAPTOR_SPEED 0.90
#define CLASS_ZOMBIE_RAPTOR_GRAVITY 1.0
#define CLASS_ZOMBIE_RAPTOR_KNOCKBACK 1.5

new const g_Class_Zombie_Raptor_Models[][] =
{
	"zombie_source"
};

new const g_Class_Zombie_Raptor_Clawmodels[][] =
{
	"models/zombie_plague/v_knife_zombie.mdl"
};

new const g_Class_Zombie_Raptor_Pain_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_pain0.wav",
	"zombie_plague/zombie_sounds/zombie_pain1.wav"
};

new const g_Class_Zombie_Raptor_Die_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_die0.wav",
	"zombie_plague/zombie_sounds/zombie_die1.wav",
	"zombie_plague/zombie_sounds/zombie_die2.wav"
};

new const g_Class_Zombie_Raptor_Fall_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_fall0.wav"
};

new const g_Class_Zombie_Raptor_Miss_Slash_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_miss_slash0.wav",
	"zombie_plague/zombie_sounds/zombie_miss_slash1.wav"
};

new const g_Class_Zombie_Raptor_Miss_Wall_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_miss_wall0.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall1.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall2.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall3.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall4.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall5.wav"
};

new const g_Class_Zombie_Raptor_Hit_Normal_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_hit_normal0.wav",
	"zombie_plague/zombie_sounds/zombie_hit_normal1.wav"
};

new const g_Class_Zombie_Raptor_Hit_Stab_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_hit_stab0.wav"
};

new const g_Class_Zombie_Raptor_Idle_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_idle0.wav",
	"zombie_plague/zombie_sounds/zombie_idle1.wav"
};

new const g_Class_Zombie_Raptor_Infect_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_infect0.wav",
	"zombie_plague/zombie_sounds/zombie_infect1.wav"
};

new const g_Class_Zombie_Raptor_Burning_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_burn0.wav",
	"zombie_plague/zombie_sounds/zombie_burn1.wav",
	"zombie_plague/zombie_sounds/zombie_burn2.wav",
	"zombie_plague/zombie_sounds/zombie_burn3.wav",
	"zombie_plague/zombie_sounds/zombie_burn4.wav"
};

#include <amxmodx>
#include <amx_settings_api>
#include <ck_zp50_class_zombie>
#include <zp_sounds_api>

#define SOUND_MAX_LENGTH 64

new Array:g_aClass_Zombie_Raptor_Pain_Sounds;
new Array:g_aClass_Zombie_Raptor_Die_Sounds;
new Array:g_aClass_Zombie_Raptor_Fall_Sounds;
new Array:g_aClass_Zombie_Raptor_Miss_Slash_Sounds;
new Array:g_aClass_Zombie_Raptor_Miss_Wall_Sounds;
new Array:g_aClass_Zombie_Raptor_Hit_Normal_Sounds;
new Array:g_aClass_Zombie_Raptor_Hit_Stab_Sounds;
new Array:g_aClass_Zombie_Raptor_Idle_Sounds;
new Array:g_aClass_Zombie_Raptor_Infect_Sounds;
new Array:g_aClass_Zombie_Raptor_Burning_Sounds;

new g_Class_Zombie_ID;

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_Class_Zombie_ID = zp_class_zombie_register(CLASS_ZOMBIE_RAPTOR_NAME, CLASS_ZOMBIE_RAPTOR_INFO, CLASS_ZOMBIE_RAPTOR_HEALTH, CLASS_ZOMBIE_RAPTOR_SPEED, CLASS_ZOMBIE_RAPTOR_GRAVITY);

	zp_class_zombie_register_kb(g_Class_Zombie_ID, CLASS_ZOMBIE_RAPTOR_KNOCKBACK);

	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Models; i++)
	{
		zp_class_zombie_register_model(g_Class_Zombie_ID, g_Class_Zombie_Raptor_Models[i]);
	}

	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Clawmodels; i++)
	{
		zp_class_zombie_register_claw(g_Class_Zombie_ID, g_Class_Zombie_Raptor_Clawmodels[i]);
	}

	// Initialize arrays
	g_aClass_Zombie_Raptor_Pain_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Raptor_Die_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Raptor_Fall_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Raptor_Miss_Slash_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Raptor_Miss_Wall_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Raptor_Hit_Normal_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Raptor_Hit_Stab_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Raptor_Idle_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Raptor_Infect_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Raptor_Burning_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);

	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR PAIN", g_aClass_Zombie_Raptor_Pain_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR DIE", g_aClass_Zombie_Raptor_Die_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR FALL", g_aClass_Zombie_Raptor_Fall_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR MISS SLASH", g_aClass_Zombie_Raptor_Miss_Slash_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR MISS WALL", g_aClass_Zombie_Raptor_Miss_Wall_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR HIT NORMAL", g_aClass_Zombie_Raptor_Hit_Normal_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR HIT STAB", g_aClass_Zombie_Raptor_Hit_Stab_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR IDLE", g_aClass_Zombie_Raptor_Idle_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR INFECT", g_aClass_Zombie_Raptor_Infect_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR BURNING", g_aClass_Zombie_Raptor_Burning_Sounds);

	// If we couldn't load from file, use and save default ones
	if (ArraySize(g_aClass_Zombie_Raptor_Pain_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Pain_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Pain_Sounds, g_Class_Zombie_Raptor_Pain_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR PAIN", g_aClass_Zombie_Raptor_Pain_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Raptor_Die_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Die_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Die_Sounds, g_Class_Zombie_Raptor_Die_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR DIE", g_aClass_Zombie_Raptor_Die_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Raptor_Fall_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Fall_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Fall_Sounds, g_Class_Zombie_Raptor_Fall_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR FALL", g_aClass_Zombie_Raptor_Fall_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Raptor_Miss_Slash_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Miss_Slash_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Miss_Slash_Sounds, g_Class_Zombie_Raptor_Miss_Slash_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR MISS SLASH", g_aClass_Zombie_Raptor_Miss_Slash_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Raptor_Miss_Wall_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Miss_Wall_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Miss_Wall_Sounds, g_Class_Zombie_Raptor_Miss_Wall_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR MISS WALL", g_aClass_Zombie_Raptor_Miss_Wall_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Raptor_Hit_Normal_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Hit_Normal_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Hit_Normal_Sounds, g_Class_Zombie_Raptor_Hit_Normal_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR HIT NORMAL", g_aClass_Zombie_Raptor_Hit_Normal_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Raptor_Hit_Stab_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Hit_Stab_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Hit_Stab_Sounds, g_Class_Zombie_Raptor_Hit_Stab_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR HIT STAB", g_aClass_Zombie_Raptor_Hit_Stab_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Raptor_Idle_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Idle_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Idle_Sounds, g_Class_Zombie_Raptor_Idle_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR IDLE", g_aClass_Zombie_Raptor_Idle_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Raptor_Infect_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Infect_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Infect_Sounds, g_Class_Zombie_Raptor_Infect_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR INFECT", g_aClass_Zombie_Raptor_Infect_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Raptor_Burning_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Burning_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Raptor_Burning_Sounds, g_Class_Zombie_Raptor_Burning_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAPTOR BURNING", g_aClass_Zombie_Raptor_Burning_Sounds);
	}

	// Pain sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Pain_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_PAIN, g_Class_Zombie_Raptor_Pain_Sounds[i]);
	}

	// Die sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Die_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_DIE, g_Class_Zombie_Raptor_Die_Sounds[i]);
	}

	// Fall sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Fall_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_FALL, g_Class_Zombie_Raptor_Fall_Sounds[i]);
	}

	// Miss slash sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Miss_Slash_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_MISS_SLASH, g_Class_Zombie_Raptor_Miss_Slash_Sounds[i]);
	}

	// Miss wall sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Miss_Wall_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_MISS_WALL, g_Class_Zombie_Raptor_Miss_Wall_Sounds[i]);
	}

	// Hit normal sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Hit_Normal_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_HIT_NORMAL, g_Class_Zombie_Raptor_Hit_Normal_Sounds[i]);
	}

	// Hit stab sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Hit_Stab_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_HIT_STAB, g_Class_Zombie_Raptor_Hit_Stab_Sounds[i]);
	}

	// Idle sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Idle_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_IDLE, g_Class_Zombie_Raptor_Idle_Sounds[i]);
	}

	// Infect sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Infect_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_INFECT, g_Class_Zombie_Raptor_Infect_Sounds[i]);
	}

	// Burning sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Burning_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_FLAME, g_Class_Zombie_Raptor_Burning_Sounds[i]);
	}
}