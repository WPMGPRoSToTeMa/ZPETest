/* AMX Mod X
*	[ZP] Rewards Ammopacks.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "rewards ammopacks"
#define VERSION "5.1.8.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <ck_zp50_kernel>
#include <ck_zp50_gamemodes>

#define LIBRARY_NEMESIS "ck_zp50_class_nemesis"
#include <ck_zp50_class_nemesis>

#define LIBRARY_ASSASSIN "ck_zp50_class_assassin"
#include <ck_zp50_class_assassin>

#define LIBRARY_SURVIVOR "ck_zp50_class_survivor"
#include <ck_zp50_class_survivor>

#define LIBRARY_SNIPER "ck_zp50_class_sniper"
#include <ck_zp50_class_sniper>

#include <ck_zp50_ammopacks>

new Float:g_fDamage_Dealt_To_Zombies[MAX_PLAYERS + 1];
new Float:g_fDamage_Dealt_To_Humans[MAX_PLAYERS + 1];

new g_pCvar_Ammo_Packs_For_Winner;
new g_pCvar_Ammo_Packs_For_Looser;

new g_pCvar_Ammo_Packs_Damage;
new g_pCvar_Ammo_Packs_Zombie_Damaged_HP;
new g_pCvar_Ammo_Packs_Human_Damaged_HP;

new g_pCvar_Ammo_Packs_Zombie_Killed;
new g_pCvar_Ammo_Packs_Human_Killed;

new g_pCvar_Ammo_Packs_Human_Infected;

new g_pCvar_Ammo_Packs_Nemesis_Ignore;
new g_pCvar_Ammo_Packs_Assassin_Ignore;
new g_pCvar_Ammo_Packs_Survivor_Ignore;
new g_pCvar_Ammo_Packs_Sniper_Ignore;

new g_iBit_Connected;
new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Ammo_Packs_For_Winner = register_cvar("zm_ammo_packs_winner", "3");
	g_pCvar_Ammo_Packs_For_Looser = register_cvar("zm_ammo_packs_loser", "1");

	g_pCvar_Ammo_Packs_Damage = register_cvar("zm_ammo_packs_damage", "1");
	g_pCvar_Ammo_Packs_Zombie_Damaged_HP = register_cvar("zm_ammo_packs_zombie_damaged_hp", "500");
	g_pCvar_Ammo_Packs_Human_Damaged_HP = register_cvar("zm_ammo_packs_human_damaged_hp", "250");

	g_pCvar_Ammo_Packs_Zombie_Killed = register_cvar("zm_ammo_packs_zombie_killed", "1");
	g_pCvar_Ammo_Packs_Human_Killed = register_cvar("zm_ammo_packs_human_killed", "1");

	g_pCvar_Ammo_Packs_Human_Infected = register_cvar("zm_ammo_packs_human_infected", "1");

	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
	{
		g_pCvar_Ammo_Packs_Nemesis_Ignore = register_cvar("zm_ammo_packs_nemesis_ignore", "0");
	}

	// Assassin Class loaded?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
	{
		g_pCvar_Ammo_Packs_Assassin_Ignore = register_cvar("zm_ammo_packs_assassin_ignore", "0");
	}

	// Survivor Class loaded?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
	{
		g_pCvar_Ammo_Packs_Survivor_Ignore = register_cvar("zm_ammo_packs_survivor_ignore", "0");
	}

	// Sniper Class loaded?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
	{
		g_pCvar_Ammo_Packs_Sniper_Ignore = register_cvar("zm_ammo_packs_sniper_ignore", "0");
	}

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_Post", 1);
	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_Post", 1);
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

public zp_fw_core_infect_post(iPlayer, iAttacker)
{
	// Reward ammo packs to zombies infecting humans?
	if (BIT_VALID(g_iBit_Connected, iAttacker) && iAttacker != iPlayer && get_pcvar_num(g_pCvar_Ammo_Packs_Human_Infected) > 0)
	{
		zp_ammopacks_set(iAttacker, zp_ammopacks_get(iAttacker) + get_pcvar_num(g_pCvar_Ammo_Packs_Human_Infected));
	}
}

public RG_CBasePlayer_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:fDamage, iDamage_Type)
{
	// Non-player damage or self damage
	if (iVictim == iAttacker || iAttacker > 32 || BIT_NOT_VALID(g_iBit_Alive, iAttacker))
	{
		return;
	}

	// Ignore ammo pack rewards for Nemesis?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(iAttacker) && get_pcvar_num(g_pCvar_Ammo_Packs_Nemesis_Ignore))
	{
		return;
	}

	// Ignore ammo pack rewards for Assassin?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(iAttacker) && get_pcvar_num(g_pCvar_Ammo_Packs_Assassin_Ignore))
	{
		return;
	}

	// Ignore ammo pack rewards for Survivor?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(iAttacker) && get_pcvar_num(g_pCvar_Ammo_Packs_Survivor_Ignore))
	{
		return;
	}

	// Ignore ammo pack rewards for Sniper?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(iAttacker) && get_pcvar_num(g_pCvar_Ammo_Packs_Sniper_Ignore))
	{
		return;
	}

	// Zombie attacking human...
	if (zp_core_is_zombie(iAttacker) && !zp_core_is_zombie(iVictim))
	{
		// Reward ammo packs to zombies for damaging humans?
		if (get_pcvar_num(g_pCvar_Ammo_Packs_Damage) > 0)
		{
			// Store damage dealt
			g_fDamage_Dealt_To_Humans[iAttacker] += fDamage;

			// Give rewards according to damage dealt
			new iHow_Many_Rewards = floatround(g_fDamage_Dealt_To_Humans[iAttacker] / get_pcvar_float(g_pCvar_Ammo_Packs_Human_Damaged_HP), floatround_floor);

			if (iHow_Many_Rewards > 0)
			{
				zp_ammopacks_set(iAttacker, zp_ammopacks_get(iAttacker) + (get_pcvar_num(g_pCvar_Ammo_Packs_Damage) * iHow_Many_Rewards));

				g_fDamage_Dealt_To_Humans[iAttacker] -= get_pcvar_float(g_pCvar_Ammo_Packs_Human_Damaged_HP) * iHow_Many_Rewards;
			}
		}
	}

	// Human attacking zombie...
	else if (!zp_core_is_zombie(iAttacker) && zp_core_is_zombie(iVictim))
	{
		// Reward ammo packs to humans for damaging zombies?
		if (get_pcvar_num(g_pCvar_Ammo_Packs_Damage) > 0)
		{
			// Store damage dealt
			g_fDamage_Dealt_To_Zombies[iAttacker] += fDamage;

			// Give rewards according to damage dealt
			new iHow_Many_Rewards = floatround(g_fDamage_Dealt_To_Zombies[iAttacker] / get_pcvar_float(g_pCvar_Ammo_Packs_Zombie_Damaged_HP), floatround_floor);

			if (iHow_Many_Rewards > 0)
			{
				zp_ammopacks_set(iAttacker, zp_ammopacks_get(iAttacker) + (get_pcvar_num(g_pCvar_Ammo_Packs_Damage) * iHow_Many_Rewards));

				g_fDamage_Dealt_To_Zombies[iAttacker] -= get_pcvar_float(g_pCvar_Ammo_Packs_Zombie_Damaged_HP) * iHow_Many_Rewards;
			}
		}
	}
}

public RG_CSGameRules_PlayerKilled_Post(iVictim, iAttacker)
{
	// Non-player kill or self kill
	if (iVictim == iAttacker || BIT_NOT_VALID(g_iBit_Connected, iAttacker))
	{
		return;
	}

	// Ignore ammo pack rewards for Nemesis?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(iAttacker) && get_pcvar_num(g_pCvar_Ammo_Packs_Nemesis_Ignore))
	{
		return;
	}

	// Ignore ammo pack rewards for Assassin?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(iAttacker) && get_pcvar_num(g_pCvar_Ammo_Packs_Assassin_Ignore))
	{
		return;
	}
	
	// Ignore ammo pack rewards for Survivor?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(iAttacker) && get_pcvar_num(g_pCvar_Ammo_Packs_Survivor_Ignore))
	{
		return;
	}
	
	// Ignore ammo pack rewards for Sniper?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(iAttacker) && get_pcvar_num(g_pCvar_Ammo_Packs_Sniper_Ignore))
	{
		return;
	}
	
	// Reward ammo packs to attacker for the kill
	if (zp_core_is_zombie(iVictim))
	{
		zp_ammopacks_set(iAttacker, zp_ammopacks_get(iAttacker) + get_pcvar_num(g_pCvar_Ammo_Packs_Zombie_Killed));
	}

	else
	{
		zp_ammopacks_set(iAttacker, zp_ammopacks_get(iAttacker) + get_pcvar_num(g_pCvar_Ammo_Packs_Human_Killed));
	}
}

public zp_fw_gamemodes_end()
{
	// Determine round winner and money rewards
	if (!zp_core_get_zombie_count())
	{
		// Human team wins
		for (new i = 1; i <= MaxClients; i++)
		{
			if (BIT_NOT_VALID(g_iBit_Connected, i))
			{
				continue;
			}

			if (zp_core_is_zombie(i))
			{
				zp_ammopacks_set(i, zp_ammopacks_get(i) + get_pcvar_num(g_pCvar_Ammo_Packs_For_Looser));
			}

			else
			{
				zp_ammopacks_set(i, zp_ammopacks_get(i) + get_pcvar_num(g_pCvar_Ammo_Packs_For_Winner));
			}
		}
	}

	else if (!zp_core_get_human_count())
	{
		// Zombie team wins
		for (new i = 1; i <= MaxClients; i++)
		{
			if (BIT_NOT_VALID(g_iBit_Connected, i))
			{
				continue;
			}

			if (zp_core_is_zombie(i))
			{
				zp_ammopacks_set(i, zp_ammopacks_get(i) + get_pcvar_num(g_pCvar_Ammo_Packs_For_Winner));
			}

			else
			{
				zp_ammopacks_set(i, zp_ammopacks_get(i) + get_pcvar_num(g_pCvar_Ammo_Packs_For_Looser));
			}
		}
	}

	else
	{
		// No one wins
		for (new i = 1; i <= MaxClients; i++)
		{
			if (BIT_NOT_VALID(g_iBit_Connected, i))
			{
				continue;
			}

			zp_ammopacks_set(i, zp_ammopacks_get(i) + get_pcvar_num(g_pCvar_Ammo_Packs_For_Looser));
		}
	}
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	// Clear damage after disconnecting
	g_fDamage_Dealt_To_Zombies[iPlayer] = 0.0;
	g_fDamage_Dealt_To_Humans[iPlayer] = 0.0;

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