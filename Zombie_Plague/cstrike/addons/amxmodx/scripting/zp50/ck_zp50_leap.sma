/* AMX Mod X
*	[ZP] Leap.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "leap"
#define VERSION "5.2.9.1"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <fun>
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

new Float:g_fLeap_Last_Time[MAX_PLAYERS + 1];

new g_pCvar_Leap_Zombie;
new g_pCvar_Leap_Zombie_Force;
new g_pCvar_Leap_Zombie_Height;
new g_pCvar_Leap_Zombie_Cooldown;

new g_pCvar_Leap_Nemesis;
new g_pCvar_Leap_Nemesis_Force;
new g_pCvar_Leap_Nemesis_Height;
new g_pCvar_Leap_Nemesis_Cooldown;

new g_pCvar_Leap_Assassin;
new g_pCvar_Leap_Assassin_Force;
new g_pCvar_Leap_Assassin_Height;
new g_pCvar_Leap_Assassin_Cooldown;

new g_pCvar_Leap_Survivor;
new g_pCvar_Leap_Survivor_Force;
new g_pCvar_Leap_Survivor_Height;
new g_pCvar_Leap_Survivor_Cooldown;

new g_pCvar_Leap_Sniper;
new g_pCvar_Leap_Sniper_Force;
new g_pCvar_Leap_Sniper_Height;
new g_pCvar_Leap_Sniper_Cooldown;

new g_Game_Mode_Infection_ID;

new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Leap_Zombie = register_cvar("zm_leap_zombie", "3"); // 1-all // 2-first only // 3-last only
	g_pCvar_Leap_Zombie_Force = register_cvar("zm_leap_zombie_force", "500");
	g_pCvar_Leap_Zombie_Height = register_cvar("zm_leap_zombie_height", "300");
	g_pCvar_Leap_Zombie_Cooldown = register_cvar("zm_leap_zombie_cooldown", "10.0");

	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
	{
		g_pCvar_Leap_Nemesis = register_cvar("zm_leap_nemesis", "1");
		g_pCvar_Leap_Nemesis_Force = register_cvar("zm_leap_nemesis_force", "500");
		g_pCvar_Leap_Nemesis_Height = register_cvar("zm_leap_nemesis_height", "300");
		g_pCvar_Leap_Nemesis_Cooldown = register_cvar("zm_leap_nemesis_cooldown", "5.0");
	}

	// Assassin Class loaded?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
	{
		g_pCvar_Leap_Assassin = register_cvar("zm_leap_assassin", "1");
		g_pCvar_Leap_Assassin_Force = register_cvar("zm_leap_assassin_force", "500");
		g_pCvar_Leap_Assassin_Height = register_cvar("zm_leap_assassin_height", "300");
		g_pCvar_Leap_Assassin_Cooldown = register_cvar("zm_leap_assassin_cooldown", "5.0");
	}

	// Survivor Class loaded?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
	{
		g_pCvar_Leap_Survivor = register_cvar("zm_leap_survivor", "0");
		g_pCvar_Leap_Survivor_Force = register_cvar("zm_leap_survivor_force", "500");
		g_pCvar_Leap_Survivor_Height = register_cvar("zm_leap_survivor_height", "300");
		g_pCvar_Leap_Survivor_Cooldown = register_cvar("zm_leap_survivor_cooldown", "5.0");
	}

	// Sniper Class loaded?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
	{
		g_pCvar_Leap_Sniper = register_cvar("zm_leap_sniper", "0");
		g_pCvar_Leap_Sniper_Force = register_cvar("zm_leap_sniper_force", "500");
		g_pCvar_Leap_Sniper_Height = register_cvar("zm_leap_sniper_height", "300");
		g_pCvar_Leap_Sniper_Cooldown = register_cvar("zm_leap_sniper_cooldown", "5.0");
	}
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

public plugin_cfg()
{
	g_Game_Mode_Infection_ID = zp_gamemodes_get_id("Infection Mode");
}

public fw_button_changed(iPlayer, iPressed, iUnpressed)
{
	// Not alive
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer) || !zp_core_is_zombie(iPlayer))
	{
		return;
	}

	// Don't allow leap if player is frozen (e.g. freezetime)
	if (get_user_maxspeed(iPlayer) == 1.0)
	{
		return;
	}

	static Float:fCooldown;

	new iForce;
	new Float:fHeight;

	// Nemesis class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(iPlayer))
	{
		if (!get_pcvar_num(g_pCvar_Leap_Nemesis))
		{
			return;
		}

		fCooldown = get_pcvar_float(g_pCvar_Leap_Nemesis_Cooldown);
		iForce = get_pcvar_num(g_pCvar_Leap_Nemesis_Force);
		fHeight = get_pcvar_float(g_pCvar_Leap_Nemesis_Height);
	}

	// Assassin Class loaded?
	else if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(iPlayer))
	{
		// Check if assassin should leap
		if (!get_pcvar_num(g_pCvar_Leap_Assassin))
		{
			return;
		}

		fCooldown = get_pcvar_float(g_pCvar_Leap_Assassin_Cooldown);
		iForce = get_pcvar_num(g_pCvar_Leap_Assassin_Force);
		fHeight = get_pcvar_float(g_pCvar_Leap_Assassin_Height);
	}

	// Survivor Class loaded?
	else if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(iPlayer))
	{
		// Check if survivor should leap
		if (!get_pcvar_num(g_pCvar_Leap_Survivor))
		{
			return;
		}

		fCooldown = get_pcvar_float(g_pCvar_Leap_Survivor_Cooldown);
		iForce = get_pcvar_num(g_pCvar_Leap_Survivor_Force);
		fHeight = get_pcvar_float(g_pCvar_Leap_Survivor_Height);
	}

	// Sniper Class loaded?
	else if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(iPlayer))
	{
		// Check if sniper should leap
		if (!get_pcvar_num(g_pCvar_Leap_Sniper))
		{
			return;
		}

		fCooldown = get_pcvar_float(g_pCvar_Leap_Sniper_Cooldown);
		iForce =  get_pcvar_num(g_pCvar_Leap_Sniper_Force);
		fHeight = get_pcvar_float(g_pCvar_Leap_Sniper_Height);
	}

	else
	{
		// Not a zombie
		if (!zp_core_is_zombie(iPlayer))
		{
			return;
		}

		// Check if zombie should leap
		switch (get_pcvar_num(g_pCvar_Leap_Zombie))
		{
			// Disabled
			case 0:
			{
				return;
			}

			// First zombie (only on infection rounds)
			case 2:
			{
				if (!zp_core_is_first_zombie(iPlayer) || (zp_gamemodes_get_current() != g_Game_Mode_Infection_ID))
				{
					return;
				}
			}

			// Last zombie
			case 3:
			{
				if (!zp_core_is_last_zombie(iPlayer))
				{
					return;
				}
			}
		}

		fCooldown = get_pcvar_float(g_pCvar_Leap_Zombie_Cooldown);
		iForce = get_pcvar_num(g_pCvar_Leap_Zombie_Force);
		fHeight = get_pcvar_float(g_pCvar_Leap_Zombie_Height);
	}

	static Float:fCurrent_Time;

	fCurrent_Time = get_gametime();

	// Cooldown not over yet
	if (fCurrent_Time - g_fLeap_Last_Time[iPlayer] < fCooldown)
	{
		return;
	}

	new iCurrent = get_entvar(iPlayer, var_button);

	// Doing a longjump
	if (!(iCurrent & IN_DUCK && iPressed & IN_JUMP))
	{
		return;
	}

	// Not on ground or not enough speed
	if (!(get_entvar(iPlayer, var_flags) & FL_ONGROUND) || _fm_get_speed(iPlayer) < 80)
	{
		return;
	}

	static Float:fVelocity[3];

	// Make velocity vector
	velocity_by_aim(iPlayer, iForce, fVelocity);

	// Set custom height
	fVelocity[2] = fHeight;

	// Apply the new velocity
	set_entvar(iPlayer, var_velocity, fVelocity);

	// Update last leap time
	g_fLeap_Last_Time[iPlayer] = fCurrent_Time;
}

public client_disconnected(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}