/* AMX Mod X
*	[ZP] Class Human Classic.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "class human classic"
#define VERSION "5.0.2.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

#define CLASS_HUMAN_CLASSIC_NAME "Classic Human"
#define CLASS_HUMAN_CLASSIC_INFO "=Balanced="
#define CLASS_HUMAN_CLASSIC_HEALTH 100
#define CLASS_HUMAN_CLASSIC_ARMOR 0
#define CLASS_HUMAN_CLASSIC_SPEED 1.0
#define CLASS_HUMAN_CLASSIC_GRAVITY 1.0

new const g_Class_Human_Classic_Pain_Sounds[][] =
{
	"player/pl_pain2.wav",
	"player/pl_pain4.wav",
	"player/pl_pain5.wav",
	"player/pl_pain6.wav",
	"player/pl_pain7.wav"
};

new const g_Class_Human_Classic_Die_Sounds[][] =
{
	"player/die1.wav",
	"player/die2.wav",
	"player/die3.wav"
};

new const g_Class_Human_Classic_Fall_Sounds[][] =
{
	"player/pl_fallpain1.wav",
	"player/pl_fallpain2.wav",
	"player/pl_fallpain3.wav",
};

new const g_Class_Human_Classic_Miss_Slash_Sounds[][] =
{
	"weapons/knife_slash1.wav",
	"weapons/knife_slash2.wav"
};

new const g_Class_Human_Classic_Miss_Wall_Sounds[][] =
{
	"weapons/knife_hitwall1.wav"
};

new const g_Class_Human_Classic_Hit_Normal_Sounds[][] =
{
	"weapons/knife_hit1.wav",
	"weapons/knife_hit2.wav",
	"weapons/knife_hit3.wav",
	"weapons/knife_hit4.wav"
};

new const g_Class_Human_Classic_Hit_Stab_Sounds[][] =
{
	"weapons/knife_stab.wav"
};

new const g_Class_Human_Classic_Deploy_Sounds[][] =
{
	"weapons/knife_deploy1.wav"
};

new const g_Class_Human_Classic_Models[][] =
{
	"arctic",
	"guerilla",
	"leet",
	"terror",
	"gign",
	"gsg9",
	"sas",
	"urban"
};

#include <amxmodx>
#include <amx_settings_api>
#include <ck_zp50_class_human>
#include <zp_sounds_api>

#define SOUND_MAX_LENGTH 64

new Array:g_aClass_Human_Classic_Pain_Sounds;
new Array:g_aClass_Human_Classic_Die_Sounds;
new Array:g_aClass_Human_Classic_Fall_Sounds;
new Array:g_aClass_Human_Classic_Miss_Slash_Sounds;
new Array:g_aClass_Human_Classic_Miss_Wall_Sounds;
new Array:g_aClass_Human_Classic_Hit_Normal_Sounds;
new Array:g_aClass_Human_Classic_Hit_Stab_Sounds;
new Array:g_aClass_Human_Classic_Deploy_Sounds;

new g_Class_Human_ID;

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_Class_Human_ID = zp_class_human_register(CLASS_HUMAN_CLASSIC_NAME, CLASS_HUMAN_CLASSIC_INFO, CLASS_HUMAN_CLASSIC_HEALTH, CLASS_HUMAN_CLASSIC_ARMOR, CLASS_HUMAN_CLASSIC_SPEED, CLASS_HUMAN_CLASSIC_GRAVITY);

	for (new i = 0; i < sizeof g_Class_Human_Classic_Models; i++)
	{
		zp_class_human_register_model(g_Class_Human_ID, g_Class_Human_Classic_Models[i]);
	}

	// Initialize arrays
	g_aClass_Human_Classic_Pain_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Human_Classic_Die_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Human_Classic_Fall_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Human_Classic_Miss_Slash_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Human_Classic_Miss_Wall_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Human_Classic_Hit_Normal_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Human_Classic_Hit_Stab_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aClass_Human_Classic_Deploy_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);

	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC PAIN", g_aClass_Human_Classic_Pain_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC DIE", g_aClass_Human_Classic_Die_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC FALL", g_aClass_Human_Classic_Fall_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC MISS SLASH", g_aClass_Human_Classic_Miss_Slash_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC MISS WALL", g_aClass_Human_Classic_Miss_Wall_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC HIT NORMAL", g_aClass_Human_Classic_Hit_Normal_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC HIT STAB", g_aClass_Human_Classic_Hit_Stab_Sounds);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC DEPLOY", g_aClass_Human_Classic_Deploy_Sounds);

	// If we couldn't load from file, use and save default ones
	if (ArraySize(g_aClass_Human_Classic_Pain_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Human_Classic_Pain_Sounds; i++)
		{
			ArrayPushString(g_aClass_Human_Classic_Pain_Sounds, g_Class_Human_Classic_Pain_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC PAIN", g_aClass_Human_Classic_Pain_Sounds);
	}

	if (ArraySize(g_aClass_Human_Classic_Die_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Human_Classic_Die_Sounds; i++)
		{
			ArrayPushString(g_aClass_Human_Classic_Die_Sounds, g_Class_Human_Classic_Die_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC DIE", g_aClass_Human_Classic_Die_Sounds);
	}

	if (ArraySize(g_aClass_Human_Classic_Fall_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Human_Classic_Fall_Sounds; i++)
		{
			ArrayPushString(g_aClass_Human_Classic_Fall_Sounds, g_Class_Human_Classic_Fall_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC FALL", g_aClass_Human_Classic_Fall_Sounds);
	}

	if (ArraySize(g_aClass_Human_Classic_Miss_Slash_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Human_Classic_Miss_Slash_Sounds; i++)
		{
			ArrayPushString(g_aClass_Human_Classic_Miss_Slash_Sounds, g_Class_Human_Classic_Miss_Slash_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC MISS SLASH", g_aClass_Human_Classic_Miss_Slash_Sounds);
	}

	if (ArraySize(g_aClass_Human_Classic_Miss_Wall_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Human_Classic_Miss_Wall_Sounds; i++)
		{
			ArrayPushString(g_aClass_Human_Classic_Miss_Wall_Sounds, g_Class_Human_Classic_Miss_Wall_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC MISS WALL", g_aClass_Human_Classic_Miss_Wall_Sounds);
	}

	if (ArraySize(g_aClass_Human_Classic_Hit_Normal_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Human_Classic_Hit_Normal_Sounds; i++)
		{
			ArrayPushString(g_aClass_Human_Classic_Hit_Normal_Sounds, g_Class_Human_Classic_Hit_Normal_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC HIT NORMAL", g_aClass_Human_Classic_Hit_Normal_Sounds);
	}

	if (ArraySize(g_aClass_Human_Classic_Hit_Stab_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Human_Classic_Hit_Stab_Sounds; i++)
		{
			ArrayPushString(g_aClass_Human_Classic_Hit_Stab_Sounds, g_Class_Human_Classic_Hit_Stab_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC HIT STAB", g_aClass_Human_Classic_Hit_Stab_Sounds);
	}

	if (ArraySize(g_aClass_Human_Classic_Deploy_Sounds) == 0)
	{
		for (new i = 0; i < sizeof g_Class_Human_Classic_Deploy_Sounds; i++)
		{
			ArrayPushString(g_aClass_Human_Classic_Deploy_Sounds, g_Class_Human_Classic_Deploy_Sounds[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "HUMAN CLASSIC DEPLOY", g_aClass_Human_Classic_Deploy_Sounds);
	}

	// Pain sounds
	for (new i = 0; i < sizeof g_Class_Human_Classic_Pain_Sounds; i++)
	{
		zp_class_human_register_sound(g_Class_Human_ID, HUMAN_SOUND_PAIN, g_Class_Human_Classic_Pain_Sounds[i]);
	}

	// Die sounds
	for (new i = 0; i < sizeof g_Class_Human_Classic_Die_Sounds; i++)
	{
		zp_class_human_register_sound(g_Class_Human_ID, HUMAN_SOUND_DIE, g_Class_Human_Classic_Die_Sounds[i]);
	}

	// Fall sounds
	for (new i = 0; i < sizeof g_Class_Human_Classic_Fall_Sounds; i++)
	{
		zp_class_human_register_sound(g_Class_Human_ID, HUMAN_SOUND_FALL, g_Class_Human_Classic_Fall_Sounds[i]);
	}

	// Miss slash sounds
	for (new i = 0; i < sizeof g_Class_Human_Classic_Miss_Slash_Sounds; i++)
	{
		zp_class_human_register_sound(g_Class_Human_ID, HUMAN_SOUND_MISS_SLASH, g_Class_Human_Classic_Miss_Slash_Sounds[i]);
	}

	// Miss wall sounds
	for (new i = 0; i < sizeof g_Class_Human_Classic_Miss_Wall_Sounds; i++)
	{
		zp_class_human_register_sound(g_Class_Human_ID, HUMAN_SOUND_MISS_WALL, g_Class_Human_Classic_Miss_Wall_Sounds[i]);
	}

	// Hit normal sounds
	for (new i = 0; i < sizeof g_Class_Human_Classic_Hit_Normal_Sounds; i++)
	{
		zp_class_human_register_sound(g_Class_Human_ID, HUMAN_SOUND_HIT_NORMAL, g_Class_Human_Classic_Hit_Normal_Sounds[i]);
	}

	// Hit stab sounds
	for (new i = 0; i < sizeof g_Class_Human_Classic_Hit_Stab_Sounds; i++)
	{
		zp_class_human_register_sound(g_Class_Human_ID, HUMAN_SOUND_HIT_STAB, g_Class_Human_Classic_Hit_Stab_Sounds[i]);
	}

	// Fix bug deploy sound
	for (new i = 0; i < sizeof g_Class_Human_Classic_Deploy_Sounds; i++)
	{
		precache_sound(g_Class_Human_Classic_Deploy_Sounds[i]);
	}
}