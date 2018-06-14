#include <amxmodx>
#include <ck_zp50_class_zombie>
#include <ck_zp50_class_human>
#include <amx_settings_api>

#define PLUGIN "class flags"
#define VERSION "1.0"
#define AUTHOR "C&K Corporation"

#define ZP_ZOMBIE_CLASS_SETTINGS_PATH "ZPE/classes/zombie"
#define ZP_HUMAN_CLASS_SETTINGS_PATH "ZPE/classes/human"

#define ZP_SETTING_SECTION_NAME "Settings"

new Array:g_aZombie_Flags;
new Array:g_aHuman_Flags;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public zp_fw_class_zombie_register_post(classid)
{
	if (g_aZombie_Flags == Invalid_Array)
	{
		g_aZombie_Flags = ArrayCreate(1, 1);
	}	
	
	new szReal_Name[32];
	zp_class_zombie_get_real_name(classid, szReal_Name, charsmax(szReal_Name));
	
	new szClass_Config_Path[64];
	formatex(szClass_Config_Path, charsmax(szClass_Config_Path), "%s/%s.ini", ZP_ZOMBIE_CLASS_SETTINGS_PATH, szReal_Name);
	
	new szFlags[32];
	szFlags[0] = 'z';
	
	if (!amx_load_setting_string(szClass_Config_Path, ZP_SETTING_SECTION_NAME, "FLAGS", szFlags, charsmax(szFlags)))
	{
		amx_save_setting_string(szClass_Config_Path, ZP_SETTING_SECTION_NAME, "FLAGS", szFlags);
	}
	
	ArrayPushCell(g_aZombie_Flags, read_flags(szFlags));
}

public zp_fw_class_zombie_select_pre(id, classid)
{
	if (get_user_flags(id) & ArrayGetCell(g_aZombie_Flags, classid))
	{
		return ZP_CLASS_AVAILABLE;
	}
	
	return ZP_CLASS_NOT_AVAILABLE;
}

public zp_fw_class_human_register_post(classid)
{
	if (g_aHuman_Flags == Invalid_Array)
	{
		g_aHuman_Flags = ArrayCreate(1, 1);
	}	
	
	new szReal_Name[32];
	zp_class_human_get_real_name(classid, szReal_Name, charsmax(szReal_Name));
	
	new szClass_Config_Path[64];
	formatex(szClass_Config_Path, charsmax(szClass_Config_Path), "%s/%s.ini", ZP_HUMAN_CLASS_SETTINGS_PATH, szReal_Name);
	
	new szFlags[32];
	szFlags[0] = 'z';
	
	if (!amx_load_setting_string(szClass_Config_Path, ZP_SETTING_SECTION_NAME, "FLAGS", szFlags, charsmax(szFlags)))
	{
		amx_save_setting_string(szClass_Config_Path, ZP_SETTING_SECTION_NAME, "FLAGS", szFlags);
	}
	
	ArrayPushCell(g_aHuman_Flags, read_flags(szFlags));
}

public zp_fw_class_human_select_pre(id, classid)
{
	if (get_user_flags(id) & ArrayGetCell(g_aHuman_Flags, classid))
	{
		return ZP_CLASS_AVAILABLE; 
	}
	
	return ZP_CLASS_NOT_AVAILABLE;
}