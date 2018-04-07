/* AMX Mod X
*	[ZP] Item Armor.
*	Author: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "item armor"
#define VERSION "1.1.1.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_items.ini"

//	[RU] Название айтема.
//	[EN] Item name.
#define ITEM_NAME "Armor"

//	[RU] Цена айтема.
//	[EN] Item cost.
#define ITEM_COST 5

new const g_Sound_Armor_Buy[][] =
{
	"items/ammopickup1.wav",
	"items/ammopickup2.wav"
};

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_zp50_kernel>
#include <ck_zp50_items>

#define SOUND_MAX_LENGTH 64

new Array:g_aSound_Armor_Buy;

new g_pCvar_Armor_Buy_Count;
new g_pCvar_Armor_Buy_Sound;
new g_pCvar_Item_Armor_Type;

new g_Item_ID;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Armor_Buy_Count = register_cvar("zm_armor_buy_count", "70");
	g_pCvar_Armor_Buy_Sound = register_cvar("zm_armor_buy_sound", "1");
	g_pCvar_Item_Armor_Type = register_cvar("zm_item_armor_type", "0");

	g_Item_ID = zp_items_register(ITEM_NAME, ITEM_COST);
}

public plugin_precache()
{
	// Initialize arrays
	g_aSound_Armor_Buy = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "BUY ARMOR", g_aSound_Armor_Buy);

	// If we couldn't load custom sounds from file, use and save default ones
	if (ArraySize(g_aSound_Armor_Buy) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Armor_Buy; i++)
		{
			ArrayPushString(g_aSound_Armor_Buy, g_Sound_Armor_Buy[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "BUY ARMOR", g_aSound_Armor_Buy);
	}

	for (new i = 0; i < sizeof g_Sound_Armor_Buy; i++)
	{
		precache_sound(g_Sound_Armor_Buy[i]);
	}
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

	return ZP_ITEM_AVAILABLE;
}

public zp_fw_items_select_post(iPlayer, iItem_ID)
{
	if (iItem_ID != g_Item_ID)
	{
		return;
	}

	new ArmorType:Armor_Type;

	new iArmor = rg_get_user_armor(iPlayer, Armor_Type) + get_pcvar_num(g_pCvar_Armor_Buy_Count);

	if (get_pcvar_num(g_pCvar_Item_Armor_Type))
	{
		rg_set_user_armor(iPlayer, iArmor, ARMOR_VESTHELM);
	}

	else
	{
		rg_set_user_armor(iPlayer, iArmor, ARMOR_KEVLAR);
	}

	if (get_pcvar_num(g_pCvar_Armor_Buy_Sound))
	{
		emit_sound(iPlayer, CHAN_STATIC, g_Sound_Armor_Buy[random(sizeof g_Sound_Armor_Buy)], 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
}