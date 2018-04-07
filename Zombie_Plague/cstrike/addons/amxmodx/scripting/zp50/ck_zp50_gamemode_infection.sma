/* AMX Mod X
*	[ZP] Gamemode Infection.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "gamemode infection"
#define VERSION "5.2.8.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <fun>
#include <ck_cs_teams_api>
#include <ck_zp50_kernel>
#include <ck_zp50_gamemodes>

new g_pCvar_Infection_Chance;
new g_pCvar_Infection_Min_Players;

new g_pCvar_Infection_Allow_Respawn;
new g_pCvar_Respawn_After_Last_Human;
new g_pCvar_Zombie_First_HP_Multiplier;

new g_pCvar_Notice_Infection_Show_Hud;

new g_pCvar_Message_Notice_Infection_Converted;
new g_pCvar_Message_Notice_Infection_R;
new g_pCvar_Message_Notice_Infection_G;
new g_pCvar_Message_Notice_Infection_B;
new g_pCvar_Message_Notice_Infection_X;
new g_pCvar_Message_Notice_Infection_Y;
new g_pCvar_Message_Notice_Infection_Effects;
new g_pCvar_Message_Notice_Infection_Fxtime;
new g_pCvar_Message_Notice_Infection_Holdtime;
new g_pCvar_Message_Notice_Infection_Fadeintime;
new g_pCvar_Message_Notice_Infection_Fadeouttime;
new g_pCvar_Message_Notice_Infection_Channel;

new g_pCvar_All_Messages_Converted;

new g_iTarget_Player;

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	new iGame_Mode_ID = zp_gamemodes_register("Infection Mode");

	zp_gamemodes_set_default(iGame_Mode_ID);

	g_pCvar_Infection_Chance = register_cvar("zm_infection_chance", "1");
	g_pCvar_Infection_Min_Players = register_cvar("zm_infection_min_players", "0");
	g_pCvar_Infection_Allow_Respawn = register_cvar("zm_infection_allow_respawn", "1");
	g_pCvar_Respawn_After_Last_Human = register_cvar("zm_infection_respawn_after_last_human", "1");
	g_pCvar_Zombie_First_HP_Multiplier = register_cvar("zm_zombie_first_hp_multiplier", "2.0");

	g_pCvar_Notice_Infection_Show_Hud = register_cvar("zm_notice_infection_show_hud", "1");

	g_pCvar_Message_Notice_Infection_Converted = register_cvar("zm_notice_infection_message_converted", "0");
	g_pCvar_Message_Notice_Infection_R = register_cvar("zm_notice_infection_message_r", "0");
	g_pCvar_Message_Notice_Infection_G = register_cvar("zm_notice_infection_message_g", "250");
	g_pCvar_Message_Notice_Infection_B = register_cvar("zm_notice_infection_message_b", "0");
	g_pCvar_Message_Notice_Infection_X = register_cvar("zm_notice_infection_message_x", "-1.0");
	g_pCvar_Message_Notice_Infection_Y = register_cvar("zm_notice_infection_message_y", "0.75");
	g_pCvar_Message_Notice_Infection_Effects = register_cvar("zm_notice_infection_message_effects", "0");
	g_pCvar_Message_Notice_Infection_Fxtime = register_cvar("zm_notice_infection_message_fxtime", "0.1");
	g_pCvar_Message_Notice_Infection_Holdtime = register_cvar("zm_notice_infection_message_holdtime", "1.5");
	g_pCvar_Message_Notice_Infection_Fadeintime = register_cvar("zm_notice_infection_message_fadeintime", "2.0");
	g_pCvar_Message_Notice_Infection_Fadeouttime = register_cvar("zm_notice_infection_message_fadeouttime", "1.5");
	g_pCvar_Message_Notice_Infection_Channel = register_cvar("zm_notice_infection_message_channel", "-1");

	g_pCvar_All_Messages_Converted = register_cvar("zm_all_messages_are_converted_to_hud", "0");
}

// Deathmatch module's player respawn forward
public zp_fw_deathmatch_respawn_pre(iPlayer)
{
	// Respawning allowed?
	if (!get_pcvar_num(g_pCvar_Infection_Allow_Respawn))
	{
		return PLUGIN_HANDLED;
	}

	// Respawn if only the last human is left?
	if (!get_pcvar_num(g_pCvar_Respawn_After_Last_Human) && zp_core_get_human_count() == 1)
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_choose_pre(iGame_Mode_ID, iSkipchecks)
{
	if (!iSkipchecks)
	{
		if (random_num(1, get_pcvar_num(g_pCvar_Infection_Chance)) != 1)
		{
			return PLUGIN_HANDLED;
		}

		if (Get_Alive_Count() < get_pcvar_num(g_pCvar_Infection_Min_Players))
		{
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_choose_post(iGame_Mode_ID, iTarget_Player)
{
	g_iTarget_Player = (iTarget_Player == RANDOM_TARGET_PLAYER) ? Get_Random_Alive_Player() : iTarget_Player;
}

public zp_fw_gamemodes_start()
{
	zp_gamemodes_set_allow_infect();

	zp_core_infect(g_iTarget_Player, g_iTarget_Player);

	set_user_health(g_iTarget_Player, get_user_health(g_iTarget_Player) * floatround(get_pcvar_float(g_pCvar_Zombie_First_HP_Multiplier)));

	for (new i = 1; i <= MaxClients; i++)
	{
		// Not alive
		if (!is_user_alive(i))
		{
			continue;
		}

		// This is our first zombie
		if (zp_core_is_zombie(i))
		{
			continue;
		}

		cs_set_player_team(i, CS_TEAM_CT);
	}

	if (get_pcvar_num(g_pCvar_Notice_Infection_Show_Hud))
	{
		new szPlayer_Name[32];

		GET_USER_NAME(g_iTarget_Player, szPlayer_Name, charsmax(szPlayer_Name));

		if (get_pcvar_num(g_pCvar_All_Messages_Converted) || get_pcvar_num(g_pCvar_Message_Notice_Infection_Converted))
		{
			set_hudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Infection_R),
				get_pcvar_num(g_pCvar_Message_Notice_Infection_G),
				get_pcvar_num(g_pCvar_Message_Notice_Infection_B),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_X),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Infection_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Fadeouttime),
				get_pcvar_num(g_pCvar_Message_Notice_Infection_Channel)
			);

			show_hudmessage(0, "%L", LANG_PLAYER, "NOTICE_FIRST", szPlayer_Name);
		}

		else
		{
			set_dhudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Infection_R),
				get_pcvar_num(g_pCvar_Message_Notice_Infection_G),
				get_pcvar_num(g_pCvar_Message_Notice_Infection_B),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_X),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Infection_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Infection_Fadeouttime)
			);

			show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_FIRST", szPlayer_Name);
		}
	}
}

Get_Alive_Count()
{
	new iAlive;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (is_user_alive(i))
		{
			iAlive++;
		}
	}

	return iAlive;
}

Get_Random_Alive_Player()
{
	new iPlayers[32];
	new iCount;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (is_user_alive(i))
		{
			iPlayers[iCount++] = i;
		}
	}

	return iCount > 0 ? iPlayers[random(iCount)] : -1;
}