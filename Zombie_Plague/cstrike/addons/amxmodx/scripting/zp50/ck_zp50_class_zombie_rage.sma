/* AMX Mod X
*	[ZP] Class Zombie Rage.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "class zombie rage"
#define VERSION "5.2.3.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_zombieclasses.ini"

#define CLASS_ZOMBIE_RAGE_NAME "Rage Zombie"
#define CLASS_ZOMBIE_RAGE_INFO "HP+ Speed+ Radioactivity++"
#define CLASS_ZOMBIE_RAGE_HEALTH 2250
#define CLASS_ZOMBIE_RAGE_SPEED 0.80
#define CLASS_ZOMBIE_RAGE_GRAVITY 1.0
#define CLASS_ZOMBIE_RAGE_KNOCKBACK 0.5

new const g_Class_Zombie_Rage_Models[][] =
{
	"zombie_source"
};

new const g_Class_Zombie_Rage_Clawmodels[][] =
{
	"models/zombie_plague/v_knife_zombie.mdl"
};

new const g_Class_Zombie_Rage_Pain_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_pain0.wav",
	"zombie_plague/zombie_sounds/zombie_pain1.wav"
};

new const g_Class_Zombie_Rage_Die_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_die0.wav",
	"zombie_plague/zombie_sounds/zombie_die1.wav",
	"zombie_plague/zombie_sounds/zombie_die2.wav"
};

new const g_Class_Zombie_Rage_Fall_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_fall0.wav"
};

new const g_Class_Zombie_Rage_Miss_Slash_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_miss_slash0.wav",
	"zombie_plague/zombie_sounds/zombie_miss_slash1.wav"
};

new const g_Class_Zombie_Rage_Miss_Wall_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_miss_wall0.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall1.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall2.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall3.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall4.wav",
	"zombie_plague/zombie_sounds/zombie_miss_wall5.wav"
};

new const g_Class_Zombie_Rage_Hit_Normal_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_hit_normal0.wav",
	"zombie_plague/zombie_sounds/zombie_hit_normal1.wav"
};

new const g_Class_Zombie_Rage_Hit_Stab_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_hit_stab0.wav"
};

new const g_Class_Zombie_Rage_Idle_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_idle0.wav",
	"zombie_plague/zombie_sounds/zombie_idle1.wav"
};

new const g_Class_Zombie_Rage_Infect_Sounds[][] =
{
	"zombie_plague/zombie_sounds/zombie_infect0.wav",
	"zombie_plague/zombie_sounds/zombie_infect1.wav"
};

new const g_Class_Zombie_Rage_Burning_Sounds[][] =
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
#include <fakemeta>
#include <ck_zp50_class_zombie>

#define LIBRARY_NEMESIS "ck_zp50_class_nemesis"
#include <ck_zp50_class_nemesis>

#define LIBRARY_ASSASSIN "ck_zp50_class_assassin"
#include <ck_zp50_class_assassin>

#include <zp_sounds_api>

#define SOUND_MAX_LENGTH 64

new Array:g_aClass_Zombie_Rage_Pain_Sounds;
new Array:g_aClass_Zombie_Rage_Die_Sounds;
new Array:g_aClass_Zombie_Rage_Fall_Sounds;
new Array:g_aClass_Zombie_Rage_Miss_Slash_Sounds;
new Array:g_aClass_Zombie_Rage_Miss_Wall_Sounds;
new Array:g_aClass_Zombie_Rage_Hit_Normal_Sounds;
new Array:g_aClass_Zombie_Rage_Hit_Stab_Sounds;
new Array:g_aClass_Zombie_Rage_Idle_Sounds;
new Array:g_aClass_Zombie_Rage_Infect_Sounds;
new Array:g_aClass_Zombie_Rage_Burning_Sounds;

new g_pCvar_Class_Zombie_Rage_Aura_R;
new g_pCvar_Class_Zombie_Rage_Aura_G;
new g_pCvar_Class_Zombie_Rage_Aura_B;

new g_Class_Zombie_ID;

public plugin_init()
{
	g_pCvar_Class_Zombie_Rage_Aura_R = register_cvar("zm_class_zombie_rage_aura_r", "0");
	g_pCvar_Class_Zombie_Rage_Aura_G = register_cvar("zm_class_zombie_rage_aura_g", "250");
	g_pCvar_Class_Zombie_Rage_Aura_B = register_cvar("zm_class_zombie_rage_aura_b", "0");
}

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_Class_Zombie_ID = zp_class_zombie_register(CLASS_ZOMBIE_RAGE_NAME, CLASS_ZOMBIE_RAGE_INFO, CLASS_ZOMBIE_RAGE_HEALTH, CLASS_ZOMBIE_RAGE_SPEED, CLASS_ZOMBIE_RAGE_GRAVITY);

	zp_class_zombie_register_kb(g_Class_Zombie_ID, CLASS_ZOMBIE_RAGE_KNOCKBACK);

	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Models; i++)
	{
		zp_class_zombie_register_model(g_Class_Zombie_ID, g_Class_Zombie_Rage_Models[i]);
	}

	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Clawmodels; i++)
	{
		zp_class_zombie_register_claw(g_Class_Zombie_ID, g_Class_Zombie_Rage_Clawmodels[i]);
	}

	// Initialize arrays
	g_aClass_Zombie_Rage_Pain_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Rage_Die_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Rage_Fall_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Rage_Miss_Slash_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Rage_Miss_Wall_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Rage_Hit_Normal_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Rage_Hit_Stab_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Rage_Idle_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Rage_Infect_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Zombie_Rage_Burning_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);

	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE PAIN", g_aClass_Zombie_Rage_Pain_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE DIE", g_aClass_Zombie_Rage_Die_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE FALL", g_aClass_Zombie_Rage_Fall_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE MISS SLASH", g_aClass_Zombie_Rage_Miss_Slash_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE MISS WALL", g_aClass_Zombie_Rage_Miss_Wall_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE HIT NORMAL", g_aClass_Zombie_Rage_Hit_Normal_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE HIT STAB", g_aClass_Zombie_Rage_Hit_Stab_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE IDLE", g_aClass_Zombie_Rage_Idle_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE INFECT", g_aClass_Zombie_Rage_Infect_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE BURNING", g_aClass_Zombie_Rage_Burning_Sounds);

	// If we couldn't load from file, use and save default ones
	if (ArraySize(g_aClass_Zombie_Rage_Pain_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Pain_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Pain_Sounds, g_Class_Zombie_Rage_Pain_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE PAIN", g_aClass_Zombie_Rage_Pain_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Rage_Die_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Die_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Die_Sounds, g_Class_Zombie_Rage_Die_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE DIE", g_aClass_Zombie_Rage_Die_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Rage_Fall_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Fall_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Fall_Sounds, g_Class_Zombie_Rage_Fall_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE FALL", g_aClass_Zombie_Rage_Fall_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Rage_Miss_Slash_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Miss_Slash_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Miss_Slash_Sounds, g_Class_Zombie_Rage_Miss_Slash_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE MISS SLASH", g_aClass_Zombie_Rage_Miss_Slash_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Rage_Miss_Wall_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Miss_Wall_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Miss_Wall_Sounds, g_Class_Zombie_Rage_Miss_Wall_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE MISS WALL", g_aClass_Zombie_Rage_Miss_Wall_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Rage_Hit_Normal_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Hit_Normal_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Hit_Normal_Sounds, g_Class_Zombie_Rage_Hit_Normal_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE HIT NORMAL", g_aClass_Zombie_Rage_Hit_Normal_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Rage_Hit_Stab_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Hit_Stab_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Hit_Stab_Sounds, g_Class_Zombie_Rage_Hit_Stab_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE HIT STAB", g_aClass_Zombie_Rage_Hit_Stab_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Rage_Idle_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Idle_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Idle_Sounds, g_Class_Zombie_Rage_Idle_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE IDLE", g_aClass_Zombie_Rage_Idle_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Rage_Infect_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Infect_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Infect_Sounds, g_Class_Zombie_Rage_Infect_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE INFECT", g_aClass_Zombie_Rage_Infect_Sounds);
	}

	if (ArraySize(g_aClass_Zombie_Rage_Burning_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Zombie_Rage_Burning_Sounds; i++)
		{
			ArrayPushString(g_aClass_Zombie_Rage_Burning_Sounds, g_Class_Zombie_Rage_Burning_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ZOMBIE RAGE BURNING", g_aClass_Zombie_Rage_Burning_Sounds);
	}

	// Pain sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Pain_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_PAIN, g_Class_Zombie_Rage_Pain_Sounds[i]);
	}

	// Die sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Die_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_DIE, g_Class_Zombie_Rage_Die_Sounds[i]);
	}

	// Fall sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Fall_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_FALL, g_Class_Zombie_Rage_Fall_Sounds[i]);
	}

	// Miss slash sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Miss_Slash_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_MISS_SLASH, g_Class_Zombie_Rage_Miss_Slash_Sounds[i]);
	}

	// Miss wall sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Miss_Wall_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_MISS_WALL, g_Class_Zombie_Rage_Miss_Wall_Sounds[i]);
	}

	// Hit normal sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Hit_Normal_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_HIT_NORMAL, g_Class_Zombie_Rage_Hit_Normal_Sounds[i]);
	}

	// Hit stab sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Hit_Stab_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_HIT_STAB, g_Class_Zombie_Rage_Hit_Stab_Sounds[i]);
	}

	// Idle sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Idle_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_IDLE, g_Class_Zombie_Rage_Idle_Sounds[i]);
	}

	// Infect sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Infect_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_INFECT, g_Class_Zombie_Rage_Infect_Sounds[i]);
	}

	// Burning sounds
	for (new i = 0; i < sizeof g_Class_Zombie_Rage_Burning_Sounds; i++)
	{
		zp_class_zombie_register_sound(g_Class_Zombie_ID, ZOMBIE_SOUND_FLAME, g_Class_Zombie_Rage_Burning_Sounds[i]);
	}
}

public zp_fw_core_infect_post(iPlayer)
{
	// Rage Zombie glow
	if (zp_class_zombie_get_current(iPlayer) == g_Class_Zombie_ID)
	{
		// Apply custom glow, unless nemesis and assassin
		if (!LibraryExists(LIBRARY_NEMESIS, LibType_Library) || !zp_class_nemesis_get(iPlayer) || !LibraryExists(LIBRARY_ASSASSIN, LibType_Library) || !zp_class_assassin_get(iPlayer))
		{
			rh_set_user_rendering(iPlayer, kRenderFxGlowShell, get_pcvar_num(g_pCvar_Class_Zombie_Rage_Aura_R), get_pcvar_num(g_pCvar_Class_Zombie_Rage_Aura_G), get_pcvar_num(g_pCvar_Class_Zombie_Rage_Aura_B), kRenderNormal, 15);
		}
	}
}

public zp_fw_core_infect(iPlayer)
{
	// Player was using zombie class with custom rendering, restore it to normal
	if (zp_class_zombie_get_current(iPlayer) == g_Class_Zombie_ID)
	{
		rh_set_user_rendering(iPlayer);
	}
}

public zp_fw_core_cure(iPlayer)
{
	// Player was using zombie class with custom rendering, restore it to normal
	if (zp_class_zombie_get_current(iPlayer) == g_Class_Zombie_ID)
	{
		rh_set_user_rendering(iPlayer);
	}
}

public client_disconnected(iPlayer)
{
	// Player was using zombie class with custom rendering, restore it to normal
	if (zp_class_zombie_get_current(iPlayer) == g_Class_Zombie_ID)
	{
		rh_set_user_rendering(iPlayer);
	}
}