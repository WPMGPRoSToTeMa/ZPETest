/* AMX Mod X
*	[ZP] Item G3SG1 Auto-Sniper.
*	Author: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "item g3sg1"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

/*												zp50_item_g3sg1.sma																	*/

//	[RU] Название айтема.
//	[EN] Item name.
#define ITEM_G3SG1_NAME "G3SG1 Auto-Sniper"


//	[RU] Цена айтема.
//	[EN] Item cost.
#define ITEM_G3SG1_COST 12

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

	g_Item_ID = zp_items_register(ITEM_G3SG1_NAME, ITEM_G3SG1_COST);
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

	rg_set_user_bpammo(iPlayer, WEAPON_G3SG1, 90);

	rg_give_item(iPlayer, "weapon_g3sg1");
}