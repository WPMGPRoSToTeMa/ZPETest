/* AMX Mod X
*	[ZP] ZP43 Compat.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*	http://ckcorp.ru/wiki - documentation and other useful information.
*
*	Support is provided only on the site.
*/

#define PLUGIN "zp43 support"
#define VERSION "2.0.4.1"
#define AUTHOR "C&K Corporation"

//	[RU] Соотношение аммо к деньгам.
//	[EN] Ammo pack to money ratio.
#define AMMOPACK_TO_MONEY_RATIO 160


//	[RU] Во сколько раз будет умножено количество жизней у первого зомби.
//	[EN] How many times will multiply the number of lives of the first zombie.
#define ZOMBIE_FIRST_HP_MULTIPLAYER 2.0


//	[RU] Закомментируйте, чтобы включить деньги вместо аммо.
//	[EN] Comment out to turn the money instead of ammo.
#define ENABLED_AMMO


//	[RU] Лимит денег.
//	[EN] Money limit.
#define CS_MONEY_LIMIT 16000


//	[RU] Путь кеширования кеширования лап зомби.
//	[EN]Path cache caching zombie paws.
#define CLAWMODEL_PATH "models/zombie_plague/%s"

#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <ck_zp50_kernel>
#include <ck_zp50_class_zombie>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_survivor>
#include <ck_zp50_class_assassin>
#include <ck_zp50_class_sniper>
#include <ck_zp50_gamemodes>
#include <ck_zp50_flashlight>
#include <ck_zp50_items>
#include <ck_zp50_ammopacks>
#include <ck_zp50_grenade_frost>
#include <ck_cs_player_models_api>

#define BIT_ADD(%0,%1)					(%0 |= (1 << (%1)))
#define BIT_SUB(%0,%1)					(%0 &= ~(1 << (%1)))
#define BIT_VALID(%0,%1)				(%0 & (1 << (%1)))
#define BIT_NOT_VALID(%0,%1) 			(~(%0) & (1 << (%1)))

#define is_user_valid(%1) (0 < %1 <= MaxClients)

#define ZP_TEAM_ANY 0
#define ZP_TEAM_ZOMBIE (1 << 0)
#define ZP_TEAM_HUMAN (1 << 1)
#define ZP_TEAM_NEMESIS (1 << 2)
#define ZP_TEAM_SURVIVOR (1 << 3)
#define ZP_TEAM_SNIPER (1 << 4)
#define ZP_TEAM_ASSASSIN (1 << 5)

new const ZP_TEAM_NAMES[][] = 
{ 
	"ZOMBIE , HUMAN", "ZOMBIE", "HUMAN", "ZOMBIE , HUMAN", "NEMESIS",
	"ZOMBIE , NEMESIS", "HUMAN , NEMESIS", "ZOMBIE , HUMAN , NEMESIS",
	"SURVIVOR", "ZOMBIE , SURVIVOR", "HUMAN , SURVIVOR", "ZOMBIE , HUMAN , SURVIVOR",
	"NEMESIS , SURVIVOR", "ZOMBIE , NEMESIS , SURVIVOR", "HUMAN, NEMESIS, SURVIVOR",
	"ASSASSIN" , "SNIPER" , "ASSASSIN , SNIPER" , "ASSASSIN , HUMAN" , "ASSASSIN , ZOMBIE",
	"ASSASSIN , NEMESIS" , "ASSASSIN , SURVIVOR" , "ASSASSIN , SNIPER , HUMAN" , "ASSASSIN , SNIPER , ZOMBIE",
	"ASSASSIN , SNIPER , NEMESIS" , "ASSASSIN , SNIPER , SURVIVOR" , "ASSASSIN , SNIPER , HUMAN , ZOMBIE",
	"ASSASSIN , SNIPER , HUMAN , SURVIVOR" , "ASSASSIN , SNIPER , HUMAN , NEMESIS",
	"ASSASSIN , SURVIVOR , HUMAN , NEMESIS" , "SNIPER , HUMAN",
	"SNIPER , ZOMBIE" , "SNIPER , SURVIVOR" , "SNIPER , NEMESIS" , "SNIPER , HUMAN",
	"SNIPER , HUMAN , ZOMBIE" , "SNIPER , HUMAN , NEMESIS" , "SNIPER , HUMAN , SURVIVOR",
	"SNIPER , HUMAN , ZOMBIE , SURVIVOR" , "SNIPER , HUMAN , ZOMBIE , NEMESIS",
	"SNIPER , HUMAN , SURVIVOR , NEMESIS" , "SNIPER , ZOMBIE , SURVIVOR , NEMESIS",
	"ZOMBIE , HUMAN , NEMESIS , SURVIVOR" , "SNIPER , ZOMBIE , SURVIVOR , NEMESIS , HUMAN",
	"SNIPER , ZOMBIE , SURVIVOR , NEMESIS , ASSASSIN" , "SNIPER , ZOMBIE , SURVIVOR , ASSASSIN , HUMAN",
	"ASSASSIN , ZOMBIE , SURVIVOR , ASSASSIN , HUMAN" , "ASSASSIN , ZOMBIE , SURVIVOR , NEMESIS , HUMAN",
	"ASSASSIN , ZOMBIE , SURVIVOR , ASSASSIN , HUMAN , SNIPER" , "HUMAN , NEMESIS , SURVIVOR , ZOMBIE"
};

enum
{
	MODE_CUSTOM = 0,
	MODE_INFECTION,
	MODE_NEMESIS,
	MODE_SURVIVOR,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE,
	MODE_ASSASSIN,
	MODE_SNIPER,
	MODE_ARMAGEDDON
};

// There was a bug with ZP 4.3 round end forward: it passed ZP_TEAM_ZOMBIE
// and ZP_TEAM_HUMAN instead of WIN_ZOMBIES and WIN_HUMANS. This is not
// fixed here either in order to keep better backwards compatibility.
#define WIN_NO_ONE 0
#define WIN_ZOMBIES ZP_TEAM_ZOMBIE
#define WIN_HUMANS ZP_TEAM_HUMAN

#define ZP_PLUGIN_HANDLED 97

enum _:TOTAL_FORWARDS
{
	FW_ROUND_STARTED = 0,
	FW_ROUND_ENDED,
	FW_USER_INFECT_ATTEMPT,
	FW_USER_INFECTED_PRE,
	FW_USER_INFECTED_POST,
	FW_USER_HUMANIZE_ATTEMPT,
	FW_USER_HUMANIZED_PRE,
	FW_USER_HUMANIZED_POST,
	FW_EXTRA_ITEM_SELECTED,
	FW_USER_UNFROZEN,
	FW_USER_LAST_ZOMBIE,
	FW_USER_LAST_HUMAN
};

new g_Forwards[TOTAL_FORWARDS];
new g_Forward_Result;

new g_Game_Mode_Infection_ID;
new g_Game_Mode_Multi_ID;
new g_Game_Mode_Nemesis_ID;
new g_Game_Mode_Survivor_ID;
new g_Game_Mode_Swarm_ID;
new g_Game_Mode_Plague_ID;
new g_Game_Mode_Assassin_ID;
new g_Game_Mode_Sniper_ID;
new g_Game_Mode_Lnj_ID;
new g_Mode_Started;

new Array:g_aItem_ID;
new Array:g_aItem_Teams;

new g_iBit_Alive;
new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_event("HLTV", "Event_Round_Start", "a", "1=0", "2=0");
	
	// Forwards
	g_Forwards[FW_ROUND_STARTED] = CreateMultiForward("zp_round_started", ET_IGNORE, FP_CELL, FP_CELL);
	g_Forwards[FW_ROUND_ENDED] = CreateMultiForward("zp_round_ended", ET_IGNORE, FP_CELL);
	g_Forwards[FW_USER_INFECT_ATTEMPT] = CreateMultiForward("zp_user_infect_attempt", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_INFECTED_PRE] = CreateMultiForward("zp_user_infected_pre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_INFECTED_POST] = CreateMultiForward("zp_user_infected_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_HUMANIZE_ATTEMPT] = CreateMultiForward("zp_user_humanize_attempt", ET_CONTINUE, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_HUMANIZED_PRE] = CreateMultiForward("zp_user_humanized_pre", ET_IGNORE, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_HUMANIZED_POST] = CreateMultiForward("zp_user_humanized_post", ET_IGNORE, FP_CELL, FP_CELL);
	g_Forwards[FW_EXTRA_ITEM_SELECTED] = CreateMultiForward("zp_extra_item_selected", ET_CONTINUE, FP_CELL, FP_CELL);
	g_Forwards[FW_USER_UNFROZEN] = CreateMultiForward("zp_user_unfrozen", ET_IGNORE, FP_CELL);
	g_Forwards[FW_USER_LAST_ZOMBIE] = CreateMultiForward("zp_user_last_zombie", ET_IGNORE, FP_CELL);
	g_Forwards[FW_USER_LAST_HUMAN] = CreateMultiForward("zp_user_last_human", ET_IGNORE, FP_CELL);
}

public Event_Round_Start()
{
	g_Mode_Started = false;
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
	BIT_SUB(g_iBit_Connected, iPlayer);	
}

public zp_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}

public zp_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_gamemodes_start(Game_Mode_ID)
{
	if (Game_Mode_ID == g_Game_Mode_Infection_ID)
	{
		// Get first zombie index
		new iPlayer_Index = 1;
		
		while ((BIT_NOT_VALID(g_iBit_Alive, iPlayer_Index) || !zp_core_is_zombie(iPlayer_Index)) && iPlayer_Index <= MaxClients)
		{
			iPlayer_Index++;
		}
		
		if (iPlayer_Index > MaxClients)
		{
			abort(AMX_ERR_GENERAL, "ERROR - first zombie index not found!");
			
			iPlayer_Index = 0;
		}
		
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_INFECTION, iPlayer_Index);
	}
	
	else if (Game_Mode_ID == g_Game_Mode_Multi_ID)
	{
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_MULTI, 0);
	}
	
	else if (Game_Mode_ID == g_Game_Mode_Nemesis_ID)
	{
		// Get nemesis index
		new iPlayer_Index = 1;
		
		while ((BIT_NOT_VALID(g_iBit_Alive, iPlayer_Index) || !zp_class_nemesis_get(iPlayer_Index)) && iPlayer_Index <= MaxClients)
		{
			iPlayer_Index++;
		}
		
		if (iPlayer_Index > MaxClients)
		{
			abort(AMX_ERR_GENERAL, "ERROR - nemesis index not found!");
			
			iPlayer_Index = 0;
		}
		
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_NEMESIS, iPlayer_Index);
	}
	
	else if (Game_Mode_ID == g_Game_Mode_Survivor_ID)
	{
		// Get survivor index
		new iPlayer_Index = 1;
		
		while ((BIT_NOT_VALID(g_iBit_Alive, iPlayer_Index) || !zp_class_survivor_get(iPlayer_Index)) && iPlayer_Index <= MaxClients)
		{
			iPlayer_Index++;
		}
		
		if (iPlayer_Index > MaxClients)
		{
			abort(AMX_ERR_GENERAL, "ERROR - survivor index not found!");
			
			iPlayer_Index = 0;
		}
		
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_SURVIVOR, iPlayer_Index);
	}
	
	else if (Game_Mode_ID == g_Game_Mode_Swarm_ID)
	{
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_SWARM, 0);
	}
	
	else if (Game_Mode_ID == g_Game_Mode_Plague_ID)
	{
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_PLAGUE, 0);
	}
	
	else if (Game_Mode_ID == g_Game_Mode_Assassin_ID)
	{
		// Get assassin index
		new iPlayer_Index = 1;
		
		while ((BIT_NOT_VALID(g_iBit_Alive, iPlayer_Index) || !zp_class_assassin_get(iPlayer_Index)) && iPlayer_Index <= MaxClients)
		{
			iPlayer_Index++;
		}
		
		if (iPlayer_Index > MaxClients)
		{
			abort(AMX_ERR_GENERAL, "ERROR - assassin index not found!");
			
			iPlayer_Index = 0;
		}
		
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_ASSASSIN, iPlayer_Index);
	}
	
	else if (Game_Mode_ID == g_Game_Mode_Sniper_ID)
	{
		// Get sniper index
		new iPlayer_Index = 1;
		
		while ((BIT_NOT_VALID(g_iBit_Alive, iPlayer_Index) || !zp_class_sniper_get(iPlayer_Index)) && iPlayer_Index <= MaxClients)
		{
			iPlayer_Index++;
		}
		
		if (iPlayer_Index > MaxClients)
		{
			abort(AMX_ERR_GENERAL, "ERROR - sniper index not found!");
			
			iPlayer_Index = 0;
		}
		
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_SNIPER, iPlayer_Index);
	}
	
	else if (Game_Mode_ID == g_Game_Mode_Lnj_ID)
	{
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_ARMAGEDDON, 0);
	}
	
	else
	{
		// Custom game mode started, pass MODE_CUSTOM (0) as mode parameter
		ExecuteForward(g_Forwards[FW_ROUND_STARTED], g_Forward_Result, MODE_CUSTOM, 0);
	}
	
	g_Mode_Started = true;
}

public zp_fw_gamemodes_end(Game_Mode_ID)
{
	if (!zp_core_get_zombie_count())
	{
		ExecuteForward(g_Forwards[FW_ROUND_ENDED], g_Forward_Result, WIN_HUMANS);
	}
	
	else if (!zp_core_get_human_count())
	{
		ExecuteForward(g_Forwards[FW_ROUND_ENDED], g_Forward_Result, WIN_ZOMBIES);
	}
	
	else
	{
		ExecuteForward(g_Forwards[FW_ROUND_ENDED], g_Forward_Result, WIN_NO_ONE);
	}
}

public zp_fw_core_infect_pre(iPlayer, iAttacker)
{
	if (zp_class_nemesis_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_INFECT_ATTEMPT], g_Forward_Result, iPlayer, iAttacker, true);
	}
	
	else if (zp_class_assassin_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_INFECT_ATTEMPT], g_Forward_Result, iPlayer, iAttacker, true);
	}
	
	else
	{
		ExecuteForward(g_Forwards[FW_USER_INFECT_ATTEMPT], g_Forward_Result, iPlayer, iAttacker, false);
	}
	
	if (g_Forward_Result >= ZP_PLUGIN_HANDLED && g_Mode_Started && zp_core_get_zombie_count() > 0)
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public zp_fw_core_infect(iPlayer, iAttacker)
{
	if (zp_class_nemesis_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_INFECTED_PRE], g_Forward_Result, iPlayer, iAttacker, true);
	}
	
	else if (zp_class_assassin_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_INFECTED_PRE], g_Forward_Result, iPlayer, iAttacker, true);
	}
	
	else
	{
		ExecuteForward(g_Forwards[FW_USER_INFECTED_PRE], g_Forward_Result, iPlayer, iAttacker, false);
	}
}

public zp_fw_core_infect_post(iPlayer, iAttacker)
{
	if (zp_class_nemesis_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_INFECTED_POST], g_Forward_Result, iPlayer, iAttacker, true);
	}
	
	else if (zp_class_assassin_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_INFECTED_POST], g_Forward_Result, iPlayer, iAttacker, true);
	}
	
	else
	{
		ExecuteForward(g_Forwards[FW_USER_INFECTED_POST], g_Forward_Result, iPlayer, iAttacker, false);
	}
}

public zp_fw_core_cure_pre(iPlayer, iAttacker)
{
	if (zp_class_survivor_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_HUMANIZE_ATTEMPT], g_Forward_Result, iPlayer, true);
	}
	
	else if (zp_class_sniper_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_HUMANIZE_ATTEMPT], g_Forward_Result, iPlayer, true);
	}
	
	else
	{
		ExecuteForward(g_Forwards[FW_USER_HUMANIZE_ATTEMPT], g_Forward_Result, iPlayer, false);
	}
	
	if (g_Forward_Result >= ZP_PLUGIN_HANDLED && g_Mode_Started && zp_core_get_human_count() > 0)
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public zp_fw_core_cure(iPlayer, iAttacker)
{
	if (zp_class_survivor_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_HUMANIZED_PRE], g_Forward_Result, iPlayer, true);
	}
	
	else if (zp_class_sniper_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_HUMANIZED_PRE], g_Forward_Result, iPlayer, true);
	}
	
	else
	{
		ExecuteForward(g_Forwards[FW_USER_HUMANIZED_PRE], g_Forward_Result, iPlayer, false);
	}
}

public zp_fw_core_cure_post(iPlayer, iAttacker)
{
	if (zp_class_survivor_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_HUMANIZED_POST], g_Forward_Result, iPlayer, true);
	}
	
	if (zp_class_sniper_get(iPlayer))
	{
		ExecuteForward(g_Forwards[FW_USER_HUMANIZED_POST], g_Forward_Result, iPlayer, true);
	}
	
	else
	{
		ExecuteForward(g_Forwards[FW_USER_HUMANIZED_POST], g_Forward_Result, iPlayer, false);
	}
}

public zp_fw_items_select_post(iPlayer, iItem_ID)
{
	ExecuteForward(g_Forwards[FW_EXTRA_ITEM_SELECTED], g_Forward_Result, iPlayer, iItem_ID);
	
	if (g_Forward_Result >= ZP_PLUGIN_HANDLED)
	{
		// Item purchase was blocked, restore player's money/ammo packs
		new iItem_Cost = zp_items_get_cost(iItem_ID);
		
		#if defined ENABLED_AMMO
		
			zp_ammopacks_set(iPlayer, zp_ammopacks_get(iPlayer) + iItem_Cost);
		
		#else
		
			cs_set_user_money(iPlayer, cs_get_user_money(iPlayer) + iItem_Cost, 0);
		
		#endif
	}
}

public zp_fw_grenade_frost_unfreeze(iPlayer)
{
	ExecuteForward(g_Forwards[FW_USER_UNFROZEN], g_Forward_Result, iPlayer);
}

public zp_fw_core_last_zombie(iPlayer)
{
	ExecuteForward(g_Forwards[FW_USER_LAST_ZOMBIE], g_Forward_Result, iPlayer);
}

public zp_fw_core_last_human(iPlayer)
{
	ExecuteForward(g_Forwards[FW_USER_LAST_HUMAN], g_Forward_Result, iPlayer);
}

public plugin_cfg()
{
	g_Game_Mode_Infection_ID = zp_gamemodes_get_id("Infection Mode");
	g_Game_Mode_Multi_ID = zp_gamemodes_get_id("Multiple Infection Mode");
	g_Game_Mode_Nemesis_ID = zp_gamemodes_get_id("Nemesis Mode");
	g_Game_Mode_Survivor_ID = zp_gamemodes_get_id("Survivor Mode");
	g_Game_Mode_Swarm_ID = zp_gamemodes_get_id("Swarm Mode");
	g_Game_Mode_Plague_ID = zp_gamemodes_get_id("Plague Mode");
	g_Game_Mode_Assassin_ID = zp_gamemodes_get_id("Assassin Mode");
	g_Game_Mode_Sniper_ID = zp_gamemodes_get_id("Sniper Mode");
	g_Game_Mode_Lnj_ID = zp_gamemodes_get_id("Armageddon Mode");
}

public plugin_natives()
{
	register_library("ck_zp50_zp43_compat");
	
	// Natives
	register_native("zp_get_user_zombie", "native_get_user_zombie");
	register_native("zp_get_user_nemesis", "native_get_user_nemesis");
	register_native("zp_get_user_survivor", "native_get_user_survivor");
	register_native("zp_get_user_first_zombie", "native_get_user_first_zombie");
	register_native("zp_get_user_last_zombie", "native_get_user_last_zombie");
	register_native("zp_get_user_last_human", "native_get_user_last_human");
	register_native("zp_get_user_zombie_class", "native_get_user_zombie_class");
	register_native("zp_get_user_next_class", "native_get_user_next_class");
	register_native("zp_set_user_zombie_class", "native_set_user_zombie_class");
	register_native("zp_get_user_ammo_packs", "native_get_user_ammo_packs");
	register_native("zp_set_user_ammo_packs", "native_set_user_ammo_packs");
	register_native("zp_get_zombie_maxhealth", "native_get_zombie_maxhealth");
	register_native("zp_get_user_batteries", "native_get_user_batteries");
	register_native("zp_set_user_batteries", "native_set_user_batteries");
	register_native("zp_get_user_nightvision", "native_get_user_nightvision");
	register_native("zp_set_user_nightvision", "native_set_user_nightvision");
	register_native("zp_infect_user", "native_infect_user");
	register_native("zp_disinfect_user", "native_disinfect_user");
	register_native("zp_make_user_nemesis", "native_make_user_nemesis");
	register_native("zp_make_user_survivor", "native_make_user_survivor");
	register_native("zp_make_user_assassin", "native_make_user_assassin");
	register_native("zp_make_user_sniper", "native_make_user_sniper");
	register_native("zp_respawn_user", "native_respawn_user");
	register_native("zp_force_buy_extra_item", "native_force_buy_extra_item");
	register_native("zp_override_user_model", "native_override_user_model");
	register_native("zp_has_round_started", "native_has_round_started");
	register_native("zp_is_nemesis_round", "native_is_nemesis_round");
	register_native("zp_is_survivor_round", "native_is_survivor_round");
	register_native("zp_is_swarm_round", "native_is_swarm_round");
	register_native("zp_is_plague_round", "native_is_plague_round");
	register_native("zp_is_assassin_round", "native_is_assassin_round");
	register_native("zp_is_sniper_round", "native_is_sniper_round");
	register_native("zp_is_lnj_round", "native_is_lnj_round");
	register_native("zp_get_zombie_count", "native_get_zombie_count");
	register_native("zp_get_human_count", "native_get_human_count");
	register_native("zp_get_nemesis_count", "native_get_nemesis_count");
	register_native("zp_get_survivor_count", "native_get_survivor_count");
	register_native("zp_register_extra_item", "native_register_extra_item");
	register_native("zp_register_zombie_class", "native_register_zombie_class");
	register_native("zp_get_extra_item_id", "native_get_extra_item_id");
	register_native("zp_get_zombie_class_id", "native_get_zombie_class_id");
	register_native("zp_get_zombie_class_info", "native_get_zombie_class_info");
	
	// Initialize dynamic arrays
	g_aItem_ID = ArrayCreate(1, 1);
	g_aItem_Teams = ArrayCreate(1, 1);
}

public native_get_user_zombie(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_core_is_zombie(iPlayer);
}

public native_get_user_nemesis(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_class_nemesis_get(iPlayer);
}

public native_get_user_survivor(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_class_survivor_get(iPlayer);
}

public native_get_user_assassin(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_class_assassin_get(iPlayer);
}

public native_get_user_sniper(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_class_sniper_get(iPlayer);
}

public native_get_user_first_zombie(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_core_is_first_zombie(iPlayer);
}

public native_get_user_last_zombie(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_core_is_last_zombie(iPlayer);
}

public native_get_user_last_human(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_core_is_last_human(iPlayer);
}

public native_get_user_zombie_class(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return -1;
	}
	
	return zp_class_zombie_get_current(iPlayer);
}

public native_get_user_next_class(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return -1;
	}
	
	return zp_class_zombie_get_next(iPlayer);
}

public native_set_user_zombie_class(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	new iClass_ID = get_param(2);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_class_zombie_set_next(iPlayer, iClass_ID);
}

public native_get_user_ammo_packs(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (!is_user_valid(iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return -1;
	}
	
	#if defined ENABLED_AMMO
	
		return zp_ammopacks_get(iPlayer);
	
	#else
	
		return cs_get_user_money(iPlayer) / AMMOPACK_TO_MONEY_RATIO;
	
	#endif
}

public native_set_user_ammo_packs(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (!is_user_valid(iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	new iAmount = get_param(2);
	
	#if defined ENABLED_AMMO
	
		return zp_ammopacks_set(iPlayer, iAmount);
	
	#else
	
		new iMoney = min(iAmount * AMMOPACK_TO_MONEY_RATIO, CS_MONEY_LIMIT);
		
		cs_set_user_money(iPlayer, iMoney);
	
	#endif
}

public native_get_zombie_maxhealth(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return -1;
	}
	
	new iClass_ID = zp_class_zombie_get_current(iPlayer);
	
	if (iClass_ID == ZP_INVALID_ZOMBIE_CLASS)
	{
		return -1;
	}
	
	if (ZOMBIE_FIRST_HP_MULTIPLAYER && zp_core_is_first_zombie(iPlayer))
	{
		return floatround(float(zp_class_zombie_get_max_health(iPlayer, iClass_ID)) * ZOMBIE_FIRST_HP_MULTIPLAYER);
	}
	
	return zp_class_zombie_get_max_health(iPlayer, iClass_ID);
}

public native_get_user_batteries(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return -1;
	}
	
	return zp_flashlight_get_charge(iPlayer);
}

public native_set_user_batteries(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	new iCharge = get_param(2);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_flashlight_set_charge(iPlayer, iCharge);
}

public native_get_user_nightvision(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return cs_get_user_nvg(iPlayer);
}

public native_set_user_nightvision(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1)
	new iSet = get_param(2)
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	cs_set_user_nvg(iPlayer, iSet);
	
	return true;
}

public native_infect_user(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	new iAttacker = get_param(2);
	
	if (iAttacker && BIT_NOT_VALID(g_iBit_Alive, iAttacker))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iAttacker);
		
		return false;
	}
	
	if (iAttacker)
	{
		return zp_core_infect(iPlayer, iAttacker);
	}
	
	new iSilent = get_param(3);
	
	return zp_core_infect(iPlayer, iSilent ? 0 : iPlayer);
}

public native_disinfect_user(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	new iSilent = get_param(2);
	
	return zp_core_cure(iPlayer, iSilent ? 0 : iPlayer);
}

public native_make_user_nemesis(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_class_nemesis_set(iPlayer);
}

public native_make_user_survivor(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_class_survivor_set(iPlayer);
}

public native_make_user_assassin(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_class_assassin_set(iPlayer);
}

public native_make_user_sniper(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	return zp_class_sniper_set(iPlayer);
}

public native_respawn_user(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	// Respawn not allowed
	if (!Allowed_Respawn(iPlayer))
	{
		return false;
	}
	
	new iTeam = get_param(2);
	
	if (iTeam == ZP_TEAM_ZOMBIE)
	{
		zp_core_respawn_as_zombie(iPlayer, true);
	}
	
	else
	{
		zp_core_respawn_as_zombie(iPlayer, false);
	}
	
	// Respawn!
	ExecuteHamB(Ham_CS_RoundRespawn, iPlayer);
	
	return true;
}

// Checks if a player is allowed to respawn
Allowed_Respawn(iPlayer)
{
	if (BIT_VALID(g_iBit_Alive, iPlayer))
	{
		return false;
	}
	
	if (cs_get_user_team(iPlayer) == CS_TEAM_SPECTATOR  || cs_get_user_team(iPlayer) == CS_TEAM_UNASSIGNED)
	{
		return false;
	}
	
	return true;
}

public native_force_buy_extra_item(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	new iItem_ID = get_param(2);
	new iIgnorecost = get_param(3);
	
	return zp_items_force_buy(iPlayer, iItem_ID, iIgnorecost);
}

public native_override_user_model(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);
	
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid player (%d)", iPlayer);
		
		return false;
	}
	
	new szNew_Model[32];
	
	get_string(2, szNew_Model, charsmax(szNew_Model));
	
	cs_set_player_model(iPlayer, szNew_Model);
	
	return true;
}

public native_has_round_started(iPlugin_ID, iNum_Params)
{
	if (!g_Mode_Started)
	{
		if (zp_gamemodes_get_current() == ZP_NO_GAME_MODE)
		{
			return 0; // not started
		}
		
		return 2; // starting
	}
	
	return 1; // started
}

public native_is_nemesis_round(iPlugin_ID, iNum_Params)
{
	return (zp_gamemodes_get_current() == g_Game_Mode_Nemesis_ID);
}

public native_is_survivor_round(iPlugin_ID, iNum_Params)
{
	return (zp_gamemodes_get_current() == g_Game_Mode_Survivor_ID);
}

public native_is_swarm_round(iPlugin_ID, iNum_Params)
{
	return (zp_gamemodes_get_current() == g_Game_Mode_Swarm_ID);
}

public native_is_plague_round(iPlugin_ID, iNum_Params)
{
	return (zp_gamemodes_get_current() == g_Game_Mode_Plague_ID);
}

public native_is_assassin_round(iPlugin_ID, iNum_Params)
{
	return (zp_gamemodes_get_current() == g_Game_Mode_Assassin_ID);
}

public native_is_sniper_round(iPlugin_ID, iNum_Params)
{
	return (zp_gamemodes_get_current() == g_Game_Mode_Sniper_ID);
}

public native_is_lnj_round(iPlugin_ID, iNum_Params)
{
	return (zp_gamemodes_get_current() == g_Game_Mode_Lnj_ID);
}

public native_get_zombie_count(iPlugin_ID, iNum_Params)
{
	return zp_core_get_zombie_count();
}

public native_get_human_count(iPlugin_ID, iNum_Params)
{
	return zp_core_get_human_count();
}

public native_get_nemesis_count(iPlugin_ID, iNum_Params)
{
	return zp_class_nemesis_get_count();
}

public native_get_survivor_count(iPlugin_ID, iNum_Params)
{
	return zp_class_survivor_get_count();
}

public native_register_extra_item(iPlugin_ID, iNum_Params)
{
	new szName[32];
	
	get_string(1, szName, charsmax(szName));
	
	new iCost = get_param(2);
	
	new iItem_ID = zp_items_register(szName, iCost);
	
	if (iItem_ID < 0)
	{
		return iItem_ID;
	}
	
	// Item Teams
	new iTeams_Bitsum = get_param(3);
	
	if (iTeams_Bitsum == ZP_TEAM_ANY)
	{
		iTeams_Bitsum = (ZP_TEAM_ZOMBIE | ZP_TEAM_HUMAN); // backwards compatibility
	}
	
	// Load/save teams
	new sTeams_String[64];
	
	iTeams_Bitsum = 0
	
	if (contain(sTeams_String, ZP_TEAM_NAMES[ZP_TEAM_ZOMBIE]) != -1)
	{
		iTeams_Bitsum |= ZP_TEAM_ZOMBIE;
	}
	
	if (contain(sTeams_String, ZP_TEAM_NAMES[ZP_TEAM_HUMAN]) != -1)
	{
		iTeams_Bitsum |= ZP_TEAM_HUMAN;
	}
	
	if (contain(sTeams_String, ZP_TEAM_NAMES[ZP_TEAM_NEMESIS]) != -1)
	{
		iTeams_Bitsum |= ZP_TEAM_NEMESIS;
	}
	
	if (contain(sTeams_String, ZP_TEAM_NAMES[ZP_TEAM_SURVIVOR]) != -1)
	{
		iTeams_Bitsum |= ZP_TEAM_SURVIVOR;
	}
	
	if (contain(sTeams_String, ZP_TEAM_NAMES[ZP_TEAM_SNIPER]) != -1)
	{
		iTeams_Bitsum |= ZP_TEAM_SNIPER;
	}
	
	if (contain(sTeams_String, ZP_TEAM_NAMES[ZP_TEAM_ASSASSIN]) != -1)
	{
		iTeams_Bitsum |= ZP_TEAM_ASSASSIN;
	}
	
	// Add ZP team restrictions
	ArrayPushCell(g_aItem_ID, iItem_ID);
	ArrayPushCell(g_aItem_Teams, iTeams_Bitsum);
	
	return iItem_ID;
}

public zp_fw_items_select_pre(iPlayer, iItem_ID, iIgnorecost)
{
	// Is this our item?
	new iIndex;
	
	for (iIndex = 0; iIndex < ArraySize(g_aItem_ID); iIndex++)
	{
		if (iItem_ID == ArrayGetCell(g_aItem_ID, iIndex))
		{
			break;
		}
	}
	
	// This is not our item (loop reaching its end condition means no matches)
	if (iIndex >= ArraySize(g_aItem_ID))
	{
		return ZP_ITEM_AVAILABLE;
	}
	
	// Get team restrictions
	new iTeams_Bitsum = ArrayGetCell(g_aItem_Teams, iIndex);
	
	// Check team restrictions
	if (zp_core_is_zombie(iPlayer))
	{
		if (zp_class_nemesis_get(iPlayer))
		{
			if (!(iTeams_Bitsum & ZP_TEAM_NEMESIS))
			{
				return ZP_ITEM_DONT_SHOW;
			}
		}
		
		else if (zp_class_assassin_get(iPlayer))
		{
			if (!(iTeams_Bitsum & ZP_TEAM_ASSASSIN))
			{
				return ZP_ITEM_DONT_SHOW;
			}
		}
		
		else
		{
			if (!(iTeams_Bitsum & ZP_TEAM_ZOMBIE))
			{
				return ZP_ITEM_DONT_SHOW;
			}
		}
	}
	
	else
	{
		if (zp_class_survivor_get(iPlayer))
		{
			if (!(iTeams_Bitsum & ZP_TEAM_SURVIVOR))
			{
				return ZP_ITEM_DONT_SHOW;
			}
		}
		
		else if (zp_class_sniper_get(iPlayer))
		{
			if (!(iTeams_Bitsum & ZP_TEAM_SNIPER))
			{
				return ZP_ITEM_DONT_SHOW;
			}
		}
		
		else
		{
			if (!(iTeams_Bitsum & ZP_TEAM_HUMAN))
			{
				return ZP_ITEM_DONT_SHOW;
			}
		}
	}
	
	return ZP_ITEM_AVAILABLE;
}

public native_register_zombie_class(iPlugin_ID, iNum_Params)
{
	new szName[32];
	new szDescription[32];
	new szModel[32];
	new szClawmodel[64];
	
	get_string(1, szName, charsmax(szName));
	get_string(2, szDescription, charsmax(szDescription));
	get_string(3, szModel, charsmax(szModel));
	get_string(4, szClawmodel, charsmax(szClawmodel));
	format(szClawmodel, charsmax(szClawmodel), CLAWMODEL_PATH, szClawmodel);
	
	new iHelath = get_param(5);
	
	new Float:fSpeed = float(get_param(6));
	new Float:fGravity = get_param_f(7);
	new Float:fKnockback = get_param_f(8);
	
	new iClass_ID = zp_class_zombie_register(szName, szDescription, iHelath, fSpeed, fGravity);
	
	if (iClass_ID < 0)
	{
		return iClass_ID;
	}
	
	zp_class_zombie_register_model(iClass_ID, szModel);
	zp_class_zombie_register_claw(iClass_ID, szClawmodel);
	zp_class_zombie_register_kb(iClass_ID, fKnockback);
	
	return iClass_ID;
}

public native_get_extra_item_id(iPlugin_ID, iNum_Params)
{
	new szName[32];
	
	get_string(1, szName, charsmax(szName));
	
	return zp_items_get_id(szName);
}

public native_get_zombie_class_id(iPlugin_ID, iNum_Params)
{
	new szName[32];
	
	get_string(1, szName, charsmax(szName));
	
	return zp_class_zombie_get_id(szName);
}

public native_get_zombie_class_info(iPlugin_ID, iNum_Params)
{
	new iClass_ID = get_param(1);
	
	new sInfo[32];
	new sLen = get_param(3);
	
	new iResult = zp_class_zombie_get_description(iClass_ID, sInfo, sLen);
	
	if (!iResult)
	{	
		return false;
	}
	
	set_string(2, sInfo, sLen);
	
	return true;
}