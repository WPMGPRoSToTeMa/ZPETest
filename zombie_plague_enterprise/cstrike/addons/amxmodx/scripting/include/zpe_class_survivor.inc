#if defined _zpe_class_survivor_included

  #endinput

#endif

#define _zpe_class_survivor_included

#include <cs_util_const>

public stock iBit_Survivor;

/**
 * Returns whether a player is a Survivor.
 *
 * @param {%0} Player index.
 *
 * @return True if it is, false otherwise.
 */
#define zpe_class_survivor_get(%0) BIT_VALID(iBit_Survivor, %0)

/**
 * Forces a player to become a Survivor.
 *
 * @param {player} Player index.
 *
 * @return None.
 */
native zpe_class_survivor_set(player);

/**
 * Returns number of alive Survivors.
 *
 * @return Survivor count.
 */
native zpe_class_survivor_get_count();