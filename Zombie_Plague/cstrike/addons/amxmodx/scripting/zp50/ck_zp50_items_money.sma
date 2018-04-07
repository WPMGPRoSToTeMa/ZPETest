/* AMX Mod X
*	[ZP] Items Money.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "items money"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <ck_zp50_items>

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public zp_fw_items_select_pre(iPlayer, iItem_ID, iIgnorecost)
{
	// Ignore item costs?
	if (iIgnorecost)
	{
		return ZP_ITEM_AVAILABLE;
	}

	// Get current and required money
	new iCurrent_Money = CS_GET_USER_MONEY(iPlayer);
	new iRequired_money = zp_items_get_cost(iItem_ID);

	// Not enough money
	if (iCurrent_Money < iRequired_money)
	{
		return ZP_ITEM_NOT_AVAILABLE;
	}

	return ZP_ITEM_AVAILABLE;
}

public zp_fw_items_select_post(iPlayer, iItem_ID, iIgnorecost)
{
	// Ignore item costs?
	if (iIgnorecost)
	{
		return;
	}

	// Get current and required money
	new iCurrent_Money = CS_GET_USER_MONEY(iPlayer);
	new iRequired_money = zp_items_get_cost(iItem_ID);

	// Deduct item's money after purchase event
	CS_SET_USER_MONEY(iPlayer, iCurrent_Money - iRequired_money);
}