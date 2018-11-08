#if defined _ck_zp50_ammopacks_included

  #endinput

#endif

#define _ck_zp50_ammopacks_included

/**
 * Returns a player's ammo pack count.
 *
 * @param id		Player index.
 * @return			Number of ammo packs owned.
 */
native zp_ammopacks_get(id)

/**
 * Sets a player's ammo pack count.
 *
 * @param id		Player index.
 * @param amount	New quantity of ammo packs owned.
 */
native zp_ammopacks_set(id, amount)