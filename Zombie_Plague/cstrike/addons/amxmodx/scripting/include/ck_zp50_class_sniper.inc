#if defined _ck_zp50_class_sniper_included

  #endinput

#endif

#define _ck_zp50_class_sniper_included

/**
 * Returns whether a player is a sniper.
 *
 * @param id		Player index.
 * @return			True if it is, false otherwise.
 */
#define zp_class_sniper_get(%0)	BIT_VALID(g_iBit_Sniper, %0)

new stock g_iBit_Sniper;

public zp_fw_class_sniper_bit_change(iBit_Sum)
{
	g_iBit_Sniper = iBit_Sum;
}

/**
 * Forces a player to become a sniper.
 *
 * @param id		Player index.
 * @return			True on success, false otherwise.
 */
native zp_class_sniper_set(id)

/**
 * Returns number of alive sniper.
 *
 * @return		sniper count.
 */
native zp_class_sniper_get_count()