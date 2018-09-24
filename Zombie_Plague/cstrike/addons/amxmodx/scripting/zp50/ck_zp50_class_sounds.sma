/* AMX Mod X
*	[ZPE] Class Sounds.
*	Author: C&K Corporation.
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

#define PLUGIN "class sounds"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <amx_settings_api>
#include <ck_zp50_class_zombie>
#include <ck_zp50_class_human>
#include <ck_zp50_sounds_api>

#define ZPE_CLASS_ZOMBIE_SETTINGS_PATH "ZPE/classes/zombie"
#define ZPE_CLASS_HUMAN_SETTINGS_PATH "ZPE/classes/human"

new const g_szSound_Section_Name[] = "Sounds";

new const g_szZombie_Sound_Types[_:ZOMBIE_SOUNDS][] =
{
	"DIE",
	"FALL",
	"PAIN",
	"MISS SLASH",
	"MISS WALL",
	"HIT NORMAL",
	"HIT STAB",
	"INFECT",
	"IDLE",
	"FLAME"
};

new const g_szDefault_Zombie_Sounds[_:ZOMBIE_SOUNDS][] =
{
	"zombie_plague/zombie_sounds/zombie_die0.wav",
	"zombie_plague/zombie_fall1.wav",
	"zombie_plague/zombie_pain1.wav",
	"zombie_plague/zombie_sounds/zombie_miss_slash0.wav",
	"weapons/knife_hitwall1.wav",
	"weapons/knife_hit1.wav",
	"weapons/knife_stab.wav",
	"zombie_plague/zombie_sounds/zombie_infect0.wav",
	"zombie_plague/zombie_brains1.wav",
	"zombie_plague/zombie_sounds/zombie_burn0.wav"
};

new const g_szHuman_Sound_Types[_:HUMAN_SOUNDS][] =
{
	"DIE",
	"FALL",
	"PAIN",
	"MISS SLASH",
	"MISS WALL",
	"HIT NORMAL",
	"HIT STAB",
	"IDLE"
};

new const g_szDefault_Human_Sounds[_:HUMAN_SOUNDS][] =
{
	"player/die1.wav",
	"player/pl_fallpain1.wav",
	"player/pl_pain2.wav",
	"weapons/knife_slash1.wav",
	"weapons/knife_hitwall1.wav",
	"weapons/knife_hit1.wav",
	"weapons/knife_stab.wav",
	"hostage/hos1.wav"
};

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public zp_fw_class_zombie_register_post(iClass_ID)
{
	new szReal_Name[32];
	zp_class_zombie_get_real_name(iClass_ID, szReal_Name, charsmax(szReal_Name));

	new szClass_Zombie_Config_Path[64];
	formatex(szClass_Zombie_Config_Path, charsmax(szClass_Zombie_Config_Path), "%s/%s.ini", ZPE_CLASS_ZOMBIE_SETTINGS_PATH, szReal_Name);

	new Array:aSounds = ArrayCreate(128, 1);
	new szSound[128];
	new iArraySize;

	for (new i = 0; i < _:ZOMBIE_SOUNDS; i++)
	{
		amx_load_setting_string_arr(szClass_Zombie_Config_Path, g_szSound_Section_Name, g_szZombie_Sound_Types[i], aSounds);

		iArraySize = ArraySize(aSounds);

		if (iArraySize > 0)
		{
			for (new j = 0; j < iArraySize; j++)
			{
				ArrayGetString(aSounds, j, szSound, charsmax(szSound));
				zp_class_zombie_register_sound(iClass_ID, ZOMBIE_SOUNDS:i, szSound);
			}

			ArrayClear(aSounds);
		}

		else
		{
			amx_save_setting_string(szClass_Zombie_Config_Path, g_szSound_Section_Name, g_szZombie_Sound_Types[i], g_szDefault_Zombie_Sounds[i]);
			zp_class_zombie_register_sound(iClass_ID, ZOMBIE_SOUNDS:i, g_szDefault_Zombie_Sounds[i]);
		}
	}

	ArrayDestroy(aSounds);
}

public zp_fw_class_human_register_post(iClass_ID)
{
	new szReal_Name[32];
	zp_class_human_get_real_name(iClass_ID, szReal_Name, charsmax(szReal_Name));

	new szClass_Human_Config_Path[64];
	formatex(szClass_Human_Config_Path, charsmax(szClass_Human_Config_Path), "%s/%s.ini", ZPE_CLASS_HUMAN_SETTINGS_PATH, szReal_Name);

	new Array:aSounds = ArrayCreate(128, 1);
	new szSound[128];
	new iArraySize;

	for (new i = 0; i < _:HUMAN_SOUNDS; i++)
	{
		amx_load_setting_string_arr(szClass_Human_Config_Path, g_szSound_Section_Name, g_szZombie_Sound_Types[i], aSounds);

		iArraySize = ArraySize(aSounds);

		if (iArraySize > 0)
		{
			for (new j = 0; j < iArraySize; j++)
			{
				ArrayGetString(aSounds, j, szSound, charsmax(szSound));
				zp_class_human_register_sound(iClass_ID, HUMAN_SOUNDS:i, szSound);
			}

			ArrayClear(aSounds);
		}

		else
		{
			amx_save_setting_string(szClass_Human_Config_Path, g_szSound_Section_Name, g_szHuman_Sound_Types[i], g_szDefault_Human_Sounds[i]);
			zp_class_human_register_sound(iClass_ID, HUMAN_SOUNDS:i, g_szDefault_Human_Sounds[i]);
		}
	}

	ArrayDestroy(aSounds);
}
