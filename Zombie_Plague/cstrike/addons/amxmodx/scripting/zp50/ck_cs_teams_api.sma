/* AMX Mod X
*	CS Teams API.
*	Author: WiLS. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "cs teams api"
#define VERSION "3.1.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>

new const CS_TEAM_NAMES[][] =
{
	"UNASSIGNED",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

new g_Message_Team_Info;

new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_Message_Team_Info = get_user_msgid("TeamInfo");
}

public plugin_natives()
{
	register_library("ck_cs_teams_api");

	register_native("cs_set_player_team", "native_set_player_team");
}

public native_set_player_team(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[CS] Player is not in game (%d)", iPlayer);

		return false;
	}

	new CsTeams:iTeam = CsTeams:get_param(2);

	if (iTeam < CS_TEAM_UNASSIGNED || iTeam > CS_TEAM_SPECTATOR)
	{
		log_error(AMX_ERR_NATIVE, "[CS] Invalid team %d", iTeam);

		return false;
	}

	new iUpdate = get_param(3);

	fm_cs_set_user_team(iPlayer, iTeam, iUpdate);

	return true;
}

// Set a player's team
stock fm_cs_set_user_team(iPlayer, CsTeams:iTeam, iSend_Message)
{
	// Already belongs to the team
	if (CS_GET_USER_TEAM(iPlayer) == iTeam)
	{
		return;
	}

	// Set team offset
	CS_SET_USER_TEAM(iPlayer, iTeam);

	// Send message to update team?
	if (iSend_Message)
	{
		fm_cs_set_user_team_msg(iPlayer);
	}
}

// Send user team message (note: this next message can be received by other plugins)
public fm_cs_set_user_team_msg(iPlayer)
{
	// Tell everyone my new team
	emessage_begin(MSG_ALL, g_Message_Team_Info);
	ewrite_byte(iPlayer); // player
	ewrite_string(CS_TEAM_NAMES[CS_GET_USER_TEAM(iPlayer)]); // team
	emessage_end();
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	BIT_SUB(g_iBit_Connected, iPlayer);
}