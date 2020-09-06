/* AMX Mod X
*	Common Bits.
*	Author: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	https://git.ckcorp.ru/ck/game-dev/amxx-modes/zpe - development.
*
*	Support is provided only on the site.
*/

#define PLUGIN "common bits"
#define VERSION "1.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <reapi>
#include <ck_cs_common_bits_api>

new g_iBvar_Alive;
new g_iBvar_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_iBvar_Alive = get_bvar_id("iBit_Alive");
	g_iBvar_Connected = get_bvar_id("iBit_Connected");

	RegisterHookChain(RG_CSGameRules_PlayerSpawn, "RG_CSGameRules_PlayerSpawn_Post", 1);
	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_Post", 1);
}

public client_putinserver(iPlayer)
{
	set_bvar_num(g_iBvar_Connected, iBit_Connected | (1 << iPlayer));
}

public RG_CSGameRules_PlayerSpawn_Post(iPlayer)
{
	if (is_player_connected(iPlayer))
	{
		set_bvar_num(g_iBvar_Alive, iBit_Alive | (1 << iPlayer));
	}
}

public RG_CSGameRules_PlayerKilled_Post(iPlayer)
{
	set_bvar_num(g_iBvar_Alive, iBit_Alive & ~(1 << iPlayer));
}

public client_disconnected(iPlayer)
{
	set_bvar_num(g_iBvar_Alive, iBit_Alive & ~(1 << iPlayer));
	set_bvar_num(g_iBvar_Connected, iBit_Connected & ~(1 << iPlayer));
}
