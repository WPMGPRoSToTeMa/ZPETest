/* AMX Mod X
*	[ZPE] Kernel.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	https://git.ckcorp.ru/ck/amxx-modes/zpe - development.
*
*	Support is provided only on the site.
*/

#define PLUGIN "kernel"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <ck_cs_common_bits_api>
#include <zpe_kernel>

// Custom Forwards
enum TOTAL_FORWARDS
{
	FW_USER_INFECT_PRE = 0,
	FW_USER_INFECT,
	FW_USER_INFECT_POST,
	FW_USER_CURE_PRE,
	FW_USER_CURE,
	FW_USER_CURE_POST,
	FW_USER_LAST_ZOMBIE,
	FW_USER_LAST_HUMAN,
	FW_USER_SPAWN_POST
};

new g_Last_Zombie_Forward_Called;
new g_Last_Human_Forward_Called;

new g_Respawn_As_Zombie;

new g_Forward_Result;
new g_Forwards[TOTAL_FORWARDS];

new g_iBvar_Zombie;
new g_iBvar_First_Zombie;
new g_iBvar_Last_Zombie;
new g_iBvar_Last_Human;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_dictionary("zombie_plague_enterprise.txt");

	g_iBvar_Zombie = get_bvar_id("iBit_Zombie");
	g_iBvar_First_Zombie = get_bvar_id("iBit_First_Zombie");
	g_iBvar_Last_Zombie = get_bvar_id("iBit_Last_Zombie");
	g_iBvar_Last_Human = get_bvar_id("iBit_Last_Human");

	g_Forwards[FW_USER_INFECT_PRE] = CreateMultiForward("zpe_fw_core_infect_pre", ET_CONTINUE, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_INFECT] = CreateMultiForward("zpe_fw_core_infect", ET_IGNORE, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_INFECT_POST] = CreateMultiForward("zpe_fw_core_infect_post", ET_IGNORE, FP_CELL, FP_CELL);

	g_Forwards[FW_USER_CURE_PRE] = CreateMultiForward("zpe_fw_core_cure_pre", ET_CONTINUE, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_CURE] = CreateMultiForward("zpe_fw_core_cure", ET_IGNORE, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_CURE_POST] = CreateMultiForward("zpe_fw_core_cure_post", ET_IGNORE, FP_CELL, FP_CELL);

	g_Forwards[FW_USER_LAST_ZOMBIE] = CreateMultiForward("zpe_fw_core_last_zombie", ET_IGNORE, FP_CELL);
	g_Forwards[FW_USER_LAST_HUMAN] = CreateMultiForward("zpe_fw_core_last_human", ET_IGNORE, FP_CELL);

	g_Forwards[FW_USER_SPAWN_POST] = CreateMultiForward("zpe_fw_core_spawn_post", ET_IGNORE, FP_CELL);

	RegisterHookChain(RG_CSGameRules_PlayerSpawn, "RG_CSGameRules_PlayerSpawn_Post", 1);
	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_Post", 1);

	register_forward(FM_ClientDisconnect, "FM_ClientDisconnect_Post", 1)
}

public plugin_cfg()
{
	server_cmd("exec addons/amxmodx/configs/ZPE/zpe_settings.cfg");
}

public plugin_natives()
{
	register_library("zpe_kernel");

	register_native("zpe_core_get_zombie_count", "native_core_get_zombie_count");
	register_native("zpe_core_get_human_count", "native_core_get_human_count");
	register_native("zpe_core_infect", "native_core_infect");
	register_native("zpe_core_cure", "native_core_cure");
	register_native("zpe_core_force_infect", "native_core_force_infect");
	register_native("zpe_core_force_cure", "native_core_force_cure");
	register_native("zpe_core_respawn_as_zombie", "native_core_respawn_as_zombie");
}

public RG_CSGameRules_PlayerSpawn_Post(iPlayer)
{
	// Not connected
	if (!is_player_connected(iPlayer))
	{
		return HC_CONTINUE;
	}

	// ZPE Spawn Forward
	ExecuteForward(g_Forwards[FW_USER_SPAWN_POST], g_Forward_Result, iPlayer);

	// Set zombie/human attributes upon respawn
	if (BIT_VALID(g_Respawn_As_Zombie, iPlayer))
	{
		Infect_Player(iPlayer, iPlayer);
	}

	else
	{
		Cure_Player(iPlayer);
	}

	// Reset flag afterwards
	BIT_SUB(g_Respawn_As_Zombie, iPlayer);

	return HC_CONTINUE;
}

public RG_CSGameRules_PlayerKilled_Post(iPlayer)
{
	Check_Last_Zombie_And_Human();
}

Infect_Player(iPlayer, iAttacker = 0)
{
	ExecuteForward(g_Forwards[FW_USER_INFECT_PRE], g_Forward_Result, iPlayer, iAttacker);

	// One or more plugins blocked infection
	if (g_Forward_Result >= PLUGIN_HANDLED)
	{
		return;
	}

	ExecuteForward(g_Forwards[FW_USER_INFECT], g_Forward_Result, iPlayer, iAttacker);

	set_bvar_num(g_iBvar_Zombie, iBit_Zombie | (1 << iPlayer));

	if (Get_Zombie_Count() == 1)
	{
		set_bvar_num(g_iBvar_First_Zombie, iBit_First_Zombie | (1 << iPlayer));
	}

	else
	{
		// TODO: may be it's not needed
		set_bvar_num(g_iBvar_First_Zombie, iBit_First_Zombie & ~(1 << iPlayer));
	}

	ExecuteForward(g_Forwards[FW_USER_INFECT_POST], g_Forward_Result, iPlayer, iAttacker);

	Check_Last_Zombie_And_Human();
}

Cure_Player(iPlayer, iAttacker = 0)
{
	ExecuteForward(g_Forwards[FW_USER_CURE_PRE], g_Forward_Result, iPlayer, iAttacker);

	// One or more plugins blocked cure
	if (g_Forward_Result >= PLUGIN_HANDLED)
	{
		return;
	}

	ExecuteForward(g_Forwards[FW_USER_CURE], g_Forward_Result, iPlayer, iAttacker);

	set_bvar_num(g_iBvar_Zombie, iBit_Zombie & ~(1 << iPlayer));

	ExecuteForward(g_Forwards[FW_USER_CURE_POST], g_Forward_Result, iPlayer, iAttacker);

	Check_Last_Zombie_And_Human();
}

// Last Zombie/Human Check
Check_Last_Zombie_And_Human()
{
	new iLast_Zombie_ID;
	new iLast_Human_ID;

	new iZombie_Count = Get_Zombie_Count();
	new iHuman_Count = Get_Human_Count();

	if (iZombie_Count == 1)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			// Last zombie
			if (is_player_alive(i) && zpe_core_is_zombie(i))
			{
				set_bvar_num(g_iBvar_Last_Zombie, 1 << i);

				iLast_Zombie_ID = i;

				break;
			}
		}
	}

	else
	{
		g_Last_Zombie_Forward_Called = false;

		set_bvar_num(g_iBvar_Last_Zombie, 0);
	}

	// Last zombie forward
	if (iLast_Zombie_ID > 0 && !g_Last_Zombie_Forward_Called)
	{
		ExecuteForward(g_Forwards[FW_USER_LAST_ZOMBIE], g_Forward_Result, iLast_Zombie_ID);

		g_Last_Zombie_Forward_Called = true;
	}

	if (iHuman_Count == 1)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			// Last human
			if (is_player_alive(i) && zpe_core_is_human(i))
			{
				set_bvar_num(g_iBvar_Last_Human, 1 << i);

				iLast_Human_ID = i;

				break;
			}
		}
	}

	else
	{
		g_Last_Human_Forward_Called = false;

		set_bvar_num(g_iBvar_Last_Human, 0);
	}

	// Last human forward
	if (iLast_Human_ID > 0 && !g_Last_Human_Forward_Called)
	{
		ExecuteForward(g_Forwards[FW_USER_LAST_HUMAN], g_Forward_Result, iLast_Human_ID);

		g_Last_Human_Forward_Called = true;
	}
}

public native_core_get_zombie_count(iPlugin_ID, iNum_Params)
{
	return Get_Zombie_Count();
}

public native_core_get_human_count(iPlugin_ID, iNum_Params)
{
	return Get_Human_Count();
}

public native_core_infect(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	CHECK_IS_PLAYER(iPlayer,)
	CHECK_IS_ALIVE(iPlayer,)
	CHECK_IS_HUMAN(iPlayer,)

	new iAttacker = get_param(2);

	if (iAttacker)
	{
		CHECK_IS_PLAYER(iAttacker,)
		CHECK_IS_ALIVE(iAttacker,)
	}

	Infect_Player(iPlayer, iAttacker);
}

public native_core_cure(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	CHECK_IS_PLAYER(iPlayer,)
	CHECK_IS_ALIVE(iPlayer,) 
	CHECK_IS_ZOMBIE(iPlayer,)

	new iAttacker = get_param(2);

	if (iAttacker)
	{
		CHECK_IS_PLAYER(iAttacker,)
		CHECK_IS_ALIVE(iAttacker,)
	}

	Cure_Player(iPlayer, iAttacker);
}

public native_core_force_infect(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	CHECK_IS_PLAYER(iPlayer,)
	CHECK_IS_ALIVE(iPlayer,)

	Infect_Player(iPlayer);
}

public native_core_force_cure(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	CHECK_IS_PLAYER(iPlayer,)
	CHECK_IS_ALIVE(iPlayer,)

	Cure_Player(iPlayer);
}

public native_core_respawn_as_zombie(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	CHECK_IS_PLAYER(iPlayer,)
	CHECK_IS_CONNECTED(iPlayer,)

	new iRespawn_As_Zombie = get_param(2);

	if (iRespawn_As_Zombie)
	{
		BIT_ADD(g_Respawn_As_Zombie, iPlayer);
	}

	else
	{
		BIT_SUB(g_Respawn_As_Zombie, iPlayer);
	}
}

// Get Zombie Count -returns alive zombies number-
Get_Zombie_Count()
{
	new iZombies;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (is_player_alive(i) && zpe_core_is_zombie(i))
		{
			iZombies++;
		}
	}

	return iZombies;
}

// Get Human Count -returns alive humans number-
Get_Human_Count()
{
	new iHumans;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (is_player_alive(i) && zpe_core_is_human(i))
		{
			iHumans++;
		}
	}

	return iHumans;
}

public FM_ClientDisconnect_Post(iPlayer)
{
	// Reset flags AFTER disconnect (to allow checking if the player was zombie before disconnecting)
	set_bvar_num(g_iBvar_Zombie, iBit_Zombie & ~(1 << iPlayer));

	BIT_SUB(g_Respawn_As_Zombie, iPlayer);

	// This should be called AFTER client disconnects (post forward)
	Check_Last_Zombie_And_Human();
}
