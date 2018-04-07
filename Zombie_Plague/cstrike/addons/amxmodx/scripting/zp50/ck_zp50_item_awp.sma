/* AMX Mod X
*	[ZP] Item AWP Magnum Sniper.
*	Author: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "item awp magnum"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

/*												zp50_item_awp.sma																	*/

//	[RU] Название айтема.
//	[EN] Item szName.
#define ITEM_AWP_NAME "AWP Magnum Sniper"


//	[RU] Цена айтема.
//	[EN] Item cost.
#define ITEM_AWP_COST 8

#include <amxmodx>
#include <cs_util>
#include <ck_zp50_kernel>
#include <ck_zp50_items>

#define LIBRARY_SURVIVOR "ck_zp50_class_survivor"
#include <ck_zp50_class_survivor>

#define LIBRARY_SNIPER "ck_zp50_class_sniper"
#include <ck_zp50_class_sniper>

new g_Item_ID;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_Item_ID = zp_items_register(ITEM_AWP_NAME, ITEM_AWP_COST);
}

public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const szModule[])
{
	if (equal(szModule, LIBRARY_SURVIVOR) || equal(szModule, LIBRARY_SNIPER))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public native_filter(const szName[], iIndex, iTrap)
{
	if (!iTrap)
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
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

	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(iPlayer))
	{
		return ZP_ITEM_DONT_SHOW;
	}

	if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(iPlayer))
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

	rg_give_item(iPlayer, "weapon_awp", GT_DROP_AND_REPLACE);

	rg_set_user_bpammo(iPlayer, WEAPON_AWP, 30);
}