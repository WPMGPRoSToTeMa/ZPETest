#if defined _zpe_random_spawn_included

  #endinput

#endif

#define _zpe_random_spawn_included

/**
 * Moves a player to a random spawn point.
 *
 * @param id			Player index.
 * @param csdmspawns	Ue CSDM spawn points instead of map defaults.
 */
native zp_random_spawn_do(id, csdmspawns = true)