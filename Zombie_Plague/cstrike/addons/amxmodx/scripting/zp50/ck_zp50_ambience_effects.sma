/* AMX Mod X
*	[ZP] Ambience Effects.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "ambience effects"
#define VERSION "5.0.4.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <fakemeta>

#define FOG_VALUE_MAX_LENGTH 16

new const g_Ambience_Entity[][] =
{
	"env_fog",
	"env_rain",
	"env_snow"
};

new g_Amience_Rain = 0;
new g_Ambience_Snow = 0;
new g_Ambience_Fog = 1;
new g_Ambience_Fog_Density[FOG_VALUE_MAX_LENGTH] = "0.0018";
new g_Ambience_Fog_Color[FOG_VALUE_MAX_LENGTH] = "128 128 128";

new g_fwSpawn;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	unregister_forward(FM_Spawn, g_fwSpawn);
}

public plugin_precache()
{
	// Load from external file, save if not found
	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weather Effects", "FOG DENSITY", g_Ambience_Fog_Density, charsmax(g_Ambience_Fog_Density)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weather Effects", "FOG DENSITY", g_Ambience_Fog_Density);
	}

	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weather Effects", "FOG COLOR", g_Ambience_Fog_Color, charsmax(g_Ambience_Fog_Color)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weather Effects", "FOG COLOR", g_Ambience_Fog_Color);
	}

	if (!amx_load_setting_int(ZP_SETTINGS_FILE, "Weather Effects", "FOG", g_Ambience_Fog))
	{
		amx_save_setting_int(ZP_SETTINGS_FILE, "Weather Effects", "FOG", g_Ambience_Fog);
	}

	if (!amx_load_setting_int(ZP_SETTINGS_FILE, "Weather Effects", "SNOW", g_Ambience_Snow))
	{
		amx_save_setting_int(ZP_SETTINGS_FILE, "Weather Effects", "SNOW", g_Ambience_Snow);
	}

	if (!amx_load_setting_int(ZP_SETTINGS_FILE, "Weather Effects", "RAIN", g_Amience_Rain))
	{
		amx_save_setting_int(ZP_SETTINGS_FILE, "Weather Effects", "RAIN", g_Amience_Rain);
	}

	if (g_Ambience_Fog)
	{
		new iEntity = rg_create_entity("env_fog");

		if (is_entity(iEntity))
		{
			Fm_Set_Kvd(iEntity, "density", g_Ambience_Fog_Density, "env_fog");
			Fm_Set_Kvd(iEntity, "rendercolor", g_Ambience_Fog_Color, "env_fog");
		}
	}

	if (g_Amience_Rain)
	{
		rg_create_entity("env_rain");
	}

	if (g_Ambience_Snow)
	{
		rg_create_entity("env_snow");
	}

	g_fwSpawn = register_forward(FM_Spawn, "Forward_Spawn");
}

public Forward_Spawn(iEntity)
{
	if (!is_entity(iEntity))
	{
		return FMRES_IGNORED;
	}

	new szClassname[32];

	get_entvar(iEntity, var_classname, szClassname, charsmax(szClassname));

	for (new i = 0; i < sizeof g_Ambience_Entity; i++)
	{
		if (equal(szClassname, g_Ambience_Entity[i]))
		{
			engfunc(EngFunc_RemoveEntity, iEntity);

			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

stock Fm_Set_Kvd(iEntity, const iKey[], const iValue[], const szClassname[])
{
	set_kvd(0, KV_ClassName, szClassname);
	set_kvd(0, KV_KeyName, iKey);
	set_kvd(0, KV_Value, iValue);
	set_kvd(0, KV_fHandled, 0);

	dllfunc(DLLFunc_KeyValue, iEntity, 0);
}