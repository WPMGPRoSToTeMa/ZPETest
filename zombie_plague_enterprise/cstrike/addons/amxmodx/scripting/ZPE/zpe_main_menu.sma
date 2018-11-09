/* AMX Mod X
*	[ZPE] Main menu.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
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

#define PLUGIN "main menu"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <amxmisc>
#include <cs_util>
#include <zpe_kernel>

#define LIBRARY_BUYMENUS "zpe_buy_menus"
#include <zpe_buy_menus>

#include <zpe_class_zombie>
#include <zpe_class_human>

#define LIBRARY_ITEMS "zpe_items"
#include <zpe_items>

#define LIBRARY_ADMIN_MENU "zpe_admin_menu"
#include <zpe_admin_menu>

#define LIBRARY_RANDOM_SPAWN "zpe_random_spawn"
#include <zpe_random_spawn>

// Menu keys
const KEYS_MENU = MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_9 | MENU_KEY_0;

new g_Choose_Team_Override_Active;

new g_pCvar_Buy_Custom_Primary;
new g_pCvar_Buy_Custom_Secondary;
new g_pCvar_Buy_Custom_Grenades;

new g_pCvar_Random_Spawning_CSDM;

new g_iBit_Alive;
new g_iBit_Connected;
new g_iBit_Admin;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("chooseteam", "Client_Command_Chooseteam");

	register_clcmd("say /zpemenu", "Client_Command_Zpemenu");
	register_clcmd("say zpemenu", "Client_Command_Zpemenu");

	// Menus
	register_menu("Main Menu", KEYS_MENU, "Menu_Main");
}

public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const szModule[])
{
	if (equal(szModule, LIBRARY_BUYMENUS) || equal(szModule, LIBRARY_ITEMS) || equal(szModule, LIBRARY_ADMIN_MENU) || equal(szModule, LIBRARY_RANDOM_SPAWN))
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
	g_pCvar_Buy_Custom_Primary = get_cvar_pointer("zpe_buy_custom_primary");
	g_pCvar_Buy_Custom_Secondary = get_cvar_pointer("zpe_buy_custom_secondary");
	g_pCvar_Buy_Custom_Grenades = get_cvar_pointer("zpe_buy_custom_grenades");
	g_pCvar_Random_Spawning_CSDM = get_cvar_pointer("zpe_random_spawning_csdm");
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

public Client_Command_Zpemenu(iPlayer)
{
	Show_Menu_Main(iPlayer);
}

// Menu main
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 2. \w %L ^n", iPlayer, "MENU_EXTRA_BUY");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 2. %L ^n", iPlayer, "MENU_EXTRA_BUY");
	}

	// 3. Class Zombie
	if (zp_class_zombie_get_count() > 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 3. \w %L ^n", iPlayer, "MENU_CLASS_ZOMBIE");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 3. %L ^n", iPlayer, "MENU_CLASS_ZOMBIE");
	}

	// 4. Class Human
	if (zp_class_human_get_count() > 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 4. \w %L ^n", iPlayer, "MENU_CLASS_HUMAN");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 4. %L ^n", iPlayer, "MENU_CLASS_HUMAN");
	}

	// 5. Unstuck
	if (LibraryExists(LIBRARY_RANDOM_SPAWN, LibType_Library) && BIT_VALID(g_iBit_Alive, iPlayer))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r 5. \w %L ^n", iPlayer, "MENU_UNSTUCK");
	}

	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d 5. %L ^n", iPlayer, "MENU_UNSTUCK");
	}

	// 6. Choose team
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

	show_menu(iPlayer, KEYS_MENU, szMenu, -1, "Main Menu");
}

// Menu main
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
					zpe_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CANT_BUY_WEAPONS_DEAD_COLOR");
				}
			}

			else
			{
				zpe_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CUSTOM_BUY_DISABLED_COLOR");
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
					zpe_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CANT_BUY_ITEMS_DEAD_COLOR");
				}
			}

			else
			{
				zpe_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT_EXTRAS_COLOR");
			}
		}

		case 2: // Classes zombie
		{
			if (zp_class_zombie_get_count() > 1)
			{
				zp_class_zombie_show_menu(iPlayer);
			}

			else
			{
				zpe_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT_CLASSES_ZOMBIE_COLOR");
			}
		}

		case 3: // Classes human
		{
			if (zp_class_human_get_count() > 1)
			{
				zp_class_human_show_menu(iPlayer);
			}

			else
			{
				zpe_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT_CLASSES_HUMAN_COLOR");
			}
		}

		case 4:
		{
			// Check if player is stuck
			if (LibraryExists(LIBRARY_RANDOM_SPAWN, LibType_Library) && BIT_VALID(g_iBit_Alive, iPlayer))
			{
				if (Is_Player_Stuck(iPlayer))
				{
					// Move to an initial spawn
					if (get_pcvar_num(g_pCvar_Random_Spawning_CSDM))
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
					zpe_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT_STUCK_COLOR");
				}
			}

			else
			{
				zpe_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "CMD_NOT_COLOR");
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
				zpe_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "NO_ADMIN_MENU_COLOR");
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

public zpe_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zpe_fw_spawn_post_bit_add(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}