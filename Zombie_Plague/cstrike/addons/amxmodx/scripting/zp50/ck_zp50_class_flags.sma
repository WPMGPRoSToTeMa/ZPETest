/* AMX Mod X
*	[ZPE] Class Flags.
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

#include <amxmodx>
#include <amx_settings_api>
#include <ck_zp50_class_zombie>
#include <ck_zp50_class_human>

#define PLUGIN "class flags"
#define VERSION "1.0.0"
#define AUTHOR "C&K Corporation"

#define ZPE_CLASS_ZOMBIE_SETTINGS_PATH "ZPE/classes/zombie"
#define ZPE_CLASS_HUMAN_SETTINGS_PATH "ZPE/classes/human"

#define ZPE_SETTING_SECTION_NAME "Settings"

new Array:g_aZombie_Flags;
new Array:g_aHuman_Flags;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public zp_fw_class_zombie_register_post(iClass_ID)
{
	if (g_aZombie_Flags == Invalid_Array)
	{
		g_aZombie_Flags = ArrayCreate(1, 1);
	}

	new szReal_Name[32];
	zp_class_zombie_get_real_name(iClass_ID, szReal_Name, charsmax(szReal_Name));

	new szClass_Config_Path[64];
	formatex(szClass_Config_Path, charsmax(szClass_Config_Path), "%s/%s.ini", ZPE_CLASS_ZOMBIE_SETTINGS_PATH, szReal_Name);

	new szFlags[32];
	szFlags[0] = 'z';

	if (!amx_load_setting_string(szClass_Config_Path, ZPE_SETTING_SECTION_NAME, "FLAGS", szFlags, charsmax(szFlags)))
	{
		amx_save_setting_string(szClass_Config_Path, ZPE_SETTING_SECTION_NAME, "FLAGS", szFlags);
	}

	ArrayPushCell(g_aZombie_Flags, read_flags(szFlags));
}

public zp_fw_class_zombie_select_pre(iPlayer, iClass_ID)
{
	if (get_user_flags(iPlayer) & ArrayGetCell(g_aZombie_Flags, iClass_ID))
	{
		return ZP_CLASS_AVAILABLE;
	}

	return ZP_CLASS_NOT_AVAILABLE;
}

public zp_fw_class_human_register_post(iClass_ID)
{
	if (g_aHuman_Flags == Invalid_Array)
	{
		g_aHuman_Flags = ArrayCreate(1, 1);
	}

	new szReal_Name[32];
	zp_class_human_get_real_name(iClass_ID, szReal_Name, charsmax(szReal_Name));

	new szClass_Config_Path[64];
	formatex(szClass_Config_Path, charsmax(szClass_Config_Path), "%s/%s.ini", ZPE_CLASS_HUMAN_SETTINGS_PATH, szReal_Name);

	new szFlags[32];
	szFlags[0] = 'z';

	if (!amx_load_setting_string(szClass_Config_Path, ZPE_SETTING_SECTION_NAME, "FLAGS", szFlags, charsmax(szFlags)))
	{
		amx_save_setting_string(szClass_Config_Path, ZPE_SETTING_SECTION_NAME, "FLAGS", szFlags);
	}

	ArrayPushCell(g_aHuman_Flags, read_flags(szFlags));
}

public zp_fw_class_human_select_pre(iPlayer, iClass_ID)
{
	if (get_user_flags(iPlayer) & ArrayGetCell(g_aHuman_Flags, iClass_ID))
	{
		return ZP_CLASS_AVAILABLE;
	}

	return ZP_CLASS_NOT_AVAILABLE;
}