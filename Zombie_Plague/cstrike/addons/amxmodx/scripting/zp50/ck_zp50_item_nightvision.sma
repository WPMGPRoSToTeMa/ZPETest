/* AMX Mod X
*	[ZP] Item Nightvision.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "item nightvision"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

/*												zp50_item_nightvision.sma																	*/

//	[RU] Название айтема.
//	[EN] Item szName.
#define ITEM_NIGHTVISION_NAME "Nightvision"


//	[RU] Цена айтема.
//	[EN] Item cost.
#define ITEM_NIGHTVISION_COST 15

#include <amxmodx>
#include <cs_util>
#include <cstrike>
#include <ck_zp50_kernel>
#include <ck_zp50_items>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_assassin>
#include <ck_zp50_class_survivor>
#include <ck_zp50_class_sniper>

new g_Item_ID;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_Item_ID = zp_items_register(ITEM_NIGHTVISION_NAME, ITEM_NIGHTVISION_COST);
}

public zp_fw_items_select_pre(iPlayer, iItem_ID)
{
	// This is not our item
	if (iItem_ID != g_Item_ID)
	{
		return ZP_ITEM_AVAILABLE;
	}

	// Nightvision only available to humans
	if (zp_class_nemesis_get(iPlayer))
	{
		return ZP_ITEM_DONT_SHOW;
	}

	if (zp_class_assassin_get(iPlayer))
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

	if (zp_core_is_zombie(iPlayer))
	{
		return ZP_ITEM_DONT_SHOW;
	}

	// Player already has nightvision
	if (cs_get_user_nvg(iPlayer))
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

	// Give player nightvision and enable it automatically
	cs_set_user_nvg(iPlayer, 1);

	client_cmd(iPlayer, "nightvision");
}