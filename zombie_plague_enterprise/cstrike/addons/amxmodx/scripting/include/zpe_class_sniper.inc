#if defined _zpe_class_sniper_included

  #endinput

#endif

#define _zpe_class_sniper_included

#include <cs_util_const>

public stock iBit_Sniper;

/**
 * Returns whether a player is a Sniper.
 *
 * @param {%0} Player index.
 *
 * @return True if it is, false otherwise.
 */
#define zpe_class_sniper_get(%0) BIT_VALID(iBit_Sniper, %0)

/**
 * Forces a player to become a Sniper.
 *
 * @param {player} Player index.
 *
 * @return None.
 */
native zpe_class_sniper_set(player);

/**
 * Returns number of alive Sniper.
 *
 * @return Sniper count.
 */
native zpe_class_sniper_get_count();