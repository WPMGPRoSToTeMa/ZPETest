/* AMX Mod X
*	[ZP] Gamemode assassin.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "gamemode assassin"
#define VERSION "5.2.10.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

new const g_Sounds_Assassin[][] =
{
	"zombie_plague/nemesis1.wav",
	"zombie_plague/nemesis2.wav"
};

#include <amxmodx>
#include <amxmisc>
#include <cs_util>
#include <amx_settings_api>
#include <ck_cs_teams_api>
#include <engine>
#include <ck_zp50_gamemodes>
#include <ck_zp50_class_assassin>
#include <ck_zp50_kernel>

#define SOUND_MAX_LENGTH 64

new Array:g_aSounds_Assassin;

new g_pCvar_Assassin_Chance;
new g_pCvar_Assassin_Min_Players;
new g_pCvar_Assassin_Sounds;
new g_pCvar_Assassin_Allow_Respawn;

new g_pCvar_Assassin_Lighting;

new g_pCvar_Notice_Assassin_Show_Hud;

new g_pCvar_Message_Notice_Assassin_Converted;
new g_pCvar_Message_Notice_Assassin_R;
new g_pCvar_Message_Notice_Assassin_G;
new g_pCvar_Message_Notice_Assassin_B;
new g_pCvar_Message_Notice_Assassin_X;
new g_pCvar_Message_Notice_Assassin_Y;
new g_pCvar_Message_Notice_Assassin_Effects;
new g_pCvar_Message_Notice_Assassin_Fxtime;
new g_pCvar_Message_Notice_Assassin_Holdtime;
new g_pCvar_Message_Notice_Assassin_Fadeintime;
new g_pCvar_Message_Notice_Assassin_Fadeouttime;
new g_pCvar_Message_Notice_Assassin_Channel;

new g_pCvar_All_Messages_Converted;

new g_iTarget_Player;

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	zp_gamemodes_register("Assassin Mode");

	g_pCvar_Assassin_Chance = register_cvar("zm_assassin_chance", "20");
	g_pCvar_Assassin_Min_Players = register_cvar("zm_assassin_min_players", "0");
	g_pCvar_Assassin_Sounds = register_cvar("zm_assassin_sounds", "1");
	g_pCvar_Assassin_Allow_Respawn = register_cvar("zm_assassin_allow_respawn", "0");

	g_pCvar_Assassin_Lighting = register_cvar("zm_assassin_lighting", "a");

	g_pCvar_Notice_Assassin_Show_Hud = register_cvar("zm_notice_assassin_show_hud", "1");

	g_pCvar_Message_Notice_Assassin_Converted = register_cvar("zm_notice_assassin_message_converted", "0");
	g_pCvar_Message_Notice_Assassin_R = register_cvar("zm_notice_assassin_message_r", "0");
	g_pCvar_Message_Notice_Assassin_G = register_cvar("zm_notice_assassin_message_g", "250");
	g_pCvar_Message_Notice_Assassin_B = register_cvar("zm_notice_assassin_message_b", "0");
	g_pCvar_Message_Notice_Assassin_X = register_cvar("zm_notice_assassin_message_x", "-1.0");
	g_pCvar_Message_Notice_Assassin_Y = register_cvar("zm_notice_assassin_message_y", "0.75");
	g_pCvar_Message_Notice_Assassin_Effects = register_cvar("zm_notice_assassin_message_effects", "0");
	g_pCvar_Message_Notice_Assassin_Fxtime = register_cvar("zm_notice_assassin_message_fxtime", "0.1");
	g_pCvar_Message_Notice_Assassin_Holdtime = register_cvar("zm_notice_assassin_message_holdtime", "1.5");
	g_pCvar_Message_Notice_Assassin_Fadeintime = register_cvar("zm_notice_assassin_message_fadeintime", "2.0");
	g_pCvar_Message_Notice_Assassin_Fadeouttime = register_cvar("zm_notice_assassin_message_fadeouttime", "1.5");
	g_pCvar_Message_Notice_Assassin_Channel = register_cvar("zm_notice_assassin_message_channel", "-1");

	g_pCvar_All_Messages_Converted = register_cvar("zm_all_messages_are_converted_to_hud", "0");

	// Initialize arrays
	g_aSounds_Assassin = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND ASSASSIN", g_aSounds_Assassin);

	// If we couldn't load custom sounds from file, use and save default ones
	if (ArraySize(g_aSounds_Assassin) == 0)
	{
		for (new i = 0; i < sizeof g_Sounds_Assassin; i++)
		{
			ArrayPushString(g_aSounds_Assassin, g_Sounds_Assassin[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND ASSASSIN", g_aSounds_Assassin);
	}

	for (new i = 0; i < sizeof g_Sounds_Assassin; i++)
	{
		precache_sound(g_Sounds_Assassin[i]);
	}
}

// Deathmatch module's player respawn forward
public zp_fw_deathmatch_respawn_pre(id)
{
	// Respawning allowed?
	if (!get_pcvar_num(g_pCvar_Assassin_Allow_Respawn))
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
		if (random_num(1, get_pcvar_num(g_pCvar_Assassin_Chance)) != 1)
		{
			return PLUGIN_HANDLED;
		}

		// Min players
		if (Get_Alive_Count() < get_pcvar_num(g_pCvar_Assassin_Min_Players))
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
	zp_class_assassin_set(g_iTarget_Player);

	for (new i = 1; i <= MaxClients; i++)
	{
		if (!is_user_alive(i))
		{
			continue;
		}

		if (zp_class_assassin_get(i))
		{
			continue;
		}

		cs_set_player_team(i, CS_TEAM_CT);
	}

	// Play assassin sound
	if (get_pcvar_num(g_pCvar_Assassin_Sounds))
	{
		Play_Sound_To_Clients(g_Sounds_Assassin[random(sizeof g_Sounds_Assassin)]);
	}

	if (get_pcvar_num(g_pCvar_Notice_Assassin_Show_Hud))
	{
		new szPlayer_Name[32];

		GET_USER_NAME(g_iTarget_Player, szPlayer_Name, charsmax(szPlayer_Name));

		if (get_pcvar_num(g_pCvar_All_Messages_Converted) || get_pcvar_num(g_pCvar_Message_Notice_Assassin_Converted))
		{
			set_hudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Assassin_R),
				get_pcvar_num(g_pCvar_Message_Notice_Assassin_G),
				get_pcvar_num(g_pCvar_Message_Notice_Assassin_B),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_X),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Assassin_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Fadeouttime),
				get_pcvar_num(g_pCvar_Message_Notice_Assassin_Channel)
			);

			show_hudmessage(0, "%L", LANG_PLAYER, "NOTICE_ASSASSIN", szPlayer_Name);
		}

		else
		{
			set_dhudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Assassin_R),
				get_pcvar_num(g_pCvar_Message_Notice_Assassin_G),
				get_pcvar_num(g_pCvar_Message_Notice_Assassin_B),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_X),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Assassin_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Assassin_Fadeouttime)
			)

			show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_ASSASSIN", szPlayer_Name);
		}
	}

	new szLighting[32];

	get_pcvar_string(g_pCvar_Assassin_Lighting, szLighting, charsmax(szLighting));

	set_lights(szLighting);
}

public zp_fw_gamemodes_end()
{
	// Setting The lighting Settings as before the Mode.
	new szConfiguration_Directory[32];

	get_configsdir(szConfiguration_Directory, charsmax(szConfiguration_Directory));

	// Execute config file (zm_settings.cfg)
	server_cmd("exec %s/zm_settings.cfg", szConfiguration_Directory);
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