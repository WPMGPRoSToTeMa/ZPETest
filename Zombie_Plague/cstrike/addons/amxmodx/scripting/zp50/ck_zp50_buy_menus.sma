/* AMX Mod X
*	[ZP] Buy Menus.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "buy menus"
#define VERSION "5.1.5.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

#include <amxmodx>
#include <amxmisc>
#include <cs_util>
#include <amx_settings_api>
#include <hamsandwich>
#include <ck_zp50_kernel>

#define LIBRARY_SURVIVOR "ck_zp50_class_survivor"
#include <ck_zp50_class_survivor>

#define LIBRARY_SNIPER "ck_zp50_class_sniper"
#include <ck_zp50_class_sniper>

// Buy Menu: Primary Weapons
new const g_Primary_Items[][] =
{
	"weapon_galil",
	"weapon_famas",
	"weapon_m4a1",
	"weapon_ak47",
	"weapon_sg552",
	"weapon_aug",
	"weapon_scout",
	"weapon_m3",
	"weapon_xm1014",
	"weapon_tmp",
	"weapon_mac10",
	"weapon_ump45",
	"weapon_mp5navy",
	"weapon_p90"
};

// Buy Menu: Secondary Weapons
new const g_Secondary_Items[][] =
{
	"weapon_glock18",
	"weapon_usp",
	"weapon_p228",
	"weapon_deagle",
	"weapon_fiveseven",
	"weapon_elite"
};

// Buy Menu: Grenades
new const g_Grenades_Items[][] =
{
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_smokegrenade"
};

// Primary and Secondary Weapon Names
new const g_Weapon_Names[][] =
{
	"",
	"P228 Compact",
	"",
	"Schmidt Scout",
	"HE Grenade",
	"XM1014 M4",
	"",
	"Ingram MAC-10",
	"Steyr AUG A1",
	"Smoke Grenade",
	"Dual Elite Berettas",
	"FiveseveN",
	"UMP 45",
	"SG-550 Auto-Sniper",
	"IMI Galil",
	"Famas",
	"USP .45 ACP Tactical",
	"Glock 18C",
	"AWP Magnum Sniper",
	"MP5 Navy",
	"M249 Para Machinegun",
	"M3 Super 90",
	"M4A1 Carbine",
	"Schmidt TMP",
	"G3SG1 Auto-Sniper",
	"Flashbang",
	"Desert Eagle .50 AE",
	"SG-552 Commando",
	"AK-47 Kalashnikov",
	"",
	"ES P90"
};

// Max BP ammo for weapons
new const g_Max_BP_Ammo[] =
{
	-1,
	52,
	-1,
	90,
	1,
	32,
	1,
	100,
	90,
	1,
	120,
	100,
	100,
	90,
	90,
	90,
	100,
	120,
	30,
	120,
	200,
	32,
	90,
	120,
	90,
	2,
	35,
	90,
	90,
	-1,
	100
};

// Ammo Type Names for weapons
new const g_Ammo_Type[][] =
{
	"",
	"357sig",
	"",
	"762nato",
	"",
	"buckshot",
	"",
	"45acp",
	"556nato",
	"",
	"9mm",
	"57mm",
	"45acp",
	"556nato",
	"556nato",
	"556nato",
	"45acp",
	"9mm",
	"338magnum",
	"9mm",
	"556natobox",
	"buckshot",
	"556nato",
	"9mm",
	"762nato",
	"",
	"50ae",
	"556nato",
	"762nato",
	"",
	"57mm"
};

// For weapon buy menu handlers
#define WPN_STARTID(%0) g_Menu_Data[%0][0]
#define WPN_MAXIDS (sizeof g_Primary_Items)
#define WPN_SELECTION(%1,%2) (g_Menu_Data[%1][1] + %2)
#define WPN_AUTO_ON(%2) g_Menu_Data[%2][2]
#define WPN_AUTO_PRIMARY(%3) g_Menu_Data[%3][3]
#define WPN_AUTO_SECONDARY(%4) g_Menu_Data[%4][4]
#define WPN_AUTO_GRENADE(%5) g_Menu_Data[%5][5]

#define WEAPON_ITEM_MAX_LENGTH 32

// Menu selections
#define MENU_KEY_AUTOSELECT 7
#define MENU_KEY_BACK 7
#define MENU_KEY_NEXT 8
#define MENU_KEY_EXIT 9

// Menu keys
const KEYSMENU = MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8
	| MENU_KEY_9 | MENU_KEY_0;

new Float:g_fBuy_Time_Start[MAX_PLAYERS + 1];

new g_Menu_Data[MAX_PLAYERS + 1][6];

new	Array:g_aPrimary_Items;
new	Array:g_aSecondary_Items;
new	Array:g_aGrenades_Items;

new g_Can_Buy_Primary;
new g_Can_Buy_Secondary;
new g_Can_Buy_Grenades;

new g_pCvar_Random_Primary;
new g_pCvar_Random_Secondary;
new g_pCvar_Random_Grenades;

new g_pCvar_Buy_Custom_Primary;
new g_pCvar_Buy_Custom_Secondary;
new g_pCvar_Buy_Custom_Grenades;

new g_pCvar_Give_All_Grenades;

new g_pCvar_Buy_Custom_Time_Primary;
new g_pCvar_Buy_Custom_Time_Secondary;
new g_pCvar_Buy_Custom_Time_Grenades;

new g_iBit_Alive;
new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Random_Primary = register_cvar("zm_random_primary", "0");
	g_pCvar_Random_Secondary = register_cvar("zm_random_secondary", "0");
	g_pCvar_Random_Grenades = register_cvar("zm_random_grenades", "0");

	g_pCvar_Buy_Custom_Time_Primary = register_cvar("zm_buy_custom_time_primary", "15");
	g_pCvar_Buy_Custom_Time_Secondary = register_cvar("zm_buy_custom_time_secondary", "15");
	g_pCvar_Buy_Custom_Time_Grenades = register_cvar("zm_buy_custom_time_grenades", "15");

	g_pCvar_Buy_Custom_Primary = register_cvar("zm_buy_custom_primary", "1");
	g_pCvar_Buy_Custom_Secondary = register_cvar("zm_buy_custom_secondary", "1");
	g_pCvar_Buy_Custom_Grenades = register_cvar("zm_buy_custom_grenades", "0");

	g_pCvar_Give_All_Grenades = register_cvar("zm_give_all_grenades", "1");

	register_clcmd("say /buy", "Client_Command_Buy");
	register_clcmd("say buy", "Client_Command_Buy");
	register_clcmd("say /guns", "Client_Command_Buy");
	register_clcmd("say guns", "Client_Command_Buy");

	// Menus
	register_menu("Buy Menu Primary", KEYSMENU, "Menu_Buy_Primary");
	register_menu("Buy Menu Secondary", KEYSMENU, "Menu_Buy_Secondary");
	register_menu("Buy Menu Grenades", KEYSMENU, "Menu_Buy_Grenades");
}

public plugin_precache()
{
	// Initialize arrays
	g_aPrimary_Items = ArrayCreate(WEAPON_ITEM_MAX_LENGTH, 1);
	g_aSecondary_Items = ArrayCreate(WEAPON_ITEM_MAX_LENGTH, 1);
	g_aGrenades_Items = ArrayCreate(WEAPON_ITEM_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Buy Menu Weapons", "PRIMARY", g_aPrimary_Items);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Buy Menu Weapons", "SECONDARY", g_aSecondary_Items);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Buy Menu Weapons", "GRENADES", g_aGrenades_Items);

	// If we couldn't load from file, use and save default ones
	if (ArraySize(g_aPrimary_Items) == 0)
	{
		for (new i = 0; i < sizeof g_Primary_Items; i++)
		{
			ArrayPushString(g_aPrimary_Items, g_Primary_Items[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Buy Menu Weapons", "PRIMARY", g_aPrimary_Items);
	}

	if (ArraySize(g_aSecondary_Items) == 0)
	{
		for (new i = 0; i < sizeof g_Secondary_Items; i++)
		{
			ArrayPushString(g_aSecondary_Items, g_Secondary_Items[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Buy Menu Weapons", "SECONDARY", g_aSecondary_Items);
	}

	if (ArraySize(g_aGrenades_Items) == 0)
	{
		for (new i = 0; i < sizeof g_Grenades_Items; i++)
		{
			ArrayPushString(g_aGrenades_Items, g_Grenades_Items[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Buy Menu Weapons", "GRENADES", g_aGrenades_Items);
	}
}

public plugin_natives()
{
	register_library("ck_zp50_buy_menus");

	register_native("zp_buy_menus_show", "native_buy_menus_show");

	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const szModule[])
{
	if (equal(szModule, LIBRARY_SURVIVOR) || equal(szModule, LIBRARY_SNIPER))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public native_filter(const szName[], iIndex, iTrap)
{
	if (!iTrap)
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public native_buy_menus_show(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (iPlayer > 32 || BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	Client_Command_Buy(iPlayer);

	return true;
}

public Client_Command_Buy(iPlayer)
{
	if (WPN_AUTO_ON(iPlayer))
	{
		zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "BUY_ENABLED");

		WPN_AUTO_ON(iPlayer) = 0;
	}

	// Player dead or zombie
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer) || zp_core_is_zombie(iPlayer))
	{
		return;
	}

	Show_Available_Buy_Menus(iPlayer);
}

public Human_Weapons(iPlayer)
{
	// Player dead or zombie
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer) || zp_core_is_zombie(iPlayer))
	{
		return;
	}

	// Survivor and Sniper automatically gets his own weapon
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(iPlayer) || LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(iPlayer))
	{
		BIT_SUB(g_Can_Buy_Primary, iPlayer);
		BIT_SUB(g_Can_Buy_Secondary, iPlayer);
		BIT_SUB(g_Can_Buy_Grenades, iPlayer);

		return;
	}

	// Random wapons settings
	if (get_pcvar_num(g_pCvar_Random_Primary))
	{
		Buy_Primary_Weapon(iPlayer, random(sizeof g_Primary_Items));
	}

	if (get_pcvar_num(g_pCvar_Random_Secondary))
	{
		Buy_Secondary_Weapon(iPlayer, random(sizeof g_Secondary_Items));
	}

	if (get_pcvar_num(g_pCvar_Random_Grenades))
	{
		Buy_Grenades(iPlayer, random(sizeof g_Grenades_Items));
	}

	// Custom buy menus
	if (get_pcvar_num(g_pCvar_Buy_Custom_Primary))
	{
		BIT_ADD(g_Can_Buy_Primary, iPlayer);

		if (WPN_AUTO_ON(iPlayer))
		{
			Buy_Primary_Weapon(iPlayer, WPN_AUTO_PRIMARY(iPlayer));
		}
	}

	if (get_pcvar_num(g_pCvar_Buy_Custom_Secondary))
	{
		BIT_ADD(g_Can_Buy_Secondary, iPlayer);

		if (WPN_AUTO_ON(iPlayer))
		{
			Buy_Secondary_Weapon(iPlayer, WPN_AUTO_SECONDARY(iPlayer));
		}
	}

	if (get_pcvar_num(g_pCvar_Buy_Custom_Grenades))
	{
		BIT_ADD(g_Can_Buy_Grenades, iPlayer);

		if (WPN_AUTO_ON(iPlayer))
		{
			Buy_Grenades(iPlayer, WPN_AUTO_GRENADE(iPlayer));
		}
	}

	// Open available buy menus
	Show_Available_Buy_Menus(iPlayer);

	// Automatically give all grenades?
	if (get_pcvar_num(g_pCvar_Give_All_Grenades))
	{
		for (new i = 0; i < sizeof g_Grenades_Items; i++)
		{
			Buy_Grenades(iPlayer, i);
		}
	}
}

// Shows the next available buy menu
Show_Available_Buy_Menus(iPlayer)
{
	if (BIT_VALID(g_Can_Buy_Primary, iPlayer))
	{
		Show_Menu_Buy_Primary(iPlayer);
	}

	else if (BIT_VALID(g_Can_Buy_Secondary, iPlayer))
	{
		Show_Menu_Buy_Secondary(iPlayer);
	}

	else if (BIT_VALID(g_Can_Buy_Grenades, iPlayer))
	{
		Show_Menu_Buy_Grenades(iPlayer);
	}
}

// Buy Menu Primary
Show_Menu_Buy_Primary(iPlayer)
{
	new iMenu_Time = floatround(g_fBuy_Time_Start[iPlayer] + get_pcvar_float(g_pCvar_Buy_Custom_Time_Primary) - get_gametime());

	if (iMenu_Time <= 0)
	{
		zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "BUY_MENU_TIME_EXPIRED");

		return;
	}

	static szMenu[512];

	new iLen;
	new iMaxloops = min(WPN_STARTID(iPlayer) + 7, WPN_MAXIDS);

	// Title
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y %L \r [%d - %d] ^n ^n", iPlayer, "MENU_BUY1_TITLE", WPN_STARTID(iPlayer) + 1, min(WPN_STARTID(iPlayer) + 7, WPN_MAXIDS));

	// 1-7. Weapon List
	for (new i = WPN_STARTID(iPlayer); i < iMaxloops; i++)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r %d. \w %s ^n", i - WPN_STARTID(iPlayer) + 1, g_Weapon_Names[rg_get_weapon_info(g_Primary_Items[i], WI_ID)]);
	}

	// 8. Auto Select
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n \r 8. \w %L \y [%L]", iPlayer, "MENU_AUTOSELECT", iPlayer, (WPN_AUTO_ON(iPlayer)) ? "MOTD_ENABLED" : "MOTD_DISABLED");

	// 9. Next/Back - 0. Exit
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n ^n \r 9. \w %L / %L ^n ^n \r 0. \w %L", iPlayer, "MENU_NEXT", iPlayer, "MENU_BACK", iPlayer, "MENU_EXIT");

	show_menu(iPlayer, KEYSMENU, szMenu, iMenu_Time, "Buy Menu Primary");
}

// Buy Menu Secondary
Show_Menu_Buy_Secondary(iPlayer)
{
	new iMenu_Time = floatround(g_fBuy_Time_Start[iPlayer] + get_pcvar_float(g_pCvar_Buy_Custom_Time_Secondary) - get_gametime());

	if (iMenu_Time <= 0)
	{
		zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "BUY_MENU_TIME_EXPIRED");

		return;
	}

	static szMenu[512];

	new iLen;
	new iMaxloops = sizeof g_Secondary_Items;

	// Title
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y %L ^n", iPlayer, "MENU_BUY2_TITLE");

	// 1-6. Weapon List
	for (new i = 0; i < iMaxloops; i++)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n \r %d. \w %s", i + 1, g_Weapon_Names[rg_get_weapon_info(g_Secondary_Items[i], WI_ID)]);
	}

	// 8. Auto Select
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n ^n \r 8. \w %L \y [%L]", iPlayer, "MENU_AUTOSELECT", iPlayer, (WPN_AUTO_ON(iPlayer)) ? "MOTD_ENABLED" : "MOTD_DISABLED");

	// 0. Exit
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n ^n \r 0. \w %L", iPlayer, "MENU_EXIT");

	show_menu(iPlayer, KEYSMENU, szMenu, iMenu_Time, "Buy Menu Secondary");
}

// Buy Menu Grenades
Show_Menu_Buy_Grenades(iPlayer)
{
	new iMenu_Time = floatround(g_fBuy_Time_Start[iPlayer] + get_pcvar_float(g_pCvar_Buy_Custom_Time_Grenades) - get_gametime());

	if (iMenu_Time <= 0)
	{
		zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "BUY_MENU_TIME_EXPIRED");

		return;
	}

	static szMenu[512];

	new iLen;
	new iMaxloops = sizeof g_Grenades_Items;

	// Title
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y %L ^n", iPlayer, "MENU_BUY3_TITLE");

	// 1-3. Item List
	for (new i = 0; i < iMaxloops; i++)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n \r %d. \w %s", i + 1, g_Weapon_Names[rg_get_weapon_info(g_Grenades_Items[i], WI_ID)]);
	}

	// 8. Auto Select
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n ^n \r 8. \w %L \y [%L]", iPlayer, "MENU_AUTOSELECT", iPlayer, (WPN_AUTO_ON(iPlayer)) ? "MOTD_ENABLED" : "MOTD_DISABLED");

	// 0. Exit
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n ^n \r 0. \w %L", iPlayer, "MENU_EXIT");

	show_menu(iPlayer, KEYSMENU, szMenu, iMenu_Time, "Buy Menu Grenades");
}

// Buy Menu Primary
public Menu_Buy_Primary(iPlayer, iKey)
{
	// Player dead or zombie or already bought primary
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer) || zp_core_is_zombie(iPlayer) || BIT_NOT_VALID(g_Can_Buy_Primary, iPlayer))
	{
		return PLUGIN_HANDLED;
	}

	// Special keys / weapon list exceeded
	if (iKey >= MENU_KEY_AUTOSELECT || WPN_SELECTION(iPlayer, iKey) >= WPN_MAXIDS)
	{
		switch (iKey)
		{
			case MENU_KEY_AUTOSELECT: // Toggle auto select
			{
				WPN_AUTO_ON(iPlayer) = 1 - WPN_AUTO_ON(iPlayer);
			}

			case MENU_KEY_NEXT: // Next/back
			{
				if (WPN_STARTID(iPlayer) + 7 < WPN_MAXIDS)
				{
					WPN_STARTID(iPlayer) += 7;
				}

				else
				{
					WPN_STARTID(iPlayer) = 0;
				}
			}

			case MENU_KEY_EXIT: // exit
			{
				return PLUGIN_HANDLED;
			}
		}

		// Show buy menu again
		Show_Menu_Buy_Primary(iPlayer);

		return PLUGIN_HANDLED;
	}

	// Store selected weapon id
	WPN_AUTO_PRIMARY(iPlayer) = WPN_SELECTION(iPlayer, iKey + WPN_STARTID(iPlayer));

	// Buy primary weapon
	Buy_Primary_Weapon(iPlayer, WPN_AUTO_PRIMARY(iPlayer));

	// Show next buy menu
	Show_Available_Buy_Menus(iPlayer);

	return PLUGIN_HANDLED;
}

// Buy Primary Weapon
Buy_Primary_Weapon(iPlayer, iSelection)
{
	// Get weapon's player
	new iWeapon_ID = rg_get_weapon_info(g_Primary_Items[iSelection], WI_ID);

	// Give the new weapon and full ammo
	rg_give_item(iPlayer, g_Primary_Items[iSelection], GT_DROP_AND_REPLACE);

	ExecuteHamB(Ham_GiveAmmo, iPlayer, g_Max_BP_Ammo[iWeapon_ID], g_Ammo_Type[iWeapon_ID], g_Max_BP_Ammo[iWeapon_ID]);

	// Primary bought
	BIT_SUB(g_Can_Buy_Primary, iPlayer);
}

// Buy Menu Secondary
public Menu_Buy_Secondary(iPlayer, iKey)
{
	// Player dead or zombie or already bought secondary
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer) || zp_core_is_zombie(iPlayer) || BIT_NOT_VALID(g_Can_Buy_Secondary, iPlayer))
	{
		return PLUGIN_HANDLED;
	}

	// Special keys / weapon list exceeded
	if (iKey >= sizeof g_Secondary_Items)
	{
		// Toggle autoselect
		if (iKey == MENU_KEY_AUTOSELECT)
		{
			WPN_AUTO_ON(iPlayer) = 1 - WPN_AUTO_ON(iPlayer);
		}

		// Reshow menu unless user exited
		if (iKey != MENU_KEY_EXIT)
		{
			Show_Menu_Buy_Secondary(iPlayer);
		}

		return PLUGIN_HANDLED;
	}

	// Store selected weapon id
	WPN_AUTO_SECONDARY(iPlayer) = iKey;

	// Buy secondary weapon
	Buy_Secondary_Weapon(iPlayer, iKey);

	// Show next buy menu
	Show_Available_Buy_Menus(iPlayer);

	return PLUGIN_HANDLED;
}

// Buy Secondary Weapon
Buy_Secondary_Weapon(iPlayer, iSelection)
{
	// Get weapon's player
	new iWeapon_ID = rg_get_weapon_info(g_Secondary_Items[iSelection], WI_ID);

	// Give the new weapon and full ammo
	rg_give_item(iPlayer, g_Secondary_Items[iSelection], GT_DROP_AND_REPLACE);

	ExecuteHamB(Ham_GiveAmmo, iPlayer, g_Max_BP_Ammo[iWeapon_ID], g_Ammo_Type[iWeapon_ID], g_Max_BP_Ammo[iWeapon_ID]);

	// Secondary bought
	BIT_SUB(g_Can_Buy_Secondary, iPlayer);
}

// Buy Menu Grenades
public Menu_Buy_Grenades(iPlayer, iKey)
{
	// Player dead or zombie or already bought grenades
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer) || zp_core_is_zombie(iPlayer) || BIT_NOT_VALID(g_Can_Buy_Grenades, iPlayer))
	{
		return PLUGIN_HANDLED;
	}

	// Special keys / weapon list exceeded
	if (iKey >= sizeof g_Grenades_Items)
	{
		// Toggle autoselect
		if (iKey == MENU_KEY_AUTOSELECT)
		{
			WPN_AUTO_ON(iPlayer) = 1 - WPN_AUTO_ON(iPlayer);
		}

		// Reshow menu unless user exited
		if (iKey != MENU_KEY_EXIT)
		{
			Show_Menu_Buy_Grenades(iPlayer);
		}

		return PLUGIN_HANDLED;
	}

	// Store selected grenade
	WPN_AUTO_GRENADE(iPlayer) = iKey;

	// Buy selected grenade
	Buy_Grenades(iPlayer, iKey);

	return PLUGIN_HANDLED;
}

// Buy Grenades
Buy_Grenades(iPlayer, iSelection)
{
	// Give the new weapon
	rg_give_item(iPlayer, g_Grenades_Items[iSelection]);

	// Grenades bought
	BIT_SUB(g_Can_Buy_Grenades, iPlayer);
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	WPN_AUTO_ON(iPlayer) = 0;
	WPN_STARTID(iPlayer) = 0;

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

public zp_fw_core_cure_post(iPlayer)
{
	// Buyzone time starts when player is set to human
	g_fBuy_Time_Start[iPlayer] = get_gametime();

	Human_Weapons(iPlayer);
}