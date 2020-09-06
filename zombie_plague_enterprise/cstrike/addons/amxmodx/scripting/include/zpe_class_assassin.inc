#if defined _zpe_class_assassin_included

  #endinput

#endif

#define _zpe_class_assassin_included

#include <cs_util_const>

public stock iBit_Assassin;

/**
 * Returns whether a player is a Assassin.
 *
 * @param {%0} Player index.
 *
 * @return True if it is, false otherwise.
 */
#define zpe_class_assassin_get(%0) BIT_VALID(iBit_Assassin, %0)

/**
 * Forces a player to become a Assassin.
 *
 * @param {player} Player index.
 *
 * @return None.
 */
native zpe_class_assassin_set(player);

/**
 * Returns number of alive Assassin.
 *
 * @return Assassin count.
 */
native zpe_class_assassin_get_count();