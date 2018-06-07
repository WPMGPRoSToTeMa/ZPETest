/* AMX Mod X
*	[ZP] Painshockfree.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "painshockfree"
#define VERSION "5.1.4.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <ck_zp50_kernel>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_assassin>
#include <ck_zp50_class_survivor>
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

	g_pCvar_Painshockfree_Nemesis = register_cvar("zm_painshockfree_nemesis", "0");
	g_pCvar_Painshockfree_Assassin = register_cvar("zm_painshockfree_assassin", "0");
	g_pCvar_Painshockfree_Survivor = register_cvar("zm_painshockfree_survivor", "1");
	g_pCvar_Painshockfree_Sniper = register_cvar("zm_painshockfree_sniper", "1");
	
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_Post", 1);
}

public RG_CBasePlayer_TakeDamage_Post(iVictim)
{
	if (zp_core_is_zombie(iVictim))
	{
		// Nemesis Class loaded?
		if (zp_class_nemesis_get(iVictim))
		{
			if (!get_pcvar_num(g_pCvar_Painshockfree_Nemesis))
			{
				return;
			}
		}

		// Assassin Class loaded?
		else if (zp_class_assassin_get(iVictim))
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
		if (zp_class_survivor_get(iVictim))
		{
			if (!get_pcvar_num(g_pCvar_Painshockfree_Survivor))
			{
				return;
			}
		}

		// Sniper Class loaded?
		else if (zp_class_sniper_get(iVictim))
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