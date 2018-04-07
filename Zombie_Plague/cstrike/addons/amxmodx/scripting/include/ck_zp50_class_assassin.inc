#if defined _ck_zp50_class_assassin_included

  #endinput

#endif

#define _ck_zp50_class_assassin_included


/**
 * Returns whether a player is a assassin.
 *
 * @param id		Player index.
 * @return			True if it is, false otherwise.
 */
#define zp_class_assassin_get(%0)	BIT_VALID(g_iBit_Assassin, %0)

new stock g_iBit_Assassin;

public zp_fw_class_asassin_bit_change(iBit_Sum)
{
	g_iBit_Assassin = iBit_Sum;
}

/**
 * Forces a player to become a assassin.
 *
 * @param id		Player index.
 * @return			True on success, false otherwise.
 */
native zp_class_assassin_set(id)

/**
 * Returns number of alive assassin.
 *
 * @return		assassin count.
 */
native zp_class_assassin_get_count()
