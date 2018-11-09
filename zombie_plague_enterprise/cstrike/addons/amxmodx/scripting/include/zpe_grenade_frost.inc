#if defined _zpe_grenade_frost_included

  #endinput

#endif

#define _zpe_grenade_frost_included

/**
 * Returns whether a player is frozen.
 *
 * @param id		Player index.
 */
native zp_grenade_frost_get(id)

/**
 * Freezes / unfreezes a player.
 *
 * @param id		Player index.
 * @param set		True to freeze, false to unfreeze.
 * @return			True on success, false otherwise.
 */
native zp_grenade_frost_set(id, set = true)

/**
 * Called when a player is about to be frozen.
 * Returning PLUGIN_HANDLED will block it.
 *
 * @param id		Player index.
 */
forward zp_fw_grenade_frost_pre(id)

/**
 * Called after a player recovers from a frost nade.
 *
 * @param id		Player index.
 */
forward zp_fw_grenade_frost_unfreeze(id)
