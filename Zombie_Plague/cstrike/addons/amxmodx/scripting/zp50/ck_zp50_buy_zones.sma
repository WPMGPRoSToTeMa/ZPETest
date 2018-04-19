/* AMX Mod X
*	[ZP] Buy Zones.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "buy zones"
#define VERSION "5.2.6.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

new const g_Sound_Buy_Ammo[][] =
{
	"items/9mmclip1.wav"
};

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <hamsandwich>
#include <ck_zp50_kernel>

#define LIBRARY_SURVIVOR "ck_zp50_class_survivor"
#include <ck_zp50_class_survivor>

#define LIBRARY_SNIPER "ck_zp50_class_sniper"
#include <ck_zp50_class_sniper>

#define LIBRARY_AMMOPACKS "ck_zp50_ammopacks"
#include <ck_zp50_ammopacks>

#define SOUND_MAX_LENGTH 64

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

// Amount of ammo to give when buying additional clips for weapons
new const g_Buy_Ammo[] =
{
	-1,
	13,
	-1,
	30,
	-1,
	8,
	-1,
	12,
	30,
	-1,
	30,
	50,
	12,
	30,
	30,
	30,
	12,
	30,
	10,
	30,
	30,
	8,
	30,
	30,
	30,
	-1,
	7,
	30,
	30,
	-1,
	50
};

// Ammo type names for weapons
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

new Float:g_fBuy_Time_Start[MAX_PLAYERS + 1];

new Array:g_aSound_Buy_Ammo;

new g_fwSpawn;

new g_Buyzone_Entity;

new g_pCvar_Buyzone_Time;
new g_pCvar_Buyzone_Humans;
new g_pCvar_Buyzone_Zombies;

new g_pCvar_Buy_Ammo_Human;
new g_pCvar_Buy_Ammo_Cost_Ammopacks;
new g_pCvar_Buy_Ammo_Cost_Money;

new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Buyzone_Time = register_cvar("zm_buy_zone_time", "15.0");
	g_pCvar_Buyzone_Humans = register_cvar("zm_buy_zone_humans", "1");
	g_pCvar_Buyzone_Zombies = register_cvar("zm_buy_zone_zombies", "0");

	g_pCvar_Buy_Ammo_Human = register_cvar("zm_buy_ammo_human", "1");
	g_pCvar_Buy_Ammo_Cost_Ammopacks = register_cvar("zm_buy_ammo_cost_ammopacks", "1");
	g_pCvar_Buy_Ammo_Cost_Money = register_cvar("zm_buy_ammo_cost_money", "100");

	unregister_forward(FM_Spawn, g_fwSpawn);

	RegisterHookChain(RG_CBasePlayer_PreThink, "RG_CBasePlayer_PreThink_");

	// Client commands
	register_clcmd("buyammo1", "Client_Command_Buyammo");
	register_clcmd("buyammo2", "Client_Command_Buyammo");
}

public plugin_precache()
{
	// Initialize arrays
	g_aSound_Buy_Ammo = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "BUY AMMO", g_aSound_Buy_Ammo);

	if (ArraySize(g_aSound_Buy_Ammo) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Buy_Ammo; i++)
		{
			ArrayPushString(g_aSound_Buy_Ammo, g_Sound_Buy_Ammo[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "BUY AMMO", g_aSound_Buy_Ammo);
	}

	// Custom buyzones for all players
	g_Buyzone_Entity = rg_create_entity("func_buyzone");

	if (is_entity(g_Buyzone_Entity))
	{
		dllfunc(DLLFunc_Spawn, g_Buyzone_Entity);

		set_entvar(g_Buyzone_Entity, var_solid, SOLID_NOT);
	}

	if (!is_entity(g_Buyzone_Entity))
	{
		set_fail_state("Unable to spawn custom buyzones.");

		return;
	}

	// Prevent some entities from spawning
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn");

	// Precache sounds
	for (new i = 0; i < sizeof g_Sound_Buy_Ammo; i++)
	{
		precache_sound(g_Sound_Buy_Ammo[i]);
	}
}

public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const szModule[])
{
	if (equal(szModule, LIBRARY_SURVIVOR) || equal(szModule, LIBRARY_SNIPER) || equal(szModule, LIBRARY_AMMOPACKS))
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
	// Prevents CS buytime messing up ZP buytime cvar
	server_cmd("mp_buytime 99");
}

// Entity Spawn Forward
public fw_Spawn(iEntity)
{
	// Invalid entity
	if (!is_entity(iEntity))
	{
		return FMRES_IGNORED;
	}

	// Get classname
	new szClassname[32];

	get_entvar(iEntity, var_classname, szClassname, charsmax(szClassname));

	// Check whether it needs to be removed
	if (equal(szClassname, "func_buyzone"))
	{
		engfunc(EngFunc_RemoveEntity, iEntity);

		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public zp_fw_core_cure_post(iPlayer)
{
	if (get_pcvar_num(g_pCvar_Buyzone_Humans) && (!LibraryExists(LIBRARY_SURVIVOR, LibType_Library) || !zp_class_survivor_get(iPlayer)) && (!LibraryExists(LIBRARY_SNIPER, LibType_Library) || !zp_class_sniper_get(iPlayer)))
	{
		// Buyzones time starts when player is set to human
		g_fBuy_Time_Start[iPlayer] = get_gametime();
	}

	else
	{
		// Buyzones time ends when player is set to human/survivor/sniper
		g_fBuy_Time_Start[iPlayer] = get_gametime() - get_pcvar_float(g_pCvar_Buyzone_Time);
	}
}

public zp_fw_core_infect_post(iPlayer)
{
	if (get_pcvar_num(g_pCvar_Buyzone_Zombies))
	{
		// Buyzones time starts when player is set to zombie
		g_fBuy_Time_Start[iPlayer] = get_gametime();
	}

	else
	{
		// Buyzones time ends when player is set to zombie
		g_fBuy_Time_Start[iPlayer] = get_gametime() - get_pcvar_float(g_pCvar_Buyzone_Time);
	}
}

// Player PreThink
public RG_CBasePlayer_PreThink_(iPlayer)
{
	// Not alive
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		return;
	}

	// Enable custom buyzones for player during buytime, unless time expired
	if (get_gametime() < g_fBuy_Time_Start[iPlayer] + get_pcvar_float(g_pCvar_Buyzone_Time))
	{
		dllfunc(DLLFunc_Touch, g_Buyzone_Entity, iPlayer);
	}

	else if (get_member_game(m_bMapHasBuyZone))
	{
		set_member_game(m_bMapHasBuyZone, true);
	}
}

// Buy BP Ammo
public Client_Command_Buyammo(iPlayer)
{
	// Setting disabled, player dead or zombie
	if (!get_pcvar_num(g_pCvar_Buy_Ammo_Human) || BIT_NOT_VALID(g_iBit_Alive, iPlayer) || zp_core_is_zombie(iPlayer))
	{
		return;
	}

	// Player standing in buyzones, allow buying weapon's ammo normally instead
	if ((get_gametime() < g_fBuy_Time_Start[iPlayer] + get_pcvar_float(g_pCvar_Buyzone_Time)) && get_member_game(m_bMapHasBuyZone, iPlayer))
	{
		return;
	}

	// Not enough money/ammo packs
	if (LibraryExists(LIBRARY_AMMOPACKS, LibType_Library))
	{
		if (zp_ammopacks_get(iPlayer) < get_pcvar_num(g_pCvar_Buy_Ammo_Cost_Ammopacks))
		{
			zp_client_print_color(iPlayer, print_team_default, "%L (%L)", iPlayer, "NOT_ENOUGH_AMMO", iPlayer, "REQUIRED_AMOUNT", get_pcvar_num(g_pCvar_Buy_Ammo_Cost_Ammopacks));

			return;
		}
	}

	else
	{
		if (CS_GET_USER_MONEY(iPlayer) < get_pcvar_num(g_pCvar_Buy_Ammo_Cost_Money))
		{
			zp_client_print_color(iPlayer, print_team_default, "%L (%L)", iPlayer, "NOT_ENOUGH_MONEY", iPlayer, "REQUIRED_AMOUNT", get_pcvar_num(g_pCvar_Buy_Ammo_Cost_Money));

			return;
		}
	}

	// Get user weapons
	new iBpammo_Before;
	new iRefilled;

	new iWeapons = get_entvar(iPlayer, var_weapons) & ~(1 << 31); // get_user_weapons

	// Loop through them and give the right ammo type
	for (new i = 1; i < 32; i++)
	{
		if ((iWeapons & (1 << i)) && g_Max_BP_Ammo[i] > 2)
		{
			iBpammo_Before = rg_get_user_bpammo(iPlayer, WeaponIdType:i);

			// Give additional ammo
			ExecuteHamB(Ham_GiveAmmo, iPlayer, g_Buy_Ammo[i], g_Ammo_Type[i], g_Max_BP_Ammo[i]);

			// Check whether we actually refilled the weapon's ammo
			if (rg_get_user_bpammo(iPlayer, WeaponIdType:i) - iBpammo_Before > 0)
			{
				iRefilled = true;
			}
		}
	}

	// Weapons already have full ammo
	if (!iRefilled)
	{
		return;
	}

	// Deduce cost
	if (LibraryExists(LIBRARY_AMMOPACKS, LibType_Library))
	{
		zp_ammopacks_set(iPlayer, zp_ammopacks_get(iPlayer) - get_pcvar_num(g_pCvar_Buy_Ammo_Cost_Ammopacks));
	}

	else
	{
		rg_add_account(iPlayer, - get_pcvar_num(g_pCvar_Buy_Ammo_Cost_Money), AS_ADD);
	}

	// Play clip purchase sound, and notify player
	emit_sound(iPlayer, CHAN_VOICE, g_Sound_Buy_Ammo[random_num(0, sizeof g_Sound_Buy_Ammo - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM);

	zp_client_print_color(iPlayer, print_team_default, "%L", iPlayer, "AMMO_BOUGHT");
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