#if defined _ck_zp50_flashlight_included

  #endinput

#endif

#define _ck_zp50_flashlight_included

/**
 * Returns a player's custom flashlight batteries charge.
 *
 * @param id		Player index.
 * @return			Charge percent (0 to 100), or -1 if custom flashlight is disabled.
 */
native zp_flashlight_get_charge(id)

/**
 * Sets a player's custom flashlight batteries charge.
 *
 * @param id		Player index.
 * @param value		New charge percent (0 to 100).
 */
native zp_flashlight_set_charge(id, charge)