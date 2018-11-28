/* AMX Mod X
*	[ZPE] Item Flare Nade.
*	Author: C&K Corporation.
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

#define PLUGIN "item flare nade"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <zpe_kernel>
#include <zpe_items>
#include <zpe_class_survivor>
#include <zpe_class_sniper>

#define ZPE_SETTINGS_FILE "ZPE/zpe_items.ini"

#define ITEM_FLARE_NAME "Flare Nade"
#define ITEM_FLARE_COST 3

#define SOUND_MAX_LENGTH 64

new const g_Sound_Flare_Buy_Item[][] =
{
	"items/gunpickup2.wav"
};

new Array:g_aSound_Flare_Buy_Item;

new g_Item_ID;

new g_iMessage_ID_AmmoPickup;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_iMessage_ID_AmmoPickup = get_user_msgid("AmmoPickup");

	g_Item_ID = zpe_items_register(ITEM_FLARE_NAME, ITEM_FLARE_COST);
}

public plugin_precache()
{
	// Initialize arrays
	g_aSound_Flare_Buy_Item = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ADD FLARE GRENADE", g_aSound_Flare_Buy_Item);

	for (new i = 0; i < sizeof g_Sound_Flare_Buy_Item; i++)
	{
		precache_sound(g_Sound_Flare_Buy_Item[i]);
	}
}

public zpe_fw_items_select_pre(iPlayer, iItem_ID)
{
	// This is not our item
	if (iItem_ID != g_Item_ID)
	{
		return ZPE_ITEM_AVAILABLE;
	}

	if (zpe_core_is_zombie(iPlayer))
	{
		return ZPE_ITEM_DONT_SHOW;
	}

	if (zpe_class_survivor_get(iPlayer))
	{
		return ZPE_ITEM_DONT_SHOW;
	}

	if (zpe_class_sniper_get(iPlayer))
	{
		return ZPE_ITEM_DONT_SHOW;
	}

	return ZPE_ITEM_AVAILABLE;
}

public zpe_fw_items_select_post(iPlayer, iItem_ID)
{
	// This is not our item
	if (iItem_ID != g_Item_ID)
	{
		return;
	}

	new iAmmo = rg_get_user_bpammo(iPlayer, WEAPON_SMOKEGRENADE);

	if (iAmmo >= 1)
	{
		rg_set_user_bpammo(iPlayer, WEAPON_SMOKEGRENADE, iAmmo + 1);

		message_begin(MSG_ONE, g_iMessage_ID_AmmoPickup, _, iPlayer);
		write_byte(13); // Ammo id
		write_byte(1); // Ammount
		message_end();

		emit_sound(iPlayer, CHAN_ITEM, g_Sound_Flare_Buy_Item[random(sizeof g_Sound_Flare_Buy_Item)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}

	else
	{
		rg_give_item(iPlayer, "weapon_smokegrenade");
	}
}