#if defined _ck_zp50_deathmatch_included

  #endinput

#endif

#define _ck_zp50_deathmatch_included


/**
 * Called before the deathmatch module respawns a player.
 * Returning PLUGIN_HANDLED will block respawn.
 *
 * @param id		Player index.
 */
forward zp_fw_deathmatch_respawn_pre(id)