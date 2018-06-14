/* AMX Mod X
*	[ZP] Item M249 Para Machinegun.
*	Author: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "item m249"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

/*												zp50_item_m249.sma																	*/

//	[RU] Название айтема.
//	[EN] Item name.
#define ITEM_M249_NAME "M249 Para Machinegun"


//	[RU] Цена айтема.
//	[EN] Item cost.
#define ITEM_M249_COST 10

#include <amxmodx>
#include <cs_util>
#include <ck_zp50_kernel>
#include <ck_zp50_items>
#include <ck_zp50_class_survivor>
#include <ck_zp50_class_sniper>

new g_Item_ID;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_Item_ID = zp_items_register(ITEM_M249_NAME, ITEM_M249_COST);
}

public zp_fw_items_select_pre(iPlayer, iItem_ID)
{
	// This is not our item
	if (iItem_ID != g_Item_ID)
	{
		return ZP_ITEM_AVAILABLE;
	}

	if (zp_core_is_zombie(iPlayer))
	{
		return ZP_ITEM_DONT_SHOW;
	}

	if (zp_class_survivor_get(iPlayer))
	{
		return ZP_ITEM_DONT_SHOW;
	}

	if (zp_class_sniper_get(iPlayer))
	{
		return ZP_ITEM_DONT_SHOW;
	}

	return ZP_ITEM_AVAILABLE;
}

public zp_fw_items_select_post(iPlayer, iItem_ID)
{
	// This is not our item
	if (iItem_ID != g_Item_ID)
	{
		return;
	}

	rg_set_user_bpammo(iPlayer, WEAPON_M249, 200);

	rg_give_item(iPlayer, "weapon_m249");
}