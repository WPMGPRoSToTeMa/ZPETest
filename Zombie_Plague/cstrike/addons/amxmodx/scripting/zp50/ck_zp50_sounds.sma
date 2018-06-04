/* AMX Mod X
*	[ZP] Class Zombie.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "class sounds"
#define VERSION "4.3.4.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <ck_zp50_class_zombie>
#include <ck_zp50_sounds_api>
#include <amx_settings_api>

#define ZP_CLASS_SETTINGS_PATH "classes/zombie"


new const g_szSound_Section_Name[] = "Sounds";

new const g_szZombie_Sound_Types[][] = 
{
	"PAIN",
	"DIE",
	"FALL",
	"MISS SLASH",
	"MISS WALL",
	"HIT NORMAL",
	"HIT STAB",
	"IDLE",
	"INFECT",
	"FLAME"
};

new const g_szDefault_Zombie_Sounds[][] = 
{
	"zombie_plague/zombie_pain1.wav",
	"zombie_plague/zombie_die1.wav",
	"zombie_plague/zombie_fall1.wav",
	"weapons/knife_slash1.wav",
	"weapons/knife_hitwall1.wav",
	"weapons/knife_hit1.wav",
	"weapons/knife_stab.wav",
	"zombie_plague/zombie_brains1.wav",
	"zombie_plague/zombie_sounds/zombie_infect0.wav",
	"zombie_plague/zombie_sounds/zombie_burn0.wav"
};

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public zp_fw_class_zombie_register_post(classid)
{
	new szReal_Name[32];
	zp_class_zombie_get_real_name(classid, szReal_Name, charsmax(szReal_Name));
	
	new szClass_Config_Path[64];
	formatex(szClass_Config_Path, charsmax(szClass_Config_Path), "%s/%s.ini", ZP_CLASS_SETTINGS_PATH, szReal_Name);
	
	new Array:aSounds = ArrayCreate(64, 1);
	new szSound[64];
	new iArraySize;
	
	for(new i = 0; i < sizeof g_szZombie_Sound_Types; i++)
	{
		amx_load_setting_string_arr(szClass_Config_Path, g_szSound_Section_Name, g_szZombie_Sound_Types[i], aSounds);
		
		iArraySize = ArraySize(aSounds);
		
		if (iArraySize > 0)
		{
			for (new i = 0; i < iArraySize; i++)
			{
				ArrayGetString(aSounds, i, szSound, charsmax(szSound));
				zp_class_zombie_register_sound(classid, ZOMBIE_SOUNDS:i, szSound);
			}
			
			ArrayClear(aSounds);
		}
		
		else
		{
			amx_save_setting_string(szClass_Config_Path, g_szSound_Section_Name, g_szZombie_Sound_Types[i], g_szDefault_Zombie_Sounds[i]);
			zp_class_zombie_register_sound(classid, ZOMBIE_SOUNDS:i, g_szDefault_Zombie_Sounds[i]);
		}
	}
	
	ArrayDestroy(aSounds);
}