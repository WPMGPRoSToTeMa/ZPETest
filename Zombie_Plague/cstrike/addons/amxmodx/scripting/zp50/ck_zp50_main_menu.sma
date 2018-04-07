/* AMX Mod X
*	[ZP] Main menu.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "main menu"
#define VERSION "5.2.4.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <amxmisc>
#include <cs_util>
#include <ck_zp50_kernel>

#define LIBRARY_BUYMENUS "ck_zp50_buy_menus"
#include <ck_zp50_buy_menus>

#define LIBRARY_ZOMBIECLASSES "ck_zp50_class_zombie"
#include <ck_zp50_class_zombie>

#define LIBRARY_HUMANCLASSES "ck_zp50_class_human"
#include <ck_zp50_class_human>

#define LIBRARY_ITEMS "ck_zp50_items"
#include <ck_zp50_items>

#define LIBRARY_ADMIN_MENU "ck_zp50_admin_menu"
#include <ck_zp50_admin_menu>

#define LIBRARY_RANDOMSPAWN "ck_zp50_random_spawn"
#include <ck_zp50_random_spawn>

// Menu keys
const KEYSMENU = MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9 | MENU_KEY_0;

new g_Choose_Team_Override_Active;

new g_pCvar_Buy_Custom_Primary;
new g_pCvar_Buy_Custom_Secondary;
new g_pCvar_Buy_Custom_Grenades;

new g_pCvar_Random_Spawning;

new g_iBit_Alive;
new g_iBit_Connected;
new g_iBit_Admin;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("chooseteam", "Client_Command_Chooseteam");

	register_clcmd("say /zpmenu", "Client_Command_Zpmenu");
	register_clcmd("say zpmenu", "Client_Command_Zpmenu");

	// Menus
	register_menu("Main Menu", KEYSMENU, "Menu_Main");
}

public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const szModule[])
{
	if (equal(szModule, LIBRARY_BUYMENUS) || equal(szModule, LIBRARY_ZOMBIECLASSES) || equal(szModule, LIBRARY_HUMANCLASSES) || equal(szModule, LIBRARY_ITEMS) || equal(szModule, LIBRARY_ADMIN_MENU) || equal(szModule, LIBRARY_RANDOMSPAWN))
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

public plugin_cfg()
{
	g_pCvar_Buy_Custom_Primary = get_cvar_pointer("zm_buy_custom_primary");
	g_pCvar_Buy_Custom_Secondary = get_cvar_pointer("zm_buy_custom_secondary");
	g_pCvar_Buy_Custom_Grenades = get_cvar_pointer("zm_buy_custom_grenades");
	g_pCvar_Random_Spawning = get_cvar_pointer("zm_random_spawning_csdm");
}

public Client_Command_Chooseteam(iPlayer)
{
	if (BIT_VALID(g_Choose_Team_Override_Active, iPlayer))
	{
		Show_Menu_Main(iPlayer);

		return PLUGIN_HANDLED;
	}

	BIT_ADD(g_Choose_Team_Override_Active, iPlayer);

	return PLUGIN_CONTINUE;
}

public Client_Command_Zpmenu(iPlayer)
{
	Show_Menu_Main(iPlayer);
}

// Main Menu
Show_Menu_Main(iPlayer)
{
	static szMenu[512];

	new iLen;

	// Title
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", iPlayer, "MENU_TITLE");

	// 1. Buy menu
	if (LibraryExists(LIBRARY_BUYMENUS, LibType_Library) && (get_pcvar_num(g_pCvar_Buy_Custom_Primary) || get_pcvar_num(g_pCvar_Buy_Custom_Secondary) || get_pcvar_num(g_pCvar_Buy_Custom_Grenades)) && BIT_VALID(g_iBit_Alive, iPlayer))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 1. \w %L ^n", iPlayer, "MENU_BUY");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 1. %L ^n", iPlayer, "MENU_BUY");
	}

	// 2. Extra items
	if (LibraryExists(LIBRARY_ITEMS, LibType_Library) && BIT_VALID(g_iBit_Alive, iPlayer))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 2. \w %L ^n", iPlayer, "MENU_EXTRABUY");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 2. %L ^n", iPlayer, "MENU_EXTRABUY");
	}

	// 3. Zombie class
	if (LibraryExists(LIBRARY_ZOMBIECLASSES, LibType_Library) && zp_class_zombie_get_count() > 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 3. \w %L ^n", iPlayer, "MENU_ZCLASS");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 3. %L ^n", iPlayer, "MENU_ZCLASS");
	}

	// 4. Human class
	if (LibraryExists(LIBRARY_HUMANCLASSES, LibType_Library) && zp_class_human_get_count() > 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 4. \w %L ^n", iPlayer, "MENU_HCLASS");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 4. %L ^n", iPlayer, "MENU_HCLASS");
	}

	// 5. Unstuck
	if (LibraryExists(LIBRARY_RANDOMSPAWN, LibType_Library) && BIT_VALID(g_iBit_Alive, iPlayer))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 5. \w %L ^n", iPlayer, "MENU_UNSTUCK");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 5. %L ^n", iPlayer, "MENU_UNSTUCK");
	}

	// 7. Choose team
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 6. \w %L ^n ^n", iPlayer, "MENU_CHOOSE_TEAM");

	// 9. Admin menu
	if (LibraryExists(LIBRARY_ADMIN_MENU, LibType_Library) && BIT_VALID(g_iBit_Admin, iPlayer))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 9. \w %L", iPlayer, "MENU_ADMIN");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 9. %L", iPlayer, "MENU_ADMIN");
	}

	// 0. Exit
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n ^n \r 0. \w %L", iPlayer, "MENU_EXIT");

	show_menu(iPlayer, KEYSMENU, szMenu, -1, "Main Menu");
}

// Main Menu
public Menu_Main(iPlayer, iKey)
{
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		return PLUGIN_HANDLED;
	}

	switch (iKey)
	{
		case 0: // Buy menu
		{
			// Custom buy menus enabled?
			if (LibraryExists(LIBRARY_BUYMENUS, LibType_Library) && (get_pcvar_num(g_pCvar_Buy_Custom_Primary) || get_pcvar_num(g_pCvar_Buy_Custom_Secondary) || get_pcvar_num(g_pCvar_Buy_Custom_Grenades)))
			{
				// Check whether the player is able to buy anything
				if (BIT_VALID(g_iBit_Alive, iPlayer))
				{
					zp_buy_menus_show(iPlayer);
				}

				else
				{
					zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CANT_BUY_WEAPONS_DEAD");
				}
			}

			else
			{
				zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CUSTOM_BUY_DISABLED");
			}
		}

		case 1: // Extra items
		{
			// Items enabled?
			if (LibraryExists(LIBRARY_ITEMS, LibType_Library))
			{
				// Check whether the player is able to buy anything
				if (BIT_VALID(g_iBit_Alive, iPlayer))
				{
					zp_items_show_menu(iPlayer);
				}

				else
				{
					zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CANT_BUY_ITEMS_DEAD");
				}
			}

			else
			{
				zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT_EXTRAS");
			}
		}

		case 2: // Zombie classes
		{
			if (LibraryExists(LIBRARY_ZOMBIECLASSES, LibType_Library) && zp_class_zombie_get_count() > 1)
			{
				zp_class_zombie_show_menu(iPlayer);
			}

			else
			{
				zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT_ZCLASSES");
			}
		}

		case 3: // Human classes
		{
			if (LibraryExists(LIBRARY_HUMANCLASSES, LibType_Library) && zp_class_human_get_count() > 1)
			{
				zp_class_human_show_menu(iPlayer);
			}

			else
			{
				zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT_HCLASSES");
			}
		}

		case 4:
		{
			// Check if player is stuck
			if (LibraryExists(LIBRARY_RANDOMSPAWN, LibType_Library) && BIT_VALID(g_iBit_Alive, iPlayer))
			{
				if (Is_Player_Stuck(iPlayer))
				{
					// Move to an initial spawn
					if (get_pcvar_num(g_pCvar_Random_Spawning))
					{
						zp_random_spawn_do(iPlayer, true); // random spawn (including CSDM)
					}

					else
					{
						zp_random_spawn_do(iPlayer, false); // regular spawn
					}
				}

				else
				{
					zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT_STUCK");
				}
			}

			else
			{
				zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT");
			}
		}

		case 5: // Menu override
		{
			BIT_SUB(g_Choose_Team_Override_Active, iPlayer);

			client_cmd(iPlayer, "chooseteam");
		}

		case 8: // Admin menu
		{
			if (LibraryExists(LIBRARY_ADMIN_MENU, LibType_Library) && BIT_VALID(g_iBit_Admin, iPlayer))
			{
				zp_admin_menu_show(iPlayer);
			}

			else
			{
				zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "NO_ADMIN_MENU");
			}
		}
	}

	return PLUGIN_HANDLED;
}

public client_putinserver(iPlayer)
{
	if (is_user_admin(iPlayer))
	{
		BIT_ADD(g_iBit_Admin, iPlayer);
	}

	BIT_ADD(g_Choose_Team_Override_Active, iPlayer);

	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	BIT_SUB(g_iBit_Admin, iPlayer);
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