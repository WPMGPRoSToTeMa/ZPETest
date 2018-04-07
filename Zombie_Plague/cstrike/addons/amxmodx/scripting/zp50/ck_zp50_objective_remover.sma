/* AMX Mod X
*	[ZP] Objective remover.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "objective remover"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <fakemeta>

new const g_Objective_Entitys[][] =
{
	"func_bomb_target",
	"info_bomb_target",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue"
};

#define CLASSNAME_MAX_LENGTH 32

new Array:g_aObjective_Entitys;

new g_unfwSpawn;
new g_unfwPrecache_Sound;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	unregister_forward(FM_Spawn, g_unfwSpawn);
	unregister_forward(FM_PrecacheSound, g_unfwPrecache_Sound);

	register_forward(FM_EmitSound, "FM_EmitSound_");

	register_message(get_user_msgid("Scenario"), "Message_Scenario");
	register_message(get_user_msgid("HostagePos"), "Message_Hostagepos");
}

public plugin_precache()
{
	// Initialize arrays
	g_aObjective_Entitys = ArrayCreate(CLASSNAME_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Objective Entities", "OBJECTIVES", g_aObjective_Entitys);

	// If we couldn't load from file, use and save default ones
	if (ArraySize(g_aObjective_Entitys) == 0)
	{
		for (new i = 0; i < sizeof g_Objective_Entitys; i++)
		{
			ArrayPushString(g_aObjective_Entitys, g_Objective_Entitys[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Objective Entities", "OBJECTIVES", g_aObjective_Entitys);
	}

	// Fake Hostage (to force round ending)
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"));

	if (is_entity(iEntity))
	{
		engfunc(EngFunc_SetOrigin, iEntity, Float:{ 8192.0, 8192.0, 8192.0 });

		dllfunc(DLLFunc_Spawn, iEntity);
	}

	// Prevent objective entities from spawning
	g_unfwSpawn = register_forward(FM_Spawn, "FM_Spawn_");

	// Prevent hostage sounds from being precached
	g_unfwPrecache_Sound = register_forward(FM_PrecacheSound, "FM_PrecacheSound_");
}

// Entity Spawn Forward
public FM_Spawn_(iEntity)
{
	// Invalid entity
	if (!is_entity(iEntity))
	{
		return FMRES_IGNORED;
	}

	// Get сlassname
	new szClassname[32];

	get_entvar(iEntity, var_classname, szClassname, charsmax(szClassname));

	// Check whether it needs to be removed
	for (new i = 0; i < sizeof g_Objective_Entitys; i++)
	{
		if (equal(szClassname, g_Objective_Entitys[i]))
		{
			engfunc(EngFunc_RemoveEntity, iEntity);

			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

// Sound Precache Forward
public FM_PrecacheSound_(const szSound[])
{
	// Block all those unneeeded hostage sounds
	if (equal(szSound, "hostage", 7))
	{
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

// Emit Sound Forward
public FM_EmitSound_(iPlayer, iChannel, const szSample[])
{
	// Block all those unneeeded hostage sounds
	if (szSample[0] == 'h' && szSample[1] == 'o' && szSample[2] == 's' && szSample[3] == 't' && szSample[4] == 'a' && szSample[5] == 'g' && szSample[6] == 'e')
	{
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

// Block hostage HUD display
public Message_Scenario()
{
	if (get_msg_args() > 1)
	{
		new szSprite[8];

		get_msg_arg_string(2, szSprite, charsmax(szSprite));

		if (equal(szSprite, "hostage"))
		{
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}

// Block hostages from appearing on radar
public Message_Hostagepos()
{
	return PLUGIN_HANDLED;
}