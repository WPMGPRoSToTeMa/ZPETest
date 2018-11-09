#if defined _zpe_class_nemesis_included

  #endinput

#endif

#define _zpe_class_nemesis_included


/**
 * Returns whether a player is a Nemesis.
 *
 * @param id		Player index.
 * @return			True if it is, false otherwise.
 */
#define zp_class_nemesis_get(%0)	BIT_VALID(g_iBit_Nemesis, %0)

new stock g_iBit_Nemesis;

public zp_fw_class_nemesis_bit_change(iBit_Sum)
{
	g_iBit_Nemesis = iBit_Sum;
}

/**
 * Forces a player to become a Nemesis.
 *
 * @param id		Player index.
 * @return			True on success, false otherwise.
 */
native zp_class_nemesis_set(id)

/**
 * Returns number of alive nemesis.
 *
 * @return		Nemesis count.
 */
native zp_class_nemesis_get_count()
