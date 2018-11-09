#if defined _zpe_grenade_fire_included

  #endinput

#endif

#define _zpe_grenade_fire_included

/**
 * Returns whether a player is burning.
 *
 * @param id		Player index.
 */
native zp_grenade_fire_get(id)

/**
 * Sets a player on fire / stops burning.
 *
 * @param id		Player index.
 * @param set		True to set on fire, false to stop burning.
 * @return			True on success, false otherwise.
 */
native zp_grenade_fire_set(id, set = true)

/**
 * Called when a player is about to start burning.
 * Returning PLUGIN_HANDLED will block it.
 *
 * @param id		Player index.
 */
forward zp_fw_grenade_fire_pre(id)