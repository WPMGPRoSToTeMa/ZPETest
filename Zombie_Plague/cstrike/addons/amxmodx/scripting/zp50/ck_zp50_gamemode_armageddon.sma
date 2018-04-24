/* AMX Mod X
*	[ZP] Gamemode Armageddon.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "gamemode armageddon"
#define VERSION "5.2.6.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

new const g_Sounds_Armageddon[][] =
{
	"zombie_plague/nemesis1.wav",
	"zombie_plague/survivor1.wav"
};

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_zp50_gamemodes>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_survivor>
#include <ck_zp50_deathmatch>

#define SOUND_MAX_LENGTH 64

new Array:g_aSound_Armageddon;

new g_pCvar_Armageddon_Chance;
new g_pCvar_Armageddon_Min_Players;
new g_pCvar_Armageddon_Ratio;

new g_pCvar_Armageddon_Nemesis_HP_Multi;
new g_pCvar_Armageddon_Survivor_HP_Multi;

new g_pCvar_Armageddon_Sounds;
new g_pCvar_Armageddon_Allow_Respawn;

new g_pCvar_Notice_Armageddon_Show_Hud;

new g_pCvar_Message_Notice_Armageddon_Converted;
new g_pCvar_Message_Notice_Armageddon_R;
new g_pCvar_Message_Notice_Armageddon_G;
new g_pCvar_Message_Notice_Armageddon_B;
new g_pCvar_Message_Notice_Armageddon_X;
new g_pCvar_Message_Notice_Armageddon_Y;
new g_pCvar_Message_Notice_Armageddon_Effects;
new g_pCvar_Message_Notice_Armageddon_Fxtime;
new g_pCvar_Message_Notice_Armageddon_Holdtime;
new g_pCvar_Message_Notice_Armageddon_Fadeintime;
new g_pCvar_Message_Notice_Armageddon_Fadeouttime;
new g_pCvar_Message_Notice_Armageddon_Channel;

new g_pCvar_All_Messages_Converted;

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	// Register game mode at precache (plugin gets paused after this)
	zp_gamemodes_register("Armageddon Mode");

	g_pCvar_Armageddon_Chance = register_cvar("zm_armageddon_chance", "20");
	g_pCvar_Armageddon_Min_Players = register_cvar("zm_armageddon_min_players", "0");
	g_pCvar_Armageddon_Ratio = register_cvar("zm_armageddon_ratio", "0.5");
	g_pCvar_Armageddon_Nemesis_HP_Multi = register_cvar("zm_armageddon_nemesis_hp_multi", "0.25");
	g_pCvar_Armageddon_Survivor_HP_Multi = register_cvar("zm_armageddon_survivor_hp_multi", "0.25");
	g_pCvar_Armageddon_Sounds = register_cvar("zm_armageddon_sounds", "1");
	g_pCvar_Armageddon_Allow_Respawn = register_cvar("zm_armageddon_allow_respawn", "0");

	g_pCvar_Notice_Armageddon_Show_Hud = register_cvar("zm_notice_armageddon_show_hud", "1");

	g_pCvar_Message_Notice_Armageddon_Converted = register_cvar("zm_notice_armageddon_message_converted", "0");
	g_pCvar_Message_Notice_Armageddon_R = register_cvar("zm_notice_armageddon_message_r", "0");
	g_pCvar_Message_Notice_Armageddon_G = register_cvar("zm_notice_armageddon_message_g", "250");
	g_pCvar_Message_Notice_Armageddon_B = register_cvar("zm_notice_armageddon_message_b", "0");
	g_pCvar_Message_Notice_Armageddon_X = register_cvar("zm_notice_armageddon_message_x", "-1.0");
	g_pCvar_Message_Notice_Armageddon_Y = register_cvar("zm_notice_armageddon_message_y", "0.75");
	g_pCvar_Message_Notice_Armageddon_Effects = register_cvar("zm_notice_armageddon_message_effects", "0");
	g_pCvar_Message_Notice_Armageddon_Fxtime = register_cvar("zm_notice_armageddon_message_fxtime", "0.1");
	g_pCvar_Message_Notice_Armageddon_Holdtime = register_cvar("zm_notice_armageddon_message_holdtime", "1.5");
	g_pCvar_Message_Notice_Armageddon_Fadeintime = register_cvar("zm_notice_armageddon_message_fadeintime", "2.0");
	g_pCvar_Message_Notice_Armageddon_Fadeouttime = register_cvar("zm_notice_armageddon_message_fadeouttime", "1.5");
	g_pCvar_Message_Notice_Armageddon_Channel = register_cvar("zm_notice_armageddon_message_channel", "-1");

	g_pCvar_All_Messages_Converted = register_cvar("zm_all_messages_are_converted_to_hud", "0");

	// Initialize arrays
	g_aSound_Armageddon = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND ARMAGEDDON", g_aSound_Armageddon);

	// If we couldn't load custom sounds from file, use and save default ones
	if (ArraySize(g_aSound_Armageddon) == 0)
	{
		for (new i = 0; i < sizeof g_Sounds_Armageddon; i++)
		{
			ArrayPushString(g_aSound_Armageddon, g_Sounds_Armageddon[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND ARMAGEDDON", g_aSound_Armageddon);
	}

	for (new i = 0; i < sizeof g_Sounds_Armageddon; i++)
	{
		precache_sound(g_Sounds_Armageddon[i]);
	}
}

// Deathmatch module's player respawn forward
public zp_fw_deathmatch_respawn_pre(iPlayer)
{
	// Respawning allowed?
	if (!get_pcvar_num(g_pCvar_Armageddon_Allow_Respawn))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_choose_pre(iGame_Mode_ID, iSkipchecks)
{
	if (!iSkipchecks)
	{
		// Random chance
		if (random_num(1, get_pcvar_num(g_pCvar_Armageddon_Chance)) != 1)
		{
			return PLUGIN_HANDLED;
		}

		// Min players
		if (Get_Alive_Count() < get_pcvar_num(g_pCvar_Armageddon_Min_Players))
		{
			return PLUGIN_HANDLED;
		}
	}

	// Game mode allowed
	return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_start()
{
	// Calculate player counts
	new iPlayer;
	new iAlive_Count = Get_Alive_Count();
	new iSurvivor_Count = floatround(iAlive_Count * get_pcvar_float(g_pCvar_Armageddon_Ratio), floatround_ceil);
	new iNemesis_Count = iAlive_Count - iSurvivor_Count;

	// Turn specified amount of players into Survivors
	new iSurvivors;
	new iMax_Survivors = iSurvivor_Count;

	while (iSurvivors < iMax_Survivors)
	{
		// Choose random guy
		iPlayer = Get_Random_Alive_Player();

		// Already a survivor?
		if (zp_class_survivor_get(iPlayer))
		{
			continue;
		}

		// If not, turn him into one
		zp_class_survivor_set(iPlayer);

		iSurvivors++;

		// Apply survivor health multiplier
		SET_USER_HEALTH(iPlayer, Float:GET_USER_HEALTH(iPlayer) * get_pcvar_float(g_pCvar_Armageddon_Survivor_HP_Multi));
	}

	// Turn specified amount of players into Nemesis
	new iNemesis;
	new iMax_Nemesis = iNemesis_Count;

	while (iNemesis < iMax_Nemesis)
	{
		// Choose random guy
		iPlayer = Get_Random_Alive_Player();

		// Already a survivor or nemesis?
		if (zp_class_survivor_get(iPlayer) || zp_class_nemesis_get(iPlayer))
		{
			continue;
		}

		// If not, turn him into one
		zp_class_nemesis_set(iPlayer);

		iNemesis++;

		// Apply nemesis health multiplier
		SET_USER_HEALTH(iPlayer, Float:GET_USER_HEALTH(iPlayer) * get_pcvar_float(g_pCvar_Armageddon_Nemesis_HP_Multi));
	}

	if (get_pcvar_num(g_pCvar_Armageddon_Sounds))
	{
		Play_Sound_To_Clients(g_Sounds_Armageddon[random(sizeof g_Sounds_Armageddon)]);
	}

	if (get_pcvar_num(g_pCvar_Notice_Armageddon_Show_Hud))
	{
		if (get_pcvar_num(g_pCvar_All_Messages_Converted) || get_pcvar_num(g_pCvar_Message_Notice_Armageddon_Converted))
		{
			set_hudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Armageddon_R),
				get_pcvar_num(g_pCvar_Message_Notice_Armageddon_G),
				get_pcvar_num(g_pCvar_Message_Notice_Armageddon_B),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_X),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Armageddon_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Fadeouttime),
				get_pcvar_num(g_pCvar_Message_Notice_Armageddon_Channel)
			);

			show_hudmessage(0, "%L", LANG_PLAYER, "NOTICE_ARMAGEDDON");
		}

		else
		{
			set_dhudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Armageddon_R),
				get_pcvar_num(g_pCvar_Message_Notice_Armageddon_G),
				get_pcvar_num(g_pCvar_Message_Notice_Armageddon_B),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_X),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Armageddon_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Armageddon_Fadeouttime)
			);

			show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_ARMAGEDDON");
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
		if (is_user_alive(i)) // TODO: Fix: use bit = invalid player
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
		if (is_user_alive(i)) // TODO: Fix: use bit = invalid player
		{
			iPlayers[iCount++] = i;
		}
	}

	return iCount > 0 ? iPlayers[random(iCount)] : -1;
}