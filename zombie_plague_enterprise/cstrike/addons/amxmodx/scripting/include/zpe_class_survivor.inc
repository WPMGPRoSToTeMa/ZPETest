#if defined _zpe_class_survivor_included

  #endinput

#endif

#define _zpe_class_survivor_included

/**
 * Returns whether a player is a Survivor.
 *
 * @param id		Player index.
 * @return			True if it is, false otherwise.
 */
#define zp_class_survivor_get(%0)	BIT_VALID(g_iBit_Survivor, %0)

new stock g_iBit_Survivor;

public zp_fw_class_survivor_bit_change(iBit_Sum)
{
	g_iBit_Survivor = iBit_Sum;
}

/**
 * Forces a player to become a Survivor.
 *
 * @param id		Player index.
 * @return			True on success, false otherwise.
 */
native zp_class_survivor_set(id)

/**
 * Returns number of alive survivors.
 *
 * @return		Survivor count.
 */
native zp_class_survivor_get_count()
