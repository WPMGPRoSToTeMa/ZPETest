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

#define PLUGIN "class zombie"
#define VERSION "4.3.4.0"
#define AUTHOR "C&K Corporation"

#define ZP_ZOMBIECLASSES_FILE "zm_zombieclasses.ini"

#include <amxmodx>
#include <cs_util>
#include <fun>
#include <amx_settings_api>
#include <ck_cs_maxspeed_api>
#include <ck_cs_weap_models_api>
#include <ck_cs_weap_restrict_api>
#include <ck_zp50_kernel>
#include <ck_zp50_class_zombie_const>

// For class list menu handlers
#define MENU_PAGE_CLASS(%0) g_Menu_Data[%0]

// Allowed weapons for zombies
const ZOMBIE_ALLOWED_WEAPONS_BITSUM = (1 << CSW_KNIFE) | (1 << CSW_HEGRENADE) | (1 << CSW_FLASHBANG) | (1 << CSW_SMOKEGRENADE) | (1 << CSW_C4);

#define ZOMBIE_DEFAULT_ALLOWED_WEAPON CSW_KNIFE

enum _:TOTAL_FORWARDS
{
	FW_CLASS_SELECT_PRE = 0,
	FW_CLASS_SELECT_POST
};

new g_Zombie_Class[MAX_PLAYERS + 1];
new g_Zombie_Class_Next[MAX_PLAYERS + 1];

new g_Additional_Menu_Text[MAX_PLAYERS + 1];

new g_Menu_Data[MAX_PLAYERS + 1];

new Array:g_aZombie_Class_Real_Name;
new Array:g_aZombie_Class_Name;
new Array:g_aZombie_Class_Description;
new Array:g_aZombie_Class_Health;
new Array:g_aZombie_Class_Speed;
new Array:g_aZombie_Class_Gravity;
new Array:g_aZombie_Class_Knockback;
new Array:g_aZombie_Class_Models_Handle;
new Array:g_aZombie_Class_Claws_Handle;

new g_Forwards[TOTAL_FORWARDS];
new g_Forward_Result;

new g_Zombie_Class_Count;

new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /zclass", "Show_Menu_Zombieclass");
	register_clcmd("say /class", "Show_Class_Menu");

	g_Forwards[FW_CLASS_SELECT_PRE] = CreateMultiForward("zp_fw_class_zombie_select_pre", ET_CONTINUE, FP_CELL, FP_CELL);
	g_Forwards[FW_CLASS_SELECT_POST] = CreateMultiForward("zp_fw_class_zombie_select_post", ET_CONTINUE, FP_CELL, FP_CELL);
}

public plugin_natives()
{
	register_library("ck_zp50_class_zombie");

	register_native("zp_class_zombie_get_current", "native_class_zombie_get_current");
	register_native("zp_class_zombie_get_next", "native_class_zombie_get_next");
	register_native("zp_class_zombie_set_next", "native_class_zombie_set_next");
	register_native("zp_class_zombie_register", "native_class_zombie_register");
	register_native("zp_class_zombie_register_kb", "native_class_zombie_register_kb");
	register_native("zp_class_zombie_get_id", "native_class_zombie_get_id");
	register_native("zp_class_zombie_get_name", "native_class_zombie_get_name");
	register_native("zp_class_zombie_get_description", "native_class_zombie_get_description");
	register_native("zp_class_zombie_get_kb", "native_class_zombie_get_kb");
	register_native("zp_class_zombie_get_count", "native_class_zombie_get_count");
	register_native("zp_class_zombie_show_menu", "native_class_zombie_show_menu");
	register_native("zp_class_zombie_get_max_health", "native_class_zombie_get_max_health");
	register_native("zp_class_zombie_register_model", "native_class_zombie_register_model");
	register_native("zp_class_zombie_register_claw", "native_class_zombie_register_claw");
	register_native("zp_class_zombie_get_real_name", "native_class_zombie_get_real_name");
	register_native("zp_class_zombie_menu_text_add", "native_class_zombie_menu_text_add");

	// Initialize dynamic arrays
	g_aZombie_Class_Real_Name = ArrayCreate(32, 1);
	g_aZombie_Class_Name = ArrayCreate(32, 1);
	g_aZombie_Class_Description = ArrayCreate(32, 1);
	g_aZombie_Class_Health = ArrayCreate(1, 1);
	g_aZombie_Class_Speed = ArrayCreate(1, 1);
	g_aZombie_Class_Gravity = ArrayCreate(1, 1);
	g_aZombie_Class_Knockback = ArrayCreate(1, 1);
	g_aZombie_Class_Models_Handle = ArrayCreate(1, 1);
	g_aZombie_Class_Claws_Handle = ArrayCreate(1, 1);
}

public Show_Class_Menu(iPlayer)
{
	if (zp_core_is_zombie(iPlayer))
	{
		Show_Menu_Zombieclass(iPlayer);
	}
}

public Show_Menu_Zombieclass(iPlayer)
{
	static szMenu[128];
	static szName[32];
	static szDescription[32];
	static szTranskey[64];

	new iMenu_ID;
	new iItemdata[2];

	formatex(szMenu, charsmax(szMenu), "%L \r", iPlayer, "MENU_ZCLASS");

	iMenu_ID = menu_create(szMenu, "Menu_Zombieclass");

	for (new i = 0; i < g_Zombie_Class_Count; i++)
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

		ArrayGetString(g_aZombie_Class_Name, i, szName, charsmax(szName));
		ArrayGetString(g_aZombie_Class_Description, i, szDescription, charsmax(szDescription));

		// ML support for class name + description
		formatex(szTranskey, charsmax(szTranskey), "ZOMBIEDESC %s", szName);

		if (GetLangTransKey(szTranskey) != TransKey_Bad)
		{
			formatex(szDescription, charsmax(szDescription), "%L", iPlayer, szTranskey);
		}

		formatex(szTranskey, charsmax(szTranskey), "ZOMBIENAME %s", szName);

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
		else if (i == g_Zombie_Class_Next[iPlayer])
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

public Menu_Zombieclass(iPlayer, iMenu_ID, iItem)
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
	g_Zombie_Class_Next[iPlayer] = iIndex;

	new szName[32];
	new szTranskey[64];

	new Float:fMax_Speed = Float:ArrayGetCell(g_aZombie_Class_Speed, g_Zombie_Class_Next[iPlayer]);

	ArrayGetString(g_aZombie_Class_Name, g_Zombie_Class_Next[iPlayer], szName, charsmax(szName));

	// ML support for class name
	formatex(szTranskey, charsmax(szTranskey), "ZOMBIENAME %s", szName);

	if (GetLangTransKey(szTranskey) != TransKey_Bad)
	{
		formatex(szName, charsmax(szName), "%L", iPlayer, szTranskey);
	}

	// Show selected zombie class
	zp_client_print_color(iPlayer, print_team_default, "%L: %s", iPlayer, "ZOMBIE_SELECT", szName);

	zp_client_print_color
	(
		iPlayer, print_team_default, "%L: %d %L: %d %L: %.2fx %L %.2fx",
		iPlayer, "ZOMBIE_ATTRIB1", ArrayGetCell(g_aZombie_Class_Health, g_Zombie_Class_Next[iPlayer]),
		iPlayer, "ZOMBIE_ATTRIB2", cs_maxspeed_display_value(fMax_Speed),
		iPlayer, "ZOMBIE_ATTRIB3", Float:ArrayGetCell(g_aZombie_Class_Gravity, g_Zombie_Class_Next[iPlayer]),
		iPlayer, "ZOMBIE_ATTRIB4", Float:ArrayGetCell(g_aZombie_Class_Knockback, g_Zombie_Class_Next[iPlayer])
	);

	// Execute class select post forward
	ExecuteForward(g_Forwards[FW_CLASS_SELECT_POST], g_Forward_Result, iPlayer, iIndex);

	menu_destroy(iMenu_ID);

	return PLUGIN_HANDLED;
}

public zp_fw_core_infect_post(iPlayer)
{
	// Show zombie class menu if they haven't chosen any (e.g. just connected)
	if (g_Zombie_Class_Next[iPlayer] == ZP_INVALID_ZOMBIE_CLASS)
	{
		Show_Menu_Zombieclass(iPlayer);
	}

	// Set selected zombie class. If none selected yet, use the first one
	g_Zombie_Class[iPlayer] = g_Zombie_Class_Next[iPlayer];

	if (g_Zombie_Class[iPlayer] == ZP_INVALID_ZOMBIE_CLASS)
	{
		g_Zombie_Class[iPlayer] = 0;
	}

	// Apply zombie attributes
	set_user_health(iPlayer, ArrayGetCell(g_aZombie_Class_Health, g_Zombie_Class[iPlayer]));
	SET_USER_GRAVITY(iPlayer, Float:ArrayGetCell(g_aZombie_Class_Gravity, g_Zombie_Class[iPlayer]));
	cs_set_player_maxspeed_auto(iPlayer, Float:ArrayGetCell(g_aZombie_Class_Speed, g_Zombie_Class[iPlayer]));

	// Apply zombie player model
	new Array:aClass_Models = ArrayGetCell(g_aZombie_Class_Models_Handle, g_Zombie_Class[iPlayer]);

	if (aClass_Models != Invalid_Array)
	{
		new iIndex = random(ArraySize(aClass_Models));

		new szPlayer_Model[32];

		ArrayGetString(aClass_Models, iIndex, szPlayer_Model, charsmax(szPlayer_Model));

		rg_set_user_model(iPlayer, szPlayer_Model);
	}

	// Apply zombie claw model
	new szClaw_Model[64];

	new Array:aClass_Claws = ArrayGetCell(g_aZombie_Class_Claws_Handle, g_Zombie_Class[iPlayer]);

	if (aClass_Claws != Invalid_Array)
	{
		new iIndex = random(ArraySize(aClass_Claws));

		ArrayGetString(aClass_Claws, iIndex, szClaw_Model, charsmax(szClaw_Model));

		cs_set_player_view_model(iPlayer, CSW_KNIFE, szClaw_Model);
	}

	cs_set_player_weap_model(iPlayer, CSW_KNIFE, "");

	// Apply weapon restrictions for zombies
	cs_set_player_weap_restrict(iPlayer, true, ZOMBIE_ALLOWED_WEAPONS_BITSUM, ZOMBIE_DEFAULT_ALLOWED_WEAPON);
}

public zp_fw_core_cure(iPlayer)
{
	// Remove zombie claw models
	cs_reset_player_view_model(iPlayer, CSW_KNIFE);
	cs_reset_player_weap_model(iPlayer, CSW_KNIFE);

	// Remove zombie weapon restrictions
	cs_set_player_weap_restrict(iPlayer, false);
}

public native_class_zombie_get_current(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (!is_user_connected(iPlayer)) // TODO: use bit = invalid player.
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return ZP_INVALID_ZOMBIE_CLASS;
	}

	return g_Zombie_Class[iPlayer];
}

public native_class_zombie_get_next(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return ZP_INVALID_ZOMBIE_CLASS;
	}

	return g_Zombie_Class_Next[iPlayer];
}

public native_class_zombie_set_next(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	new iClass_ID = get_param(2);

	if (iClass_ID < 0 || iClass_ID >= g_Zombie_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid zombie class player (%d)", iClass_ID);

		return false;
	}

	g_Zombie_Class_Next[iPlayer] = iClass_ID;

	return true;
}

public native_class_zombie_get_max_health(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return -1;
	}

	new iClass_ID = get_param(2);

	if (iClass_ID < 0 || iClass_ID >= g_Zombie_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid zombie class player (%d)", iClass_ID);

		return -1;
	}

	return ArrayGetCell(g_aZombie_Class_Health, iClass_ID);
}

public native_class_zombie_register(iPlugin_ID, iNum_Params)
{
	new szName[32];

	get_string(1, szName, charsmax(szName));

	if (strlen(szName) == 0)
	{
		log_error(AMX_ERR_NATIVE, "Can't register zombie class with an empty name");

		return ZP_INVALID_ZOMBIE_CLASS;
	}

	new szZombieclass_Name[32];

	for (new i = 0; i < g_Zombie_Class_Count; i++)
	{
		ArrayGetString(g_aZombie_Class_Real_Name, i, szZombieclass_Name, charsmax(szZombieclass_Name));

		if (equali(szName, szZombieclass_Name))
		{
			log_error(AMX_ERR_NATIVE, "Zombie class already registered (%s)", szZombieclass_Name);

			return ZP_INVALID_ZOMBIE_CLASS;
		}
	}

	// Load settings from zombie classes file
	new szReal_Name[32];

	copy(szReal_Name, charsmax(szReal_Name), szName);

	ArrayPushString(g_aZombie_Class_Real_Name, szReal_Name);

	// Name
	if (!amx_load_setting_string(ZP_ZOMBIECLASSES_FILE, szReal_Name, "NAME", szName, charsmax(szName)))
	{
		amx_save_setting_string(ZP_ZOMBIECLASSES_FILE, szReal_Name, "NAME", szName);
	}

	ArrayPushString(g_aZombie_Class_Name, szName);

	// Description
	new szDescription[32];

	get_string(2, szDescription, charsmax(szDescription));

	if (!amx_load_setting_string(ZP_ZOMBIECLASSES_FILE, szReal_Name, "INFO", szDescription, charsmax(szDescription)))
	{
		amx_save_setting_string(ZP_ZOMBIECLASSES_FILE, szReal_Name, "INFO", szDescription);
	}

	ArrayPushString(g_aZombie_Class_Description, szDescription);

	// Models
	new Array:aClass_Models = ArrayCreate(32, 1);

	amx_load_setting_string_arr(ZP_ZOMBIECLASSES_FILE, szReal_Name, "MODELS", aClass_Models);

	ArrayPushCell(g_aZombie_Class_Models_Handle, aClass_Models);

	// Claw models
	new Array:aClass_Claws = ArrayCreate(64, 1);

	amx_load_setting_string_arr(ZP_ZOMBIECLASSES_FILE, szReal_Name, "CLAWMODEL", aClass_Claws)

	ArrayPushCell(g_aZombie_Class_Claws_Handle, aClass_Claws);

	// Health
	new iHealth = get_param(3);

	if (!amx_load_setting_int(ZP_ZOMBIECLASSES_FILE, szReal_Name, "HEALTH", iHealth))
	{
		amx_save_setting_int(ZP_ZOMBIECLASSES_FILE, szReal_Name, "HEALTH", iHealth);
	}

	ArrayPushCell(g_aZombie_Class_Health, iHealth);

	// Speed
	new Float:fSpeed = get_param_f(4);

	if (!amx_load_setting_float(ZP_ZOMBIECLASSES_FILE, szReal_Name, "SPEED", fSpeed))
	{
		amx_save_setting_float(ZP_ZOMBIECLASSES_FILE, szReal_Name, "SPEED", fSpeed);
	}

	ArrayPushCell(g_aZombie_Class_Speed, fSpeed);

	// Gravity
	new Float:fGravity = get_param_f(5);

	if (!amx_load_setting_float(ZP_ZOMBIECLASSES_FILE, szReal_Name, "GRAVITY", fGravity))
	{
		amx_save_setting_float(ZP_ZOMBIECLASSES_FILE, szReal_Name, "GRAVITY", fGravity);
	}

	ArrayPushCell(g_aZombie_Class_Gravity, fGravity);

	// Knockback
	amx_save_setting_float(ZP_ZOMBIECLASSES_FILE, szReal_Name, "KNOCKBACK", 1.0);

	ArrayPushCell(g_aZombie_Class_Knockback, 1.0);

	g_Zombie_Class_Count++;

	return g_Zombie_Class_Count - 1;
}

public native_class_zombie_register_model(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Zombie_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid zombie class player (%d)", iClass_ID);

		return false;
	}

	new szPlayer_Model[32];

	get_string(2, szPlayer_Model, charsmax(szPlayer_Model));

	new szModel_Path[128];

	formatex(szModel_Path, charsmax(szModel_Path), "models/player/%s/%s.mdl", szPlayer_Model, szPlayer_Model);

	precache_model(szModel_Path);

	new Array:aClass_Models = ArrayGetCell(g_aZombie_Class_Models_Handle, iClass_ID);

	// No models registered yet?
	if (aClass_Models == Invalid_Array)
	{
		aClass_Models = ArrayCreate(32, 1);

		ArraySetCell(g_aZombie_Class_Models_Handle, iClass_ID, aClass_Models);
	}

	ArrayPushString(aClass_Models, szPlayer_Model);

	// Save models to file
	new szReal_Name[32];

	ArrayGetString(g_aZombie_Class_Real_Name, iClass_ID, szReal_Name, charsmax(szReal_Name));

	amx_save_setting_string_arr(ZP_ZOMBIECLASSES_FILE, szReal_Name, "MODELS", aClass_Models);

	return true;
}

public native_class_zombie_register_claw(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Zombie_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid zombie class player (%d)", iClass_ID);

		return false;
	}

	new szClaw_Model[64];

	get_string(2, szClaw_Model, charsmax(szClaw_Model));

	precache_model(szClaw_Model);

	new Array:aClass_Claws = ArrayGetCell(g_aZombie_Class_Claws_Handle, iClass_ID);

	// No models registered yet?
	if (aClass_Claws == Invalid_Array)
	{
		aClass_Claws = ArrayCreate(64, 1);

		ArraySetCell(g_aZombie_Class_Claws_Handle, iClass_ID, aClass_Claws);
	}

	ArrayPushString(aClass_Claws, szClaw_Model);

	// Save models to file
	new szReal_Name[32];

	ArrayGetString(g_aZombie_Class_Real_Name, iClass_ID, szReal_Name, charsmax(szReal_Name));

	amx_save_setting_string_arr(ZP_ZOMBIECLASSES_FILE, szReal_Name, "CLAWMODEL", aClass_Claws);

	return true;
}

public native_class_zombie_register_kb(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Zombie_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid zombie class player (%d)", iClass_ID);

		return false;
	}

	new Float:fKnockback = get_param_f(2);

	// Set zombie class knockback
	ArraySetCell(g_aZombie_Class_Knockback, iClass_ID, fKnockback);

	// Save to file
	new szReal_Name[32];

	ArrayGetString(g_aZombie_Class_Real_Name, iClass_ID, szReal_Name, charsmax(szReal_Name));

	amx_save_setting_float(ZP_ZOMBIECLASSES_FILE, szReal_Name, "KNOCKBACK", 1.0);

	return true;
}

public native_class_zombie_get_id(iPlugin_ID, iNum_Params)
{
	new szReal_Name[32];

	get_string(1, szReal_Name, charsmax(szReal_Name));

	// Loop through every class
	new szZombieclass_Name[32];

	for (new i = 0; i < g_Zombie_Class_Count; i++)
	{
		ArrayGetString(g_aZombie_Class_Real_Name, i, szZombieclass_Name, charsmax(szZombieclass_Name));

		if (equali(szReal_Name, szZombieclass_Name))
		{
			return i;
		}
	}

	return ZP_INVALID_ZOMBIE_CLASS;
}

public native_class_zombie_get_name(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Zombie_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid zombie class player (%d)", iClass_ID);

		return false;
	}

	new szName[32];

	ArrayGetString(g_aZombie_Class_Name, iClass_ID, szName, charsmax(szName));

	new sLen = get_param(3);

	set_string(2, szName, sLen);

	return true;
}

public native_class_zombie_get_real_name(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Zombie_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid zombie class player (%d)", iClass_ID);

		return false;
	}

	new szReal_Name[32];

	ArrayGetString(g_aZombie_Class_Real_Name, iClass_ID, szReal_Name, charsmax(szReal_Name));

	new sLen = get_param(3);

	set_string(2, szReal_Name, sLen);

	return true;
}

public native_class_zombie_get_description(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Zombie_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid zombie class player (%d)", iClass_ID);

		return false;
	}

	new szDescription[32];

	ArrayGetString(g_aZombie_Class_Description, iClass_ID, szDescription, charsmax(szDescription));

	new sLen = get_param(3);

	set_string(2, szDescription, sLen);

	return true;
}

public Float:native_class_zombie_get_kb(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);

	if (iClass_ID < 0 || iClass_ID >= g_Zombie_Class_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid zombie class player (%d)", iClass_ID);

		return 1.0;
	}

	// Return zombie class knockback
	return ArrayGetCell(g_aZombie_Class_Knockback, iClass_ID);
}

public native_class_zombie_get_count(iPlugin_ID, iNum_Params)
{
	return g_Zombie_Class_Count;
}

public native_class_zombie_show_menu(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	Show_Menu_Zombieclass(iPlayer);

	return true;
}

public native_class_zombie_menu_text_add(iPlugin_ID, iNum_Params)
{
	static szText[32];

	get_string(1, szText, charsmax(szText));

	format(g_Additional_Menu_Text, charsmax(g_Additional_Menu_Text), "%s %s", g_Additional_Menu_Text, szText);
}

public client_putinserver(iPlayer)
{
	g_Zombie_Class[iPlayer] = ZP_INVALID_ZOMBIE_CLASS;
	g_Zombie_Class_Next[iPlayer] = ZP_INVALID_ZOMBIE_CLASS;

	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	// Reset remembered menu pages
	MENU_PAGE_CLASS(iPlayer) = 0;

	BIT_SUB(g_iBit_Connected, iPlayer);
}