/* AMX Mod X
*	[ZPE] Gamemode survivor.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	https://git.ckcorp.ru/CK/AMXX-MODES - development.
*
*	Support is provided only on the site.
*/

#define PLUGIN "gamemode survivor"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_zp50_kernel>
#include <ck_zp50_gamemodes>
#include <ck_zp50_class_survivor>

#define ZPE_SETTINGS_FILE "ZPE/gamemode/zpe_survivor.ini"

#define SOUND_MAX_LENGTH 64

#define CHANCE(%0) (random(100) < (%0))

new const g_Sound_Survivor[][] =
{
	"zombie_plague/survivor1.wav",
	"zombie_plague/survivor2.wav"
};

new Array:g_aSound_Survivor;

new g_pCvar_Survivor_Chance;
new g_pCvar_Survivor_Min_Players;
new g_pCvar_Survivor_Sounds;
new g_pCvar_Survivor_Allow_Respawn;

new g_pCvar_Notice_Survivor_Show_Hud;

new g_pCvar_Message_Notice_Survivor_Converted;
new g_pCvar_Message_Notice_Survivor_R;
new g_pCvar_Message_Notice_Survivor_G;
new g_pCvar_Message_Notice_Survivor_B;
new g_pCvar_Message_Notice_Survivor_X;
new g_pCvar_Message_Notice_Survivor_Y;
new g_pCvar_Message_Notice_Survivor_Effects;
new g_pCvar_Message_Notice_Survivor_Fxtime;
new g_pCvar_Message_Notice_Survivor_Holdtime;
new g_pCvar_Message_Notice_Survivor_Fadeintime;
new g_pCvar_Message_Notice_Survivor_Fadeouttime;
new g_pCvar_Message_Notice_Survivor_Channel;

new g_pCvar_All_Messages_Converted;

new g_iTarget_Player;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Survivor_Chance = register_cvar("zpe_survivor_chance", "20");
	g_pCvar_Survivor_Min_Players = register_cvar("zpe_survivor_min_players", "0");
	g_pCvar_Survivor_Sounds = register_cvar("zpe_survivor_sounds", "1");
	g_pCvar_Survivor_Allow_Respawn = register_cvar("zpe_survivor_allow_respawn", "0");

	g_pCvar_Notice_Survivor_Show_Hud = register_cvar("zpe_notice_survivor_show_hud", "1");

	g_pCvar_Message_Notice_Survivor_Converted = register_cvar("zpe_notice_survivor_message_converted", "0");
	g_pCvar_Message_Notice_Survivor_R = register_cvar("zpe_notice_survivor_message_r", "0");
	g_pCvar_Message_Notice_Survivor_G = register_cvar("zpe_notice_survivor_message_g", "250");
	g_pCvar_Message_Notice_Survivor_B = register_cvar("zpe_notice_survivor_message_b", "0");
	g_pCvar_Message_Notice_Survivor_X = register_cvar("zpe_notice_survivor_message_x", "-1.0");
	g_pCvar_Message_Notice_Survivor_Y = register_cvar("zpe_notice_survivor_message_y", "0.75");
	g_pCvar_Message_Notice_Survivor_Effects = register_cvar("zpe_notice_survivor_message_effects", "0");
	g_pCvar_Message_Notice_Survivor_Fxtime = register_cvar("zpe_notice_survivor_message_fxtime", "0.1");
	g_pCvar_Message_Notice_Survivor_Holdtime = register_cvar("zpe_notice_survivor_message_holdtime", "1.5");
	g_pCvar_Message_Notice_Survivor_Fadeintime = register_cvar("zpe_notice_survivor_message_fadeintime", "2.0");
	g_pCvar_Message_Notice_Survivor_Fadeouttime = register_cvar("zpe_notice_survivor_message_fadeouttime", "1.5");
	g_pCvar_Message_Notice_Survivor_Channel = register_cvar("zpe_notice_survivor_message_channel", "-1");

	g_pCvar_All_Messages_Converted = register_cvar("zpe_all_messages_are_converted_to_hud", "0");
}

public plugin_precache()
{
	// Initialize arrays
	g_aSound_Survivor = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ROUND SURVIVOR", g_aSound_Survivor);

	for (new i = 0; i < sizeof g_Sound_Survivor; i++)
	{
		precache_sound(g_Sound_Survivor[i]);
	}
}

public plugin_cfg()
{
	server_cmd("exec addons/amxmodx/configs/ZPE/gamemode/zpe_survivor.cfg");

	// Register game mode at plugin_cfg (plugin gets paused after this)
	zp_gamemodes_register("Survivor Mode");
}

// Deathmatch module's player respawn forward
public zp_fw_deathmatch_respawn_pre(iPlayer)
{
	// Respawning allowed?
	if (!get_pcvar_num(g_pCvar_Survivor_Allow_Respawn))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_core_spawn_post(iPlayer)
{
	zp_core_respawn_as_zombie(iPlayer, true);
}

public zp_fw_gamemodes_choose_pre(iGame_Mode_ID, iSkipchecks)
{
	if (!iSkipchecks)
	{
		// Random chance
		if (CHANCE(get_pcvar_num(g_pCvar_Survivor_Chance)))
		{
			return PLUGIN_HANDLED;
		}

		// Min players
		if (Get_Alive_Count() < get_pcvar_num(g_pCvar_Survivor_Min_Players))
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
	zp_class_survivor_set(g_iTarget_Player);

	for (new i = 1; i <= MaxClients; i++)
	{
		if (!is_user_alive(i)) // Use bit - invalid player
		{
			continue;
		}

		if (zp_class_survivor_get(i) || zp_core_is_zombie(i))
		{
			continue;
		}

		zp_core_infect(i);
	}

	if (get_pcvar_num(g_pCvar_Survivor_Sounds))
	{
		Play_Sound_To_Clients(g_Sound_Survivor[random(sizeof g_Sound_Survivor)]);
	}

	if (get_pcvar_num(g_pCvar_Notice_Survivor_Show_Hud))
	{
		new szPlayer_Name[32];

		GET_USER_NAME(g_iTarget_Player, szPlayer_Name, charsmax(szPlayer_Name));

		if (get_pcvar_num(g_pCvar_All_Messages_Converted) || get_pcvar_num(g_pCvar_Message_Notice_Survivor_Converted))
		{
			set_hudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Survivor_R),
				get_pcvar_num(g_pCvar_Message_Notice_Survivor_G),
				get_pcvar_num(g_pCvar_Message_Notice_Survivor_B),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_X),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Survivor_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Fadeouttime),
				get_pcvar_num(g_pCvar_Message_Notice_Survivor_Channel)
			);

			show_hudmessage(0, "%L", LANG_PLAYER, "NOTICE_SURVIVOR", szPlayer_Name);
		}

		else
		{
			set_dhudmessage
			(
				get_pcvar_num(g_pCvar_Message_Notice_Survivor_R),
				get_pcvar_num(g_pCvar_Message_Notice_Survivor_G),
				get_pcvar_num(g_pCvar_Message_Notice_Survivor_B),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_X),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Y),
				get_pcvar_num(g_pCvar_Message_Notice_Survivor_Effects),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Fxtime),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Holdtime),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Notice_Survivor_Fadeouttime)
			);

			show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_SURVIVOR", szPlayer_Name);
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
		if (is_user_alive(i)) // Use bit - invalid player
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
		if (is_user_alive(i)) // Use bit - invalid player
		{
			iPlayers[iCount++] = i;
		}
	}

	return iCount > 0 ? iPlayers[random(iCount)] : -1;
}