/* AMX Mod X
*	[ZP] Ammopacks.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "ammopacks"
#define VERSION "5.2.5.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>

#define Is_User_Valid(%1) (0 < %1 <= MaxClients)

new g_Ammo_Packs[MAX_PLAYERS + 1];

new g_Msg_Hide_Weapon;
new g_Msg_Crosshair;

new g_pCvar_Starting_Ammo_Packs;
new g_pCvar_Disable_Money;

new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Starting_Ammo_Packs = register_cvar("zm_starting_ammo_packs", "5");
	g_pCvar_Disable_Money = register_cvar("zm_disable_money", "0");

	g_Msg_Hide_Weapon = get_user_msgid("HideWeapon");
	g_Msg_Crosshair = get_user_msgid("Crosshair");

	register_event("ResetHUD", "Event_Reset_Hud", "be");
}

public plugin_natives()
{
	register_library("ck_zp50_ammopacks");

	register_native("zp_ammopacks_get", "native_ammopacks_get");
	register_native("zp_ammopacks_set", "native_ammopacks_set");
}

public native_ammopacks_get(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (!Is_User_Valid(iPlayer) || BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return -1;
	}

	return g_Ammo_Packs[iPlayer];
}

public native_ammopacks_set(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (!Is_User_Valid(iPlayer) || BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	new iAmount = get_param(2);

	g_Ammo_Packs[iPlayer] = iAmount;

	return true;
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);

	g_Ammo_Packs[iPlayer] = get_pcvar_num(g_pCvar_Starting_Ammo_Packs);
}

public Event_Reset_Hud(iPlayer)
{
	if (!get_pcvar_num(g_pCvar_Disable_Money))
	{
		set_task(0.1, "Hide_Money", iPlayer);
	}
}

public Hide_Money(iPlayer)
{
	if (BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		return;
	}

	// Hide money
	message_begin(MSG_ONE_UNRELIABLE, g_Msg_Hide_Weapon, { 0.0, 0.0, 0.0 }, iPlayer);
	write_byte(1 << 5); // what to hide bitsum
	message_end();

	// Hide the HL crosshair that's drawn
	message_begin(MSG_ONE_UNRELIABLE, g_Msg_Crosshair, { 0.0, 0.0, 0.0 }, iPlayer);
	write_byte(0); // toggle
	message_end();
}

public client_disconnected(iPlayer)
{
	BIT_SUB(g_iBit_Connected, iPlayer);
}