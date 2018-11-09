/* AMX Mod X
*	[ZPE] Items Ammopacks.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	https://git.ckcorp.ru/CK/AMXX-MODES - development.
*
*	Support is provided only on the site.
*/

#define PLUGIN "items ammopacks"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <zpe_items>
#include <zpe_ammopacks>

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public zp_fw_items_select_pre(iPlayer, iItem_ID, iIgnore_Cost)
{
	// Ignore item costs?
	if (iIgnore_Cost)
	{
		return ZP_ITEM_AVAILABLE;
	}

	// Get current and required ammo packs
	new iCurrent_Ammopacks = zp_ammopacks_get(iPlayer);
	new iRequired_Ammopacks = zp_items_get_cost(iItem_ID);

	// Not enough ammo packs
	if (iCurrent_Ammopacks < iRequired_Ammopacks)
	{
		return ZP_ITEM_NOT_AVAILABLE;
	}

	return ZP_ITEM_AVAILABLE;
}

public zp_fw_items_select_post(iPlayer, iItem_ID, iIgnore_Cost)
{
	// Ignore item costs?
	if (iIgnore_Cost)
	{
		return;
	}

	// Get current and required ammo packs
	new iCurrent_Ammopacks = zp_ammopacks_get(iPlayer);
	new iRequired_Ammopacks = zp_items_get_cost(iItem_ID);

	// Deduct item's ammo packs after purchase event
	zp_ammopacks_set(iPlayer, iCurrent_Ammopacks - iRequired_Ammopacks);
}