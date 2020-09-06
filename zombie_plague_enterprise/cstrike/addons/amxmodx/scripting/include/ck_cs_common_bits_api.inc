#if defined _common_bits_included

  #endinput

#endif

#define _common_bits_included

#include <cs_util>

public stock iBit_Alive;

/**
 * Returns whether a player is alive.
 *
 * @param {%0} Player index.
 *
 * @return True if it is, false otherwise.
 */
#define is_player_alive(%0) BIT_VALID(iBit_Alive, %0)

public stock iBit_Connected;

/**
 * Returns whether a player is connected.
 *
 * @param {%0} Player index.
 *
 * @return True if it is, false otherwise.
 */
#define is_player_connected(%0) BIT_VALID(iBit_Connected, %0)