/* AMX Mod X
*	[ZP] Human Ammo.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "human ammo"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <hamsandwich>
#include <ck_zp50_kernel>
#include <ck_zp50_class_survivor>
#include <ck_zp50_class_sniper>

// Weapon id for ammo types
new const g_Ammo_Weapon[] =
{
	0,
	CSW_AWP,
	CSW_SCOUT,
	CSW_M249,
	CSW_AUG,
	CSW_XM1014,
	CSW_MAC10,
	CSW_FIVESEVEN,
	CSW_DEAGLE,
	CSW_P228,
	CSW_ELITE,
	CSW_FLASHBANG,
	CSW_HEGRENADE,
	CSW_SMOKEGRENADE,
	CSW_C4
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

// Max Clip for weapons
new const g_Max_Clip[] =
{
	-1,
	13,
	-1,
	10,
	-1,
	7,
	-1,
	30,
	30,
	-1,
	30,
	20,
	25,
	30,
	35,
	25,
	12,
	20,
	10,
	30,
	100,
	8,
	30,
	30,
	20,
	-1,
	7,
	30,
	30,
	-1,
	50
};

// BP Ammo Refill task
#define REFILL_WEAPONID iArgs[0]

new g_Message_Ammo_Pickup;

new g_pCvar_Human_Unlimited_Ammo;
new g_pCvar_Survivor_Unlimited_Ammo;
new g_pCvar_Sniper_Unlimited_Ammo;

new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Human_Unlimited_Ammo = register_cvar("zm_human_unlimited_ammo", "0"); // 1-bp ammo // 2-clip ammo

	g_pCvar_Survivor_Unlimited_Ammo = register_cvar("zm_survivor_unlimited_ammo", "1"); // 1-bp ammo // 2-clip ammo
	g_pCvar_Sniper_Unlimited_Ammo = register_cvar("zm_sniper_unlimited_ammo", "1"); // 1-bp ammo // 2-clip ammo

	register_event("AmmoX", "Event_Ammo_X", "be");

	register_message(get_user_msgid("CurWeapon"), "Message_Cur_Weapon");

	g_Message_Ammo_Pickup = get_user_msgid("AmmoPickup");
}

// BP Ammo update
public Event_Ammo_X(iPlayer)
{
	// Not alive or not human
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer) || zp_core_is_zombie(iPlayer))
	{
		return;
	}

	// Survivor Class loaded?
	if (zp_class_survivor_get(iPlayer))
	{
		// Unlimited BP ammo enabled for survivor?
		if (get_pcvar_num(g_pCvar_Survivor_Unlimited_Ammo) < 1)
		{
			return;
		}
	}

	// Sniper Class loaded?
	else if (zp_class_sniper_get(iPlayer))
	{
		// Unlimited BP ammo enabled for sniper?
		if (get_pcvar_num(g_pCvar_Sniper_Unlimited_Ammo) < 1)
		{
			return;
		}
	}

	else
	{
		// Unlimited BP ammo enabled for humans?
		if (get_pcvar_num(g_pCvar_Human_Unlimited_Ammo) < 1)
		{
			return;
		}
	}

	// Get ammo type
	new iType = read_data(1);

	// Unknown ammo type
	if (iType >= sizeof g_Ammo_Weapon)
	{
		return;
	}

	// Get weapon's player
	new iWeapon = g_Ammo_Weapon[iType];

	// Primary and secondary only
	if (g_Max_BP_Ammo[iWeapon] <= 2)
	{
		return;
	}

	// Get ammo amount
	new iAmount = read_data(2);

	// Unlimited BP Ammo
	if (iAmount < g_Max_BP_Ammo[iWeapon])
	{
		new iArgs[1];

		iArgs[0] = iWeapon;

		new iBlock_Status = get_msg_block(g_Message_Ammo_Pickup);

		set_msg_block(g_Message_Ammo_Pickup, BLOCK_ONCE);

		ExecuteHamB(Ham_GiveAmmo, iPlayer, g_Max_BP_Ammo[REFILL_WEAPONID], g_Ammo_Type[REFILL_WEAPONID], g_Max_BP_Ammo[REFILL_WEAPONID]);

		set_msg_block(g_Message_Ammo_Pickup, iBlock_Status);
	}
}

// Current Weapon info
public Message_Cur_Weapon(iMessage_ID, iMessage_Dest, iMessage_Entity)
{
	// Not alive or not human
	if (BIT_NOT_VALID(g_iBit_Alive, iMessage_Entity) || zp_core_is_zombie(iMessage_Entity))
	{
		return;
	}

	// Survivor Class loaded?
	if (zp_class_survivor_get(iMessage_Entity))
	{
		// Unlimited Clip ammo enabled for humans?
		if (get_pcvar_num(g_pCvar_Survivor_Unlimited_Ammo) < 2)
		{
			return;
		}
	}

	// Sniper Class loaded?
	else if (zp_class_sniper_get(iMessage_Entity))
	{
		// Unlimited Clip ammo enabled for humans?
		if (get_pcvar_num(g_pCvar_Sniper_Unlimited_Ammo) < 2)
		{
			return;
		}
	}

	else
	{
		// Unlimited Clip ammo enabled for humans?
		if (get_pcvar_num(g_pCvar_Human_Unlimited_Ammo) < 2)
		{
			return;
		}
	}

	// Not an active weapon
	if (get_msg_arg_int(1) != 1)
	{
		return;
	}

	// Get weapon's player
	new iWeapon = get_msg_arg_int(2);

	// Primary and secondary only
	if (g_Max_BP_Ammo[iWeapon] <= 2)
	{
		return;
	}

	// Max out clip ammo
	new iWeapon_Entity = CS_GET_CURRENT_WEAPON_ENTITY(iMessage_Entity);

	if (is_entity(iWeapon_Entity)) // pev_valid
	{
		CS_SET_WEAPON_AMMO(iWeapon_Entity, g_Max_Clip[iWeapon]);
	}

	// HUD should show full clip all the time
	set_msg_arg_int(3, get_msg_argtype(3), g_Max_Clip[iWeapon]);
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