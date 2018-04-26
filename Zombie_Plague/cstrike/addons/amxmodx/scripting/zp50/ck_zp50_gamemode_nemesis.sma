/* AMX Mod X
*	[ZP] Gamemode nemesis.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "gamemode nemesis"
#define VERSION "5.2.8.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

new const g_Sound_Nemesis[][] =
{
	"zombie_plague/nemesis1.wav",
	"zombie_plague/nemesis2.wav"
};

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_zp50_kernel>
#include <ck_zp50_gamemodes>
#include <ck_zp50_class_nemesis>

#define SOUND_MAX_LENGTH 64

new Array:g_aSound_Nemesis;

new g_pCvar_Nemesis_Chance;
new g_pCvar_Nemesis_Min_Players;
new g_pCvar_Nemesis_Sounds;
new g_pCvar_Nemesis_Allow_Respawn;

new g_pCvar_Notice_Nemesis_Show_Hud;

new g_pCvar_Message_Notice_Nemesis_Converted;
new g_pCvar_Message_Notice_Nemesis_R;
new g_pCvar_Message_Notice_Nemesis_G;
new g_pCvar_Message_Notice_Nemesis_B;
new g_pCvar_Message_Notice_Nemesis_X;
new g_pCvar_Message_Notice_Nemesis_Y;
new g_pCvar_Message_Notice_Nemesis_Effects;
new g_pCvar_Message_Notice_Nemesis_Fxtime;
new g_pCvar_Message_Notice_Nemesis_Holdtime;
new g_pCvar_Message_Notice_Nemesis_Fadeintime;
new g_pCvar_Message_Notice_Nemesis_Fadeouttime;
new g_pCvar_Message_Notice_Nemesis_Channel;

new g_pCvar_All_Messages_Converted;

new g_iTarget_Player;

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	zp_gamemodes_register("Nemesis Mode");

	g_pCvar_Nemesis_Chance = register_cvar("zm_nemesis_chance", "20");
	g_pCvar_Nemesis_Min_Players = register_cvar("zm_nemesis_min_players", "0");
	g_pCvar_Nemesis_Sounds = register_cvar("zm_nemesis_sounds", "1");
	g_pCvar_Nemesis_Allow_Respawn = register_cvar("zm_nemesis_allow_respawn", "0");

	g_pCvar_Notice_Nemesis_Show_Hud = register_cvar("zm_notice_nemesis_show_hud", "1");

	g_pCvar_Message_Notice_Nemesis_Converted = register_cvar("zm_notice_nemesis_message_converted", "0");
	g_pCvar_Message_Notice_Nemesis_R = register_cvar("zm_notice_nemesis_message_r", "0");
	g_pCvar_Message_Notice_Nemesis_G = register_cvar("zm_notice_nemesis_message_g", "250");
	g_pCvar_Message_Notice_Nemesis_B = register_cvar("zm_notice_nemesis_message_b", "0");
	g_pCvar_Message_Notice_Nemesis_X = register_cvar("zm_notice_nemesis_message_x", "-1.0");
	g_pCvar_Message_Notice_Nemesis_Y = register_cvar("zm_notice_nemesis_message_y", "0.75");
	g_pCvar_Message_Notice_Nemesis_Effects = register_cvar("zm_notice_nemesis_message_effects", "0");
	g_pCvar_Message_Notice_Nemesis_Fxtime = register_cvar("zm_notice_nemesis_message_fxtime", "0.1");
	g_pCvar_Message_Notice_Nemesis_Holdtime = register_cvar("zm_notice_nemesis_message_holdtime", "1.5");
	g_pCvar_Message_Notice_Nemesis_Fadeintime = register_cvar("zm_notice_nemesis_message_fadeintime", "2.0");
	g_pCvar_Message_Notice_Nemesis_Fadeouttime = register_cvar("zm_notice_nemesis_message_fadeouttime", "1.5");
	g_pCvar_Message_Notice_Nemesis_Channel = register_cvar("zm_notice_nemesis_message_channel", "-1");

	g_pCvar_All_Messages_Converted = register_cvar("zm_all_messages_are_converted_to_hud", "0");

	// Initialize arrays
	g_aSound_Nemesis = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND NEMESIS", g_aSound_Nemesis);

	// If we couldn't load custom sounds from file, use and save default ones
	if (ArraySize(g_aSound_Nemesis) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Nemesis; i++)
		{
			ArrayPushString(g_aSound_Nemesis, g_Sound_Nemesis[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND NEMESIS", g_aSound_Nemesis);
	}

	for (new i = 0; i < sizeof g_Sound_Nemesis; i++)
	{
		precache_sound(g_Sound_Nemesis[i]);
	}
}

// Deathmatch module's player respawn forward
public zp_fw_deathmatch_respawn_pre(iPlayer)
{
	// Respawning allowed?
	if (!get_pcvar_num(g_pCvar_Nemesis_Allow_Respawn))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_core_spawn_post(iPlayer)
{
	zp_core_respawn_as_zombie(iPlayer, false);
}

public zp_fw_gamemodes_choose_pre(iGame_Mode_ID, iSkipchecks)
{
	if (!iSkipchecks)
	{
		// Random chance
		if (random_num(1, get_pcvar_num(g_pCvar_Nemesis_Chance)) != 1)
		{
			return PLUGIN_HANDLED;
		}

		// Min players
		if (Get_Alive_Count() < get_pcvar_num(g_pCvar_Nemesis_Min_Players))
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
	zp_class_nemesis_set(g_iTarget_Player);

	for (new i = 1; i <= MaxClients; i++)
	{
		// Not alive
		if (!is_user_alive(i))
		{
			continue;
		}

		if (zp_class_nemesis_get(i))
		{
			continue;
		}

		rg_set_user_team(i, TEAM_CT);
	}

	if (get_pcvar_num(g_pCvar_Nemesis_Sounds))
	{
		Play_Sound_To_Clients(g_Sound_Nemesis[random(sizeof g_Sound_Nemesis)]);
	}

	if (get_pcvar_num(g_pCvar_Notice_Nemesis_Show_Hud))
	{
		new szPlayer_Name[32];

		GET_USER_NAME(g_iTarget_Player, szPlayer_Name, charsmax(szPlayer_Name));

		if (get_pcvar_num(g_pCvar_All_Messages_Converted) || get_pcvar_num(g_pCvar_Message_Notice_Nemesis_Converted))
		{
			set_hudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Nemesis_R),
				get_pcvar_num(g_pCvar_Message_Notice_Nemesis_G),
				get_pcvar_num(g_pCvar_Message_Notice_Nemesis_B),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_X),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Nemesis_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Fadeouttime),
				get_pcvar_num(g_pCvar_Message_Notice_Nemesis_Channel)
			);

			show_hudmessage(0, "%L", LANG_PLAYER, "NOTICE_NEMESIS", szPlayer_Name);
		}

		else
		{
			set_dhudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Nemesis_R),
				get_pcvar_num(g_pCvar_Message_Notice_Nemesis_G),
				get_pcvar_num(g_pCvar_Message_Notice_Nemesis_B),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_X),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Nemesis_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Nemesis_Fadeouttime)
			);

			show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_NEMESIS", szPlayer_Name);
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