/* AMX Mod X
*	[ZP] Gamemode plague.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "gamemode plague"
#define VERSION "5.2.7.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

new const g_Sound_Plague[][] =
{
	"zombie_plague/nemesis1.wav",
	"zombie_plague/survivor1.wav"
};

#include <amxmodx>
#include <cs_util>
#include <fun>
#include <amx_settings_api>
#include <ck_zp50_kernel>
#include <ck_zp50_gamemodes>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_survivor>

#define SOUND_MAX_LENGTH 64

new Array:g_aSound_Plague;

new g_pCvar_Plague_Chance;
new g_pCvar_Plague_Min_Players;
new g_pCvar_Plague_Ratio;
new g_pCvar_Plague_Nemesis_Count;
new g_pCvar_Plague_Nemesis_HP_Multi;
new g_pCvar_Plague_Survivor_Count;
new g_pCvar_Plague_Survivor_HP_Multi;
new g_pCvar_Plague_Sounds;
new g_pCvar_Plague_Allow_Respawn;

new g_pCvar_Notice_Plague_Show_Hud;

new g_pCvar_Message_Notice_Plague_Converted;
new g_pCvar_Message_Notice_Plague_R;
new g_pCvar_Message_Notice_Plague_G;
new g_pCvar_Message_Notice_Plague_B;
new g_pCvar_Message_Notice_Plague_X;
new g_pCvar_Message_Notice_Plague_Y;
new g_pCvar_Message_Notice_Plague_Effects;
new g_pCvar_Message_Notice_Plague_Fxtime;
new g_pCvar_Message_Notice_Plague_Holdtime;
new g_pCvar_Message_Notice_Plague_Fadeintime;
new g_pCvar_Message_Notice_Plague_Fadeouttime;
new g_pCvar_Message_Notice_Plague_Channel;

new g_pCvar_All_Messages_Converted;

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	zp_gamemodes_register("Plague Mode");

	g_pCvar_Plague_Chance = register_cvar("zm_plague_chance", "20");
	g_pCvar_Plague_Min_Players = register_cvar("zm_plague_min_players", "0");
	g_pCvar_Plague_Ratio = register_cvar("zm_plague_ratio", "0.5");
	g_pCvar_Plague_Nemesis_Count = register_cvar("zm_plague_nemesis_count", "1");
	g_pCvar_Plague_Nemesis_HP_Multi = register_cvar("zm_plague_nemesis_hp_multi", "0.5");
	g_pCvar_Plague_Survivor_Count = register_cvar("zm_plague_survivor_count", "1");
	g_pCvar_Plague_Survivor_HP_Multi = register_cvar("zm_plague_survivor_hp_multi", "0.5");
	g_pCvar_Plague_Sounds = register_cvar("zm_plague_sounds", "1");
	g_pCvar_Plague_Allow_Respawn = register_cvar("zm_plague_allow_respawn", "0");

	g_pCvar_Notice_Plague_Show_Hud = register_cvar("zm_notice_plague_show_hud", "1");

	g_pCvar_Message_Notice_Plague_Converted = register_cvar("zm_notice_plague_message_converted", "0");
	g_pCvar_Message_Notice_Plague_R = register_cvar("zm_notice_plague_message_r", "0");
	g_pCvar_Message_Notice_Plague_G = register_cvar("zm_notice_plague_message_g", "250");
	g_pCvar_Message_Notice_Plague_B = register_cvar("zm_notice_plague_message_b", "0");
	g_pCvar_Message_Notice_Plague_X = register_cvar("zm_notice_plague_message_x", "-1.0");
	g_pCvar_Message_Notice_Plague_Y = register_cvar("zm_notice_plague_message_y", "0.75");
	g_pCvar_Message_Notice_Plague_Effects = register_cvar("zm_notice_plague_message_effects", "0");
	g_pCvar_Message_Notice_Plague_Fxtime = register_cvar("zm_notice_plague_message_fxtime", "0.1");
	g_pCvar_Message_Notice_Plague_Holdtime = register_cvar("zm_notice_plague_message_holdtime", "1.5");
	g_pCvar_Message_Notice_Plague_Fadeintime = register_cvar("zm_notice_plague_message_fadeintime", "2.0");
	g_pCvar_Message_Notice_Plague_Fadeouttime = register_cvar("zm_notice_plague_message_fadeouttime", "1.5");
	g_pCvar_Message_Notice_Plague_Channel = register_cvar("zm_notice_plague_message_channel", "-1");

	g_pCvar_All_Messages_Converted = register_cvar("zm_all_messages_are_converted_to_hud", "0");

	// Initialize arrays
	g_aSound_Plague = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND PLAGUE", g_aSound_Plague);

	// If we couldn't load custom sounds from file, use and save default ones
	if (ArraySize(g_aSound_Plague) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Plague; i++)
		{
			ArrayPushString(g_aSound_Plague, g_Sound_Plague[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND PLAGUE", g_aSound_Plague);
	}

	for (new i = 0; i < sizeof g_Sound_Plague; i++)
	{
		precache_sound(g_Sound_Plague[i]);
	}
}

// Deathmatch module's player respawn forward
public zp_fw_deathmatch_respawn_pre(iPlayer)
{
	// Respawning allowed?
	if (!get_pcvar_num(g_pCvar_Plague_Allow_Respawn))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_choose_pre(iGame_Mode_ID, iSkipchecks)
{
	new iAlive_Count = Get_Alive_Count();

	if (!iSkipchecks)
	{
		// Random chance
		if (random_num(1, get_pcvar_num(g_pCvar_Plague_Chance)) != 1)
		{
			return PLUGIN_HANDLED;
		}

		// Min players
		if (iAlive_Count < get_pcvar_num(g_pCvar_Plague_Min_Players))
		{
			return PLUGIN_HANDLED;
		}
	}

	// There should be enough players to have the desired amount of nemesis and survivors
	if (iAlive_Count < get_pcvar_num(g_pCvar_Plague_Nemesis_Count) + get_pcvar_num(g_pCvar_Plague_Survivor_Count))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_start()
{
	new iPlayer;
	new iAlive_Count = Get_Alive_Count();
	new iSurvivor_Count = get_pcvar_num(g_pCvar_Plague_Survivor_Count);
	new iNemesis_Count = get_pcvar_num(g_pCvar_Plague_Nemesis_Count);
	new iZombie_Count = floatround((iAlive_Count - (iNemesis_Count + iSurvivor_Count)) * get_pcvar_float(g_pCvar_Plague_Ratio), floatround_ceil);

	new iSurvivors;
	new iMax_Survivors = iSurvivor_Count;

	while (iSurvivors < iMax_Survivors)
	{
		iPlayer = Get_Random_Alive_Player();

		if (zp_class_survivor_get(iPlayer))
		{
			continue;
		}

		zp_class_survivor_set(iPlayer);

		iSurvivors++;

		set_user_health(iPlayer, get_user_health(iPlayer) * floatround(get_pcvar_float(g_pCvar_Plague_Survivor_HP_Multi)));
	}

	new iNemesis;
	new iMax_Nemesis = iNemesis_Count;

	while (iNemesis < iMax_Nemesis)
	{
		iPlayer = Get_Random_Alive_Player();

		if (zp_class_survivor_get(iPlayer) || zp_class_nemesis_get(iPlayer))
		{
			continue;
		}

		zp_class_nemesis_set(iPlayer);

		iNemesis++;

		SET_USER_HEALTH(iPlayer, Float:GET_USER_HEALTH(iPlayer) * get_pcvar_float(g_pCvar_Plague_Nemesis_HP_Multi));
	}

	new iZombies;
	new iMax_Zombies = iZombie_Count;

	while (iZombies < iMax_Zombies)
	{
		iPlayer = Get_Random_Alive_Player();

		if (zp_class_survivor_get(iPlayer) || zp_core_is_zombie(iPlayer))
		{
			continue;
		}

		zp_core_infect(iPlayer, 0);

		iZombies++;
	}

	for (new i = 1; i <= MaxClients; i++)
	{
		if (!is_user_alive(i))
		{
			continue;
		}

		if (zp_class_survivor_get(i) || zp_core_is_zombie(i))
		{
			continue;
		}

		rg_set_user_team(i, TEAM_CT);
	}

	if (get_pcvar_num(g_pCvar_Plague_Sounds))
	{
		Play_Sound_To_Clients(g_Sound_Plague[random(sizeof g_Sound_Plague)]);
	}

	if (get_pcvar_num(g_pCvar_Notice_Plague_Show_Hud))
	{
		if (get_pcvar_num(g_pCvar_All_Messages_Converted) || get_pcvar_num(g_pCvar_Message_Notice_Plague_Converted))
		{
			set_hudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Plague_R),
				get_pcvar_num(g_pCvar_Message_Notice_Plague_G),
				get_pcvar_num(g_pCvar_Message_Notice_Plague_B),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_X),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Plague_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Fadeouttime),
				get_pcvar_num(g_pCvar_Message_Notice_Plague_Channel)
			);

			show_hudmessage(0, "%L", LANG_PLAYER, "NOTICE_PLAGUE");
		}

		else
		{
			set_dhudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Plague_R),
				get_pcvar_num(g_pCvar_Message_Notice_Plague_G),
				get_pcvar_num(g_pCvar_Message_Notice_Plague_B),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_X),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Plague_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Plague_Fadeouttime)
			);

			show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_PLAGUE");
		}
	}
}

// Plays a sound on clients
Play_Sound_To_Clients(const szSound[])
{
	if (equal(szSound[strlen(szSound) - 4], ".mp3"))
	{
		client_cmd(0, "mp3 play ^"sound/%s^"", szSound);
	}

	else
	{
		client_cmd(0, "spk ^"%s^"", szSound);
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