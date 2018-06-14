#include <amxmodx>
#include <fakemeta>
#include <ck_zp50_kernel>
#include <ck_zp50_class_zombie>
#include <ck_zp50_class_human>
#include <amx_settings_api>

#define PLUGIN "class weaponlist"
#define VERSION "1.0"
#define AUTHOR "C&K Corporation"

#define ZP_ZOMBIE_CLASS_SETTINGS_PATH "ZPE/classes/zombie"
#define ZP_HUMAN_CLASS_SETTINGS_PATH "ZPE/classes/human"

#define ZP_SETTING_SECTION_NAME "Settings"

#define MSG_WEAPONLIST 78

#define WRITE_BYTE(%0) write_byte(%0)
#define WRITE_STRING(%0) write_string(%0)
#define MESSAGE_END() message_end()
#define MESSAGE_BEGIN(%0,%1,%2,%3) engfunc(EngFunc_MessageBegin, %0, %1, %2, %3)

new Array:g_aZombie_WeaponList;
new Array:g_aHuman_WeaponList;

new g_sWeapon_List_Data[8];

public plugin_precache()
{
	register_message(MSG_WEAPONLIST, "Message_Hook_WeaponList");
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public zp_fw_class_zombie_register_post(classid)
{
	if (g_aZombie_WeaponList == Invalid_Array)
	{
		g_aZombie_WeaponList = ArrayCreate(64, 1);
	}
	
	new szReal_Name[32];
	zp_class_zombie_get_real_name(classid, szReal_Name, charsmax(szReal_Name));
	
	new szClass_Config_Path[64];
	formatex(szClass_Config_Path, charsmax(szClass_Config_Path), "%s/%s.ini", ZP_ZOMBIE_CLASS_SETTINGS_PATH, szReal_Name);
	
	new Array:aWeaponList = ArrayCreate(64, 1);
	amx_load_setting_string_arr(szClass_Config_Path, ZP_SETTING_SECTION_NAME, "WEAPONLIST", aWeaponList);
	new iArray_Size = ArraySize(aWeaponList);
	
	new szFile_Name[16] = "";
	
	if (iArray_Size > 0)
	{
		new szPath[32];
		ArrayGetString(aWeaponList, 0, szPath, charsmax(szPath));
		precache_generic(szPath);
		
		Get_FileName_From_Path(szPath, szFile_Name, charsmax(szFile_Name));
		
		register_clcmd(szFile_Name, "Weapon_Hook");
		
		for (new i = 1; i < iArray_Size; i++)
		{
			ArrayGetString(aWeaponList, i, szPath, charsmax(szPath));
			precache_generic(szPath);
		}
	}
	
	else
	{
		amx_save_setting_string(szClass_Config_Path, ZP_SETTING_SECTION_NAME, "WEAPONLIST", "");
	}
	
	ArrayPushString(g_aZombie_WeaponList, szFile_Name);
	ArrayDestroy(aWeaponList);
}

public zp_fw_class_human_register_post(classid)
{
	if (g_aHuman_WeaponList == Invalid_Array)
	{
		g_aHuman_WeaponList = ArrayCreate(32, 1);
	}
	
	new szReal_Name[32];
	zp_class_human_get_real_name(classid, szReal_Name, charsmax(szReal_Name));
	
	new szClass_Config_Path[64];
	formatex(szClass_Config_Path, charsmax(szClass_Config_Path), "%s/%s.ini", ZP_HUMAN_CLASS_SETTINGS_PATH, szReal_Name);
	
	new Array:aWeaponList = ArrayCreate(32, 1);
	amx_load_setting_string_arr(szClass_Config_Path, ZP_SETTING_SECTION_NAME, "WEAPONLIST", aWeaponList);
	new iArray_Size = ArraySize(aWeaponList);
	
	new szFile_Name[16] = "";
	
	if (iArray_Size > 0)
	{
		new szPath[32];
		ArrayGetString(aWeaponList, 0, szPath, charsmax(szPath));
		precache_generic(szPath);
		
		Get_FileName_From_Path(szPath, szFile_Name, charsmax(szFile_Name));
		
		register_clcmd(szFile_Name, "Weapon_Hook");
		
		for (new i = 1; i < iArray_Size; i++)
		{
			ArrayGetString(aWeaponList, i, szPath, charsmax(szPath));
			precache_generic(szPath);
		}
	}
	
	else
	{
		amx_save_setting_string(szClass_Config_Path, ZP_SETTING_SECTION_NAME, "WEAPONLIST", "");
	}
	
	ArrayPushString(g_aHuman_WeaponList, szFile_Name);
	ArrayDestroy(aWeaponList);
}

public zp_fw_core_infect_post(iPlayer)
{
	new szWeaponList[32];
	ArrayGetString(g_aZombie_WeaponList, zp_class_zombie_get_current(iPlayer), szWeaponList, charsmax(szWeaponList));
	
	if (szWeaponList[0])
	{
		Send_Weapon_List_Update(iPlayer, szWeaponList);
	}
}

public zp_fw_core_cure_post(iPlayer)
{
	Send_Weapon_List_Update(iPlayer, "weapon_knife");
	
	new szWeaponList[32];
	ArrayGetString(g_aHuman_WeaponList, zp_class_human_get_current(iPlayer), szWeaponList, charsmax(szWeaponList));
	
	if (szWeaponList[0])
	{
		Send_Weapon_List_Update(iPlayer, szWeaponList);
	}
}

public Message_Hook_WeaponList(iMessage_ID, iMessage_Dest, iMessage_Entity)
{
	new szWeapon_Name[32];

	get_msg_arg_string(1, szWeapon_Name, charsmax(szWeapon_Name));

	if (!strcmp(szWeapon_Name, "weapon_knife"))
	{
		for (new i, a = sizeof g_sWeapon_List_Data; i < a; i++)
		{
			g_sWeapon_List_Data[i] = get_msg_arg_int(i + 2);
		}
	}
}

public Weapon_Hook(iPlayer)
{
	engclient_cmd(iPlayer, "weapon_knife");
	
	return PLUGIN_HANDLED;
}

stock Send_Weapon_List_Update(iPlayer, const szWeapon_Name[32])
{
	MESSAGE_BEGIN(MSG_ONE, MSG_WEAPONLIST, { 0.0, 0.0, 0.0 }, iPlayer);
	WRITE_STRING(szWeapon_Name);
	WRITE_BYTE(g_sWeapon_List_Data[0]);
	WRITE_BYTE(g_sWeapon_List_Data[1]);
	WRITE_BYTE(g_sWeapon_List_Data[2]);
	WRITE_BYTE(g_sWeapon_List_Data[3]);
	WRITE_BYTE(g_sWeapon_List_Data[4]);
	WRITE_BYTE(g_sWeapon_List_Data[5]);
	WRITE_BYTE(g_sWeapon_List_Data[6]);
	WRITE_BYTE(g_sWeapon_List_Data[7]);
	MESSAGE_END();
}

stock Get_FileName_From_Path(szPath[], szFile_Name[], iSize)
{
	new iPath_Size = strlen(szPath);
	
	if (iPath_Size == 0)
	{
		return;
	}
	
	new iSlash_Index = -1;
	
	for (new i = iPath_Size - 1; i >= 0; i--)
	{
		if (szPath[i] == '/')
		{
			iSlash_Index = i;
			
			break;
		}
	}
	
	formatex(szFile_Name, iSize, "%s", szPath[iSlash_Index != -1 ? iSlash_Index + 1 : 0]);
	copyc(szFile_Name, iSize, szFile_Name, '.');
}