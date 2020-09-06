#if defined _zpe_class_nemesis_included

  #endinput

#endif

#define _zpe_class_nemesis_included

#include <cs_util_const>

public stock iBit_Nemesis;

/**
 * Returns whether a player is a Nemesis.
 *
 * @param {%0} Player index.
 *
 * @return True if it is, false otherwise.
 */
#define zpe_class_nemesis_get(%0) BIT_VALID(iBit_Nemesis, %0)

/**
 * Forces a player to become a Nemesis.
 *
 * @param {player} Player index.
 *
 * @return None.
 */
native zpe_class_nemesis_set(player);

/**
 * Returns number of alive Nemesis.
 *
 * @return Nemesis count.
 */
native zpe_class_nemesis_get_count();