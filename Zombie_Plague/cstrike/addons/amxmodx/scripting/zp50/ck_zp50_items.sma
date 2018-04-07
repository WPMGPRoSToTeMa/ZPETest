/* AMX Mod X
*	[ZP] Kernel Items.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "kernel items"
#define VERSION "5.2.3.0"
#define AUTHOR "C&K Corporation"

#define ZP_EXTRAITEMS_FILE "zm_extraitems.ini"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_zp50_kernel>
#include <ck_zp50_items_const>

// For item list menu handlers
#define MENU_PAGE_ITEMS(%0) g_Menu_Data[%0]

new g_Menu_Data[MAX_PLAYERS + 1];

enum TOTAL_FORWARDS
{
	FW_ITEM_SELECT_PRE = 0,
	FW_ITEM_SELECT_POST
};

new g_Forwards[TOTAL_FORWARDS];
new g_Forward_Result;

// Items data
new Array:g_aItem_Real_Name;
new Array:g_aItem_Name;
new Array:g_aItem_Cost;

new g_Item_Count;

new g_Additional_Menu_Text[32];

new g_iBit_Alive;
new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /items", "Client_Command_Items");
	register_clcmd("say items", "Client_Command_Items");

	g_Forwards[FW_ITEM_SELECT_PRE] = CreateMultiForward("zp_fw_items_select_pre", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL);
	g_Forwards[FW_ITEM_SELECT_POST] = CreateMultiForward("zp_fw_items_select_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
}

public plugin_natives()
{
	register_library("ck_zp50_items");

	register_native("zp_items_register", "native_items_register");
	register_native("zp_items_get_id", "native_items_get_id");
	register_native("zp_items_get_name", "native_items_get_name");
	register_native("zp_items_get_real_name", "native_items_get_real_name");
	register_native("zp_items_get_cost", "native_items_get_cost");
	register_native("zp_items_show_menu", "native_items_show_menu");
	register_native("zp_items_force_buy", "native_items_force_buy");
	register_native("zp_items_menu_text_add", "native_items_menu_text_add");

	register_native("zp_items_menu_get_text_add", "native_items_menu_get_text_add");
	register_native("zp_items_available", "native_items_available");

	// Initialize dynamic arrays
	g_aItem_Real_Name = ArrayCreate(32, 1);
	g_aItem_Name = ArrayCreate(32, 1);
	g_aItem_Cost = ArrayCreate(1, 1);
}

public native_items_register(iPlugin_ID, iNum_Params)
{
	new szPlayer_Name[32];

	new iCost = get_param(2);

	get_string(1, szPlayer_Name, charsmax(szPlayer_Name));

	if (strlen(szPlayer_Name) < 1)
	{
		log_error(AMX_ERR_NATIVE, "Can't register item with an empty name");

		return ZP_INVALID_ITEM;
	}

	new szItem_Name[32];

	for (new i = 0; i < g_Item_Count; i++)
	{
		ArrayGetString(g_aItem_Real_Name, i, szItem_Name, charsmax(szItem_Name));

		if (equali(szPlayer_Name, szItem_Name))
		{
			log_error(AMX_ERR_NATIVE, "Item already registered (%s)", szPlayer_Name);

			return ZP_INVALID_ITEM;
		}
	}

	// Load settings from extra items file
	new szReal_Name[32];

	copy(szReal_Name, charsmax(szReal_Name), szPlayer_Name);

	ArrayPushString(g_aItem_Real_Name, szReal_Name);

	// Name
	if (!amx_load_setting_string(ZP_EXTRAITEMS_FILE, szReal_Name, "NAME", szPlayer_Name, charsmax(szPlayer_Name)))
	{
		amx_save_setting_string(ZP_EXTRAITEMS_FILE, szReal_Name, "NAME", szPlayer_Name);
	}

	ArrayPushString(g_aItem_Name, szPlayer_Name);

	// Cost
	if (!amx_load_setting_int(ZP_EXTRAITEMS_FILE, szReal_Name, "COST", iCost))
	{
		amx_save_setting_int(ZP_EXTRAITEMS_FILE, szReal_Name, "COST", iCost);
	}

	ArrayPushCell(g_aItem_Cost, iCost);

	g_Item_Count++;

	return g_Item_Count - 1;
}

public native_items_get_id(iPlugin_ID, iNum_Params)
{
	new szReal_Name[32];

	get_string(1, szReal_Name, charsmax(szReal_Name));

	// Loop through every item
	new szItem_Name[32];

	for (new i = 0; i < g_Item_Count; i++)
	{
		ArrayGetString(g_aItem_Real_Name, i, szItem_Name, charsmax(szItem_Name));

		if (equali(szReal_Name, szItem_Name))
		{
			return i;
		}
	}

	return ZP_INVALID_ITEM;
}

public native_items_get_name(iPlugin_ID, iNum_Params)
{
	new iItem_ID = get_param(1);

	if (iItem_ID < 0 || iItem_ID >= g_Item_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid item player (%d)", iItem_ID);

		return false;
	}

	new szPlayer_Name[32];

	ArrayGetString(g_aItem_Name, iItem_ID, szPlayer_Name, charsmax(szPlayer_Name));

	new sLen = get_param(3);

	set_string(2, szPlayer_Name, sLen);

	return true;
}

public native_items_get_real_name(iPlugin_ID, iNum_Params)
{
	new iItem_ID = get_param(1);

	if (iItem_ID < 0 || iItem_ID >= g_Item_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid item player (%d)", iItem_ID);

		return false;
	}

	new szReal_Name[32];

	ArrayGetString(g_aItem_Real_Name, iItem_ID, szReal_Name, charsmax(szReal_Name));

	new sLen = get_param(3);

	set_string(2, szReal_Name, sLen);

	return true;
}

public native_items_get_cost(iPlugin_ID, iNum_Params)
{
	new iItem_ID = get_param(1);

	if (iItem_ID < 0 || iItem_ID >= g_Item_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid item player (%d)", iItem_ID);

		return -1;
	}

	return ArrayGetCell(g_aItem_Cost, iItem_ID);
}

public native_items_show_menu(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	Client_Command_Items(iPlayer);

	return true;
}

public native_items_force_buy(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	new iItem_ID = get_param(2);

	if (iItem_ID < 0 || iItem_ID >= g_Item_Count)
	{
		log_error(AMX_ERR_NATIVE, "Invalid item player (%d)", iItem_ID);

		return false;
	}

	new iIgnorecost = get_param(3);

	Buy_Item(iPlayer, iItem_ID, iIgnorecost);

	return true;
}

public native_items_menu_text_add(iPlugin_ID, iNum_Params)
{
	static szText[32];

	get_string(1, szText, charsmax(szText));

	format(g_Additional_Menu_Text, charsmax(g_Additional_Menu_Text), "%s %s", g_Additional_Menu_Text, szText);
}

public native_items_menu_get_text_add(iPlugin_ID, iNum_Params)
{
	set_string(1, g_Additional_Menu_Text, charsmax(g_Additional_Menu_Text));
}

public native_items_available(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);

		return false;
	}

	new iItem_ID = get_param(2);

	if (iItem_ID < 0 || iItem_ID >= g_Item_Count)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid item (%d)", iItem_ID);

		return false;
	}

	g_Additional_Menu_Text[0] = 0;

	ExecuteForward(g_Forwards[FW_ITEM_SELECT_PRE], g_Forward_Result, iPlayer, iItem_ID, 0);

	return g_Forward_Result;
}

public Client_Command_Items(iPlayer)
{
	// Player dead
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		return;
	}

	Show_Items_Menu(iPlayer);
}

// Items Menu
Show_Items_Menu(iPlayer)
{
	static szMenu[256];
	static szTranskey[64];
	static szPlayer_Name[32];

	static iCost;

	new iMenu_ID;
	new iItemdata[2];

	// Title
	formatex(szMenu, charsmax(szMenu), "%L: \r", iPlayer, "MENU_EXTRABUY");
	iMenu_ID = menu_create(szMenu, "Menu_Extraitems");

	// Item List
	for (new i = 0; i < g_Item_Count; i++)
	{
		// Additional text to display
		g_Additional_Menu_Text[0] = 0;

		// Execute item select attempt forward
		ExecuteForward(g_Forwards[FW_ITEM_SELECT_PRE], g_Forward_Result, iPlayer, i, 0);

		// Show item to player?
		if (g_Forward_Result >= ZP_ITEM_DONT_SHOW)
		{
			continue;
		}

		// Add item name and cсost
		ArrayGetString(g_aItem_Name, i, szPlayer_Name, charsmax(szPlayer_Name));

		iCost = ArrayGetCell(g_aItem_Cost, i);

		// ML support for item mame
		formatex(szTranskey, charsmax(szTranskey), "ITEMNAME %s", szPlayer_Name);

		if (GetLangTransKey(szTranskey) != TransKey_Bad)
		{
			formatex(szPlayer_Name, charsmax(szPlayer_Name), "%L", iPlayer, szTranskey);
		}

		// Item available to player?
		if (g_Forward_Result >= ZP_ITEM_NOT_AVAILABLE)
		{
			formatex(szMenu, charsmax(szMenu), "\d %s %d %s", szPlayer_Name, iCost, g_Additional_Menu_Text);
		}

		else
		{
			formatex(szMenu, charsmax(szMenu), "%s \y %d \w %s", szPlayer_Name, iCost, g_Additional_Menu_Text);
		}

		iItemdata[0] = i;
		iItemdata[1] = 0;

		menu_additem(iMenu_ID, szMenu, iItemdata);
	}

	// No items to display?
	if (menu_items(iMenu_ID) <= 0)
	{
		client_print(iPlayer, print_chat, "%L", LANG_PLAYER, "NO_EXTRA_ITEMS");

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
	MENU_PAGE_ITEMS(iPlayer) = min(MENU_PAGE_ITEMS(iPlayer), menu_pages(iMenu_ID) - 1);

	menu_display(iPlayer, iMenu_ID, MENU_PAGE_ITEMS(iPlayer));
}

// Items Menu
public Menu_Extraitems(iPlayer, iMenu_ID, iItem)
{
	// Menu was closed
	if (iItem == MENU_EXIT)
	{
		MENU_PAGE_ITEMS(iPlayer) = 0;

		menu_destroy(iMenu_ID);

		return PLUGIN_HANDLED;
	}

	// Remember items menu page
	MENU_PAGE_ITEMS(iPlayer) = iItem / 7;

	// Dead players are not allowed to buy items
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		menu_destroy(iMenu_ID);

		return PLUGIN_HANDLED;
	}

	// Retrieve item player
	new iItemdata[2];

	new iDummy;
	new iItem_ID;

	menu_item_getinfo(iMenu_ID, iItem, iDummy, iItemdata, charsmax(iItemdata), _, _, iDummy);

	iItem_ID = iItemdata[0];

	// Attempt to buy the item
	Buy_Item(iPlayer, iItem_ID);

	menu_destroy(iMenu_ID);

	return PLUGIN_HANDLED;
}

// Buy Item
Buy_Item(iPlayer, iItem_ID, iIgnorecost = 0)
{
	// Execute item select attempt forward
	ExecuteForward(g_Forwards[FW_ITEM_SELECT_PRE], g_Forward_Result, iPlayer, iItem_ID, iIgnorecost);

	// Item available to player?
	if (g_Forward_Result >= ZP_ITEM_NOT_AVAILABLE)
	{
		return;
	}

	// Execute item selected forward
	ExecuteForward(g_Forwards[FW_ITEM_SELECT_POST], g_Forward_Result, iPlayer, iItem_ID, iIgnorecost);
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	// Reset remembered menu pages
	MENU_PAGE_ITEMS(iPlayer) = 0;

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