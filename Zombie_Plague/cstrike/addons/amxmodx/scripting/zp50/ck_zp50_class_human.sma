/* AMX Mod X
*	[ZP] Class Human.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "class human"
#define VERSION "4.4.3.0"
#define AUTHOR "C&K Corporation"

#define ZP_HUMANCLASSES_FILE "zm_humanclasses.ini"

#define ZP_SETTINGS_FILE "zm_settings.ini"

#define MODEL_MAX_LENGTH 64

// Models
new g_Model_V_Knife_Human[MODEL_MAX_LENGTH] = "models/v_knife.mdl";

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_cs_maxspeed_api>
#include <ck_cs_weap_models_api>
#include <ck_zp50_kernel>
#include <ck_zp50_class_human_const>

#define HUMANS_DEFAULT_NAME "Human"
#define HUMANS_DEFAULT_DESCRIPTION "Default"
#define HUMANS_DEFAULT_HEALTH 100
#define HUMANS_DEFAULT_SPEED 1.0
#define HUMANS_DEFAULT_GRAVITY 1.0
#define HUMANS_DEFAULT_ARMOR 0

// For class list menu handlers
#define MENU_PAGE_CLASS(%0) g_Menu_Data[%0]

new g_Menu_Data[MAX_PLAYERS + 1];

new g_Human_Class[MAX_PLAYERS + 1];
new g_Human_Class_Next[MAX_PLAYERS + 1];
new g_Additional_Menu_Text[MAX_PLAYERS + 1];

enum _:TOTAL_FORWARDS
{
	FW_CLASS_SELECT_PRE = 0,
	FW_CLASS_SELECT_POST
};

new g_Forwards[TOTAL_FORWARDS];
new g_Forward_Result;

new g_Human_Class_Count;

new Array:g_aHuman_Class_Real_Name;
new Array:g_aHuman_Class_Name;
new Array:g_aHuman_Class_Description;
new Array:g_aHuman_Class_Health;
new Array:g_aHuman_Class_Speed;
new Array:g_aHuman_Class_Gravity;
new Array:g_aHuman_Class_Armor;
new Array:g_aHuman_Class_Models_File;
new Array:g_aHuman_Class_Models_Handle;

new g_pCvar_Human_Armor_Type;

new g_iBit_Alive;
new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	g_pCvar_Human_Armor_Type = register_cvar("zm_human_armor_type", "0");

	register_clcmd("say /hclass", "Cmd_Show_Menu_Humanclass");
	register_clcmd("say /class", "Cmd_Show_Menu_Humanclass");

	g_Forwards[FW_CLASS_SELECT_PRE] = CreateMultiForward("zp_fw_class_human_select_pre", ET_CONTINUE, FP_CELL, FP_CELL);
	g_Forwards[FW_CLASS_SELECT_POST] = CreateMultiForward("zp_fw_class_human_select_post", ET_CONTINUE, FP_CELL, FP_CELL);
}

public plugin_precache()
{
	// Load from external file, save if not found
	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V_KNIFE HUMAN", g_Model_V_Knife_Human, charsmax(g_Model_V_Knife_Human)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V_KNIFE HUMAN", g_Model_V_Knife_Human);
	}

	// Precache models
	precache_model(g_Model_V_Knife_Human);
}

public plugin_cfg()
{
	// No classes loaded, add default human class
	if (g_Human_Class_Count == 0)
	{
		ArrayPushString(g_aHuman_Class_Real_Name, HUMANS_DEFAULT_NAME);
		ArrayPushString(g_aHuman_Class_Name, HUMANS_DEFAULT_NAME);
		ArrayPushString(g_aHuman_Class_Description, HUMANS_DEFAULT_DESCRIPTION);
		ArrayPushCell(g_aHuman_Class_Health, HUMANS_DEFAULT_HEALTH);
		ArrayPushCell(g_aHuman_Class_Speed, HUMANS_DEFAULT_SPEED);
		ArrayPushCell(g_aHuman_Class_Gravity, HUMANS_DEFAULT_GRAVITY);
		ArrayPushCell(g_aHuman_Class_Armor, HUMANS_DEFAULT_ARMOR);
		ArrayPushCell(g_aHuman_Class_Models_File, false);
		ArrayPushCell(g_aHuman_Class_Models_Handle, Invalid_Array);

		g_Human_Class_Count++;
	}
}

public plugin_natives()
{
	register_library("ck_zp50_class_human");

	register_native("zp_class_human_get_current", "native_class_human_get_current");
	register_native("zp_class_human_get_next", "native_class_human_get_next");
	register_native("zp_class_human_set_next", "native_class_human_set_next");
	register_native("zp_class_human_register", "native_class_human_register");
	register_native("zp_class_human_get_id", "native_class_human_get_id");
	register_native("zp_class_human_get_name", "native_class_human_get_name");
	register_native("zp_class_human_get_description", "native_class_human_get_description");
	register_native("zp_class_human_get_count", "native_class_human_get_count");
	register_native("zp_class_human_show_menu", "native_class_human_show_menu");
	register_native("zp_class_human_menu_text_add", "native_class_human_menu_text_add");
	register_native("zp_class_human_get_real_name", "native_class_human_get_real_name");
	register_native("zp_class_human_register_model", "native_class_human_register_model");
	register_native("zp_class_human_get_max_health", "native_class_human_get_max_health");

	// Initialize dynamic arrays
	g_aHuman_Class_Real_Name = ArrayCreate(32, 1);
	g_aHuman_Class_Name = ArrayCreate(32, 1);
	g_aHuman_Class_Description = ArrayCreate(32, 1);
	g_aHuman_Class_Health = ArrayCreate(1, 1);
	g_aHuman_Class_Speed = ArrayCreate(1, 1);
	g_aHuman_Class_Gravity = ArrayCreate(1, 1);
	g_aHuman_Class_Armor = ArrayCreate(1, 1);
	g_aHuman_Class_Models_File = ArrayCreate(1, 1);
	g_aHuman_Class_Models_Handle = ArrayCreate(1, 1);
}

public Cmd_Show_Menu_Humanclass(iPlayer)
{
	if (!zp_core_is_zombie(iPlayer))
	{
		Show_Menu_Humanclass(iPlayer);
	}
}

public Show_Menu_Humanclass(iPlayer)
{
	static szMenu[256];
	static szName[64];
	static szDescription[65];
	static szTranskey[128];

	new iMenu_ID;
	new iItemdata[2];

	formatex(szMenu, charsmax(szMenu), "%L \r", iPlayer, "MENU_HCLASS");

	iMenu_ID = menu_create(szMenu, "Menu_Humanclass");

	for (new i = 0; i < g_Human_Class_Count; i++)
	{
		// Additional text to display
		g_Additional_Menu_Text[0] = 0;

		// Execute class select attempt forward
		ExecuteForward(g_Forwards[FW_CLASS_SELECT_PRE], g_Forward_Result, iPlayer, i);

		// Show class to player?
		if (g_Forward_Result >= ZP_CLASS_DONT_SHOW)
		{
			continue;
		}

		ArrayGetString(g_aHuman_Class_Name, i, szName, charsmax(szName));
		ArrayGetString(g_aHuman_Class_Description, i, szDescription, charsmax(szDescription));

		// ML support for class mame + description
		formatex(szTranskey, charsmax(szTranskey), "HUMANDESC %s", szName);

		if (GetLangTransKey(szTranskey) != TransKey_Bad)
		{
			formatex(szDescription, charsmax(szDescription), "%L", iPlayer, szTranskey);
		}

		formatex(szTranskey, charsmax(szTranskey), "HUMANNAME %s", szName);

		if (GetLangTransKey(szTranskey) != TransKey_Bad)
		{
			formatex(szName, charsmax(szName), "%L", iPlayer, szTranskey);
		}

		// Class available to player?
		if (g_Forward_Result >= ZP_CLASS_NOT_AVAILABLE)
		{
			formatex(szMenu, charsmax(szMenu), "\d %s %s %s", szName, szDescription, g_Additional_Menu_Text);
		}

		// Class is current class?
		else if (i == g_Human_Class_Next[iPlayer])
		{
			formatex(szMenu, charsmax(szMenu), "\r %s \y %s \w %s", szName, szDescription, g_Additional_Menu_Text);
		}

		else
		{
			formatex(szMenu, charsmax(szMenu), "%s \y %s \w %s", szName, szDescription, g_Additional_Menu_Text);
		}

		iItemdata[0] = i;
		iItemdata[1] = 0;

		menu_additem(iMenu_ID, szMenu, iItemdata);
	}

	// No classes to display?
	if (menu_items(iMenu_ID) <= 0)
	{
		zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "NO_CLASSES");

		menu_destroy(iMenu_ID);

		return;
	}

	// Back - Next - Exit
	formatex(szMenu, charsmax(szMenu), "%L", iPlayer, "MENU_BACK");
	menu_setprop(iMenu_ID, MPROP_BACKNAME, szMenu);

	formatex(szMenu, charsmax(szMenu), "%L", iPlayer, "MENU_NEXT");
	menu_setprop(iMenu_ID, MPROP_NEXTNAME, szMenu);

	formatex(szMenu, charsmax(szMenu), "%L", iPlayer, "MENU_EXIT");
	menu_setprop(iMenu_ID, MPROP_EXITNAME, szMenu);

	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_CLASS(iPlayer) = min(MENU_PAGE_CLASS(iPlayer), menu_pages(iMenu_ID) - 1);

	menu_display(iPlayer, iMenu_ID, MENU_PAGE_CLASS(iPlayer));
}

public Menu_Humanclass(iPlayer, iMenu_ID, iItem)
{
	// Menu was closed
	if (iItem == MENU_EXIT)
	{
		MENU_PAGE_CLASS(iPlayer) = 0;

		menu_destroy(iMenu_ID);

		return PLUGIN_HANDLED;
	}

	// Remember class menu page
	MENU_PAGE_CLASS(iPlayer) = iItem / 7;

	// Retrieve class index
	new iItemdata[2];
	new iDummy;
	new iIndex;

	menu_item_getinfo(iMenu_ID, iItem, iDummy, iItemdata, charsmax(iItemdata), _, _, iDummy);

	iIndex = iItemdata[0];

	// Execute class select attempt forward
	ExecuteForward(g_Forwards[FW_CLASS_SELECT_PRE], g_Forward_Result, iPlayer, iIndex);

	// Class available to player?
	if (g_Forward_Result >= ZP_CLASS_NOT_AVAILABLE)
	{
		menu_destroy(iMenu_ID);

		return PLUGIN_HANDLED;
	}

	// Make selected class next class for player
	g_Human_Class_Next[iPlayer] = iIndex;

	new szName[32];
	new szTranskey[64];

	new Float:fMax_Speed = Float:ArrayGetCell(g_aHuman_Class_Speed, g_Human_Class_Next[iPlayer]);

	ArrayGetString(g_aHuman_Class_Name, g_Human_Class_Next[iPlayer], szName, charsmax(szName));

	// ML support for class name
	formatex(szTranskey, charsmax(szTranskey), "HUMANNAME %s", szName);

	if (GetLangTransKey(szTranskey) != TransKey_Bad)
	{
		formatex(szName, charsmax(szName), "%L", iPlayer, szTranskey);
	}

	// Show selected human class
	zp_client_print_color(iPlayer, print_team_default, "%L: %s", iPlayer, "HUMAN_SELECT", szName);

	zp_client_print_color
	(
		iPlayer, print_team_default, "%L: %d %L: %d %L: %d %L: %.2fx",
		iPlayer, "ZOMBIE_ATTRIB1", ArrayGetCell(g_aHuman_Class_Health, g_Human_Class_Next[iPlayer]),
		iPlayer, "ZOMBIE_ATTRIB5", ArrayGetCell(g_aHuman_Class_Armor, g_Human_Class_Next[iPlayer]),
		iPlayer, "ZOMBIE_ATTRIB2", cs_maxspeed_display_value(fMax_Speed),
		iPlayer, "ZOMBIE_ATTRIB3", Float:ArrayGetCell(g_aHuman_Class_Gravity, g_Human_Class_Next[iPlayer])
	);

	// Execute class select post forward
	ExecuteForward(g_Forwards[FW_CLASS_SELECT_POST], g_Forward_Result, iPlayer, iIndex);

	menu_destroy(iMenu_ID);

	return PLUGIN_HANDLED;
}

public zp_fw_core_cure_post(iPlayer)
{
	// Show human class menu if they haven't chosen any (e.g. just connected)
	if (g_Human_Class_Next[iPlayer] == ZP_INVALID_HUMAN_CLASS)
	{
		if (g_Human_Class_Count > 1)
		{
			Show_Menu_Humanclass(iPlayer);
		}

		else // If only one class is registered, choose it automatically
		{
			g_Human_Class_Next[iPlayer] = 0;
		}
	}

	// Set selected human class. If none selected yet, use the first one
	g_Human_Class[iPlayer] = g_Human_Class_Next[iPlayer];

	if (g_Human_Class[iPlayer] == ZP_INVALID_HUMAN_CLASS)
	{
		g_Human_Class[iPlayer] = 0;
	}

	// Apply human attributes
	SET_USER_HEALTH(iPlayer, float(ArrayGetCell(g_aHuman_Class_Health, g_Human_Class[iPlayer])));

	if (get_pcvar_num(g_pCvar_Human_Armor_Type))
	{
		rg_set_user_armor(iPlayer, ArrayGetCell(g_aHuman_Class_Armor, g_Human_Class[iPlayer]), ARMOR_VESTHELM);
	}

	else
	{
		rg_set_user_armor(iPlayer, ArrayGetCell(g_aHuman_Class_Armor, g_Human_Class[iPlayer]), ARMOR_KEVLAR);
	}

	SET_USER_GRAVITY(iPlayer, Float:ArrayGetCell(g_aHuman_Class_Gravity, g_Human_Class[iPlayer]));
	cs_set_player_maxspeed_auto(iPlayer, Float:ArrayGetCell(g_aHuman_Class_Speed, g_Human_Class[iPlayer]));

	// Apply human player model
	new Array:aClass_Models = ArrayGetCell(g_aHuman_Class_Models_Handle, g_Human_Class[iPlayer]);

	if (aClass_Models != Invalid_Array)
	{
		new iIndex = random_num(0, ArraySize(aClass_Models) - 1);

		new szPlayer_Model[32];

		ArrayGetString(aClass_Models, iIndex, szPlayer_Model, charsmax(szPlayer_Model));

		rg_set_user_model(iPlayer, szPlayer_Model);
	}

	// Set custom knife model
	cs_set_player_view_model(iPlayer, CSW_KNIFE, g_Model_V_Knife_Human);
}

public zp_fw_core_infect(iPlayer, iAttacker)
{
	// Remove custom knife model
	cs_reset_player_view_model(iPlayer, CSW_KNIFE);
}

public native_class_human_get_current(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return ZP_INVALID_HUMAN_CLASS;
	}

	return g_Human_Class[iPlayer];
}

public native_class_human_get_next(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return ZP_INVALID_HUMAN_CLASS;
	}

	return g_Human_Class_Next[iPlayer];
}

public native_class_human_set_next(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	new iClass_ID = get_param(2);

	if (iClass_ID < 0 || iClass_ID >= g_Human_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid human class player (%d)", iClass_ID);

		return false;
	}

	g_Human_Class_Next[iPlayer] = iClass_ID;

	return true;
}

public native_class_human_get_max_health(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return -1;
	}

	new iClass_ID = get_param(2);

	if (iClass_ID < 0 || iClass_ID >= g_Human_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid human class player (%d)", iClass_ID);

		return -1;
	}

	return ArrayGetCell(g_aHuman_Class_Health, iClass_ID);
}

public native_class_human_register(iPlugin_ID, iNum_Params)
{
	new szName[32];

	get_string(1, szName, charsmax(szName));

	if (strlen(szName) == 0)
	{
		log_error(AMX_ERR_NATIVE, "Can't register human class with an empty name");

		return ZP_INVALID_HUMAN_CLASS;
	}

	new szHumanclass_Name[32];

	for (new i = 0; i < g_Human_Class_Count; i++)
	{
		ArrayGetString(g_aHuman_Class_Real_Name, i, szHumanclass_Name, charsmax(szHumanclass_Name));

		if (equali(szName, szHumanclass_Name))
		{
			log_error(AMX_ERR_NATIVE, "Human class already registered (%s)", szName);

			return ZP_INVALID_HUMAN_CLASS;
		}
	}

	// Load settings from human classes file
	new szReal_Name[32];

	copy(szReal_Name, charsmax(szReal_Name), szName);

	ArrayPushString(g_aHuman_Class_Real_Name, szReal_Name);

	// Name
	if (!amx_load_setting_string(ZP_HUMANCLASSES_FILE, szReal_Name, "NAME", szName, charsmax(szName)))
	{
		amx_save_setting_string(ZP_HUMANCLASSES_FILE, szReal_Name, "NAME", szName);
	}

	ArrayPushString(g_aHuman_Class_Name, szName);

	// Description
	new szDescription[32];

	get_string(2, szDescription, charsmax(szDescription));

	if (!amx_load_setting_string(ZP_HUMANCLASSES_FILE, szReal_Name, "INFO", szDescription, charsmax(szDescription)))
	{
		amx_save_setting_string(ZP_HUMANCLASSES_FILE, szReal_Name, "INFO", szDescription);
	}

	ArrayPushString(g_aHuman_Class_Description, szDescription);

	// Models
	new Array:aClass_Models = ArrayCreate(32, 1);

	amx_load_setting_string_arr(ZP_HUMANCLASSES_FILE, szReal_Name, "MODELS", aClass_Models);

	if (ArraySize(aClass_Models) > 0)
	{
		ArrayPushCell(g_aHuman_Class_Models_File, true);

		// Precache player models
		new szPlayer_Model[32];
		new szModel_Path[128];

		for (new i = 0; i < ArraySize(aClass_Models); i++)
		{
			ArrayGetString(aClass_Models, i, szPlayer_Model, charsmax(szPlayer_Model));

			formatex(szModel_Path, charsmax(szModel_Path), "models/player/%s/%s.mdl", szPlayer_Model, szPlayer_Model);

			precache_model(szModel_Path);
		}
	}

	else
	{
		ArrayPushCell(g_aHuman_Class_Models_File, false);

		ArrayDestroy(aClass_Models);

		amx_save_setting_string(ZP_HUMANCLASSES_FILE, szReal_Name, "MODELS", "");
	}

	ArrayPushCell(g_aHuman_Class_Models_Handle, aClass_Models);

	// Health
	new iHealth = get_param(3);

	if (!amx_load_setting_int(ZP_HUMANCLASSES_FILE, szReal_Name, "HEALTH", iHealth))
	{
		amx_save_setting_int(ZP_HUMANCLASSES_FILE, szReal_Name, "HEALTH", iHealth);
	}

	ArrayPushCell(g_aHuman_Class_Health, iHealth);

	// Armor
	new iArmor = get_param(4);

	if (!amx_load_setting_int(ZP_HUMANCLASSES_FILE, szReal_Name, "ARMOR", iArmor))
	{
		amx_save_setting_int(ZP_HUMANCLASSES_FILE, szReal_Name, "ARMOR", iArmor);
	}

	ArrayPushCell(g_aHuman_Class_Armor, iArmor);

	// Speed
	new Float:fSpeed = get_param_f(5);

	if (!amx_load_setting_float(ZP_HUMANCLASSES_FILE, szReal_Name, "SPEED", fSpeed))
	{
		amx_save_setting_float(ZP_HUMANCLASSES_FILE, szReal_Name, "SPEED", fSpeed);
	}

	ArrayPushCell(g_aHuman_Class_Speed, fSpeed);

	// Gravity
	new Float:fGravity = get_param_f(6);

	if (!amx_load_setting_float(ZP_HUMANCLASSES_FILE, szReal_Name, "GRAVITY", fGravity))
	{
		amx_save_setting_float(ZP_HUMANCLASSES_FILE, szReal_Name, "GRAVITY", fGravity);
	}

	ArrayPushCell(g_aHuman_Class_Gravity, fGravity);

	g_Human_Class_Count++;

	return g_Human_Class_Count - 1;
}

public native_class_human_register_model(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Human_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid human class player (%d)", iClass_ID);

		return false;
	}

	// Player models already loaded from file
	if (ArrayGetCell(g_aHuman_Class_Models_File, iClass_ID))
	{
		return true;
	}

	new szPlayer_Model[32];

	get_string(2, szPlayer_Model, charsmax(szPlayer_Model));

	new szModel_Path[128];

	formatex(szModel_Path, charsmax(szModel_Path), "models/player/%s/%s.mdl", szPlayer_Model, szPlayer_Model);

	precache_model(szModel_Path);

	new Array:aClass_Models = ArrayGetCell(g_aHuman_Class_Models_Handle, iClass_ID);

	// No models registered yet?
	if (aClass_Models == Invalid_Array)
	{
		aClass_Models = ArrayCreate(32, 1);

		ArraySetCell(g_aHuman_Class_Models_Handle, iClass_ID, aClass_Models);
	}

	ArrayPushString(aClass_Models, szPlayer_Model);

	// Save models to file
	new szReal_Name[32];

	ArrayGetString(g_aHuman_Class_Real_Name, iClass_ID, szReal_Name, charsmax(szReal_Name));

	amx_save_setting_string_arr(ZP_HUMANCLASSES_FILE, szReal_Name, "MODELS", aClass_Models);

	return true;
}

public native_class_human_get_id(iPlugin_ID, iNum_Params)
{
	new szReal_Name[32];

	get_string(1, szReal_Name, charsmax(szReal_Name));

	// Loop through every class
	new szHumanclass_Name[32];

	for (new i = 0; i < g_Human_Class_Count; i++)
	{
		ArrayGetString(g_aHuman_Class_Real_Name, i, szHumanclass_Name, charsmax(szHumanclass_Name));

		if (equali(szReal_Name, szHumanclass_Name))
		{
			return i;
		}
	}

	return ZP_INVALID_HUMAN_CLASS;
}

public native_class_human_get_name(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Human_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid human class player (%d)", iClass_ID);

		return false;
	}

	new szName[32];

	ArrayGetString(g_aHuman_Class_Name, iClass_ID, szName, charsmax(szName));

	new sLen = get_param(3);

	set_string(2, szName, sLen);

	return true;
}

public native_class_human_get_real_name(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Human_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid human class player (%d)", iClass_ID);

		return false;
	}

	new szReal_Name[32];

	ArrayGetString(g_aHuman_Class_Real_Name, iClass_ID, szReal_Name, charsmax(szReal_Name));

	new sLen = get_param(3);

	set_string(2, szReal_Name, sLen);

	return true;
}

public native_class_human_get_description(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Human_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid human class player (%d)", iClass_ID);

		return false;
	}

	new szDescription[32];

	ArrayGetString(g_aHuman_Class_Description, iClass_ID, szDescription, charsmax(szDescription));

	new sLen = get_param(3);

	set_string(2, szDescription, sLen);

	return true;
}

public native_class_human_get_count(iPlugin_ID, iNum_Params)
{
	return g_Human_Class_Count;
}

public native_class_human_show_menu(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	Show_Menu_Humanclass(iPlayer);

	return true;
}

public native_class_human_menu_text_add(iPlugin_ID, iNum_Params)
{
	static szText[32];

	get_string(1, szText, charsmax(szText));

	format(g_Additional_Menu_Text, charsmax(g_Additional_Menu_Text), "%s %s", g_Additional_Menu_Text, szText);
}

public client_putinserver(iPlayer)
{
	g_Human_Class[iPlayer] = ZP_INVALID_HUMAN_CLASS;
	g_Human_Class_Next[iPlayer] = ZP_INVALID_HUMAN_CLASS;

	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	// Reset remembered menu pages
	MENU_PAGE_CLASS(iPlayer) = 0;

	BIT_SUB(g_iBit_Alive, iPlayer);
	BIT_SUB(g_iBit_Connected, iPlayer);
}

public zp_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}