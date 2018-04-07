/* AMX Mod X
*	[ZP] Serverbrowser info.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "serverbrowser info"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <fakemeta>
#include <ck_zp50_kernel>

new g_Mod_Name[64];

new g_pCvar_Mode_Name;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Mode_Name = register_cvar("zm_mode_name", "");

	register_forward(FM_GetGameDescription, "FM_GetGameDescription_");

	new szMode_Name[32];

	get_pcvar_string(g_pCvar_Mode_Name, szMode_Name, charsmax(szMode_Name));

	formatex(g_Mod_Name, charsmax(g_Mod_Name), szMode_Name);
}

// Forward Get Game Description
public FM_GetGameDescription_()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, g_Mod_Name);

	return FMRES_SUPERCEDE;
}