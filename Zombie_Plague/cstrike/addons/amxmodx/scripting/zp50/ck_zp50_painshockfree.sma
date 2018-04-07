/* AMX Mod X
*	[ZP] Painshockfree.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "painshockfree"
#define VERSION "5.1.4.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <ck_zp50_kernel>

#define LIBRARY_NEMESIS "ck_zp50_class_nemesis"
#include <ck_zp50_class_nemesis>

#define LIBRARY_ASSASSIN "ck_zp50_class_assassin"
#include <ck_zp50_class_assassin>

#define LIBRARY_SURVIVOR "ck_zp50_class_survivor"
#include <ck_zp50_class_survivor>

#define LIBRARY_SNIPER "ck_zp50_class_sniper"
#include <ck_zp50_class_sniper>

new g_pCvar_Painshockfree_Zombie;
new g_pCvar_Painshockfree_Human;
new g_pCvar_Painshockfree_Nemesis;
new g_pCvar_Painshockfree_Assassin;
new g_pCvar_Painshockfree_Survivor;
new g_pCvar_Painshockfree_Sniper;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Painshockfree_Zombie = register_cvar("zm_painshockfree_zombie", "1"); // 1-all // 2-first only // 3-last only
	g_pCvar_Painshockfree_Human = register_cvar("zm_painshockfree_human", "0"); // 1-all // 2-last only

	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
	{
		g_pCvar_Painshockfree_Nemesis = register_cvar("zm_painshockfree_nemesis", "0");
	}

	// Assassin Class loaded?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
	{
		g_pCvar_Painshockfree_Assassin = register_cvar("zm_painshockfree_assassin", "0");
	}

	// Survivor Class loaded?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
	{
		g_pCvar_Painshockfree_Survivor = register_cvar("zm_painshockfree_survivor", "1");
	}

	// Sniper Class loaded?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
	{
		g_pCvar_Painshockfree_Sniper = register_cvar("zm_painshockfree_sniper", "1");
	}

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_Post", 1);
}

public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const szModule[])
{
	if (equal(szModule, LIBRARY_NEMESIS) || equal(szModule, LIBRARY_ASSASSIN) || equal(szModule, LIBRARY_SURVIVOR) || equal(szModule, LIBRARY_SNIPER))
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

public RG_CBasePlayer_TakeDamage_Post(iVictim)
{
	if (zp_core_is_zombie(iVictim))
	{
		// Nemesis Class loaded?
		if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(iVictim))
		{
			if (!get_pcvar_num(g_pCvar_Painshockfree_Nemesis))
			{
				return;
			}
		}

		// Assassin Class loaded?
		else if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(iVictim))
		{
			if (!get_pcvar_num(g_pCvar_Painshockfree_Assassin))
			{
				return;
			}
		}

		// Check if zombie should be pain shock free
		else
		{
			// Check if zombie should be pain shock free
			switch (get_pcvar_num(g_pCvar_Painshockfree_Zombie))
			{
				case 0:
				{
					return;
				}

				case 2:
				{
					if (!zp_core_is_first_zombie(iVictim))
					{
						return;
					}
				}

				case 3:
				{
					if (!zp_core_is_last_zombie(iVictim))
					{
						return;
					}
				}
			}
		}
	}

	else
	{
		// Survivor class loaded?
		if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(iVictim))
		{
			if (!get_pcvar_num(g_pCvar_Painshockfree_Survivor))
			{
				return;
			}
		}

		// Sniper Class loaded?
		else if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(iVictim))
		{
			if (!get_pcvar_num(g_pCvar_Painshockfree_Sniper))
			{
				return;
			}
		}

		else
		{
			// Check if human should be pain shock free
			switch (get_pcvar_num(g_pCvar_Painshockfree_Human))
			{
				case 0:
				{
					return;
				}

				case 2:
				{
					if (!zp_core_is_last_human(iVictim))
					{
						return;
					}
				}
			}
		}
	}

	// Set pain shock free offset
	set_member(iVictim, m_flVelocityModifier, 1.0); // OFFSET_PAINSHOCK
}