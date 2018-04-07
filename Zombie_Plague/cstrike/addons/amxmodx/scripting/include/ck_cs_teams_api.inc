#if defined _ck_cs_teams_api_included

  #endinput

#endif

#define _ck_cs_teams_api_included

/**
 * Sets a player's team.
 *
 * @param id			Player index.
 * @param team			CS_TEAM_ constant.
 * @param update		Whether to update team on scoreboard.
 */
native cs_set_player_team(id, CsTeams:team, update = true)