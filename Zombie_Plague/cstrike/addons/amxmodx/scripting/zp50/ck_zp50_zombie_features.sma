/* AMX Mod X
*	[ZP] Zombie Features.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "zombie features"
#define VERSION "5.2.6.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_settings.ini"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_zp50_kernel>

#define LIBRARY_NEMESIS "ck_zp50_class_nemesis"
#include <ck_zp50_class_nemesis>

#define LIBRARY_ASSASSIN "ck_zp50_class_assassin"
#include <ck_zp50_class_assassin>

new const g_Bleeding_Decals[] =
{
	99,
	107,
	108,
	184,
	185,
	186,
	187,
	188,
	189
};

#define TASK_BLOOD 100
#define ID_BLOOD (iTask_ID - TASK_BLOOD)

#define CS_DEFAULT_FOV 90

new Array:g_aBleeding_Decals;

new g_Message_Set_Fov;

new g_Is_Mod_CZ;

new g_pCvar_Zombie_Fov;
new g_pCvar_Zombie_Silent;
new g_pCvar_Zombie_Bleeding;

new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Zombie_Fov = register_cvar("zm_zombie_fov", "110");
	g_pCvar_Zombie_Silent = register_cvar("zm_zombie_silent", "1");
	g_pCvar_Zombie_Bleeding = register_cvar("zm_zombie_bleeding", "1");

	g_Message_Set_Fov = get_user_msgid("SetFOV");

	register_message(g_Message_Set_Fov, "Message_Setfov");

	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_Post", 1);

	new szMy_Mod[6];

	get_modname(szMy_Mod, charsmax(szMy_Mod));

	if (equal(szMy_Mod, "czero"))
	{
		g_Is_Mod_CZ = 1;
	}
}

public plugin_precache()
{
	// Initialize arrays
	g_aBleeding_Decals = ArrayCreate(1, 1);

	// Load from external file
	amx_load_setting_int_arr(ZP_SETTINGS_FILE, "Zombie Decals", "DECALS", g_aBleeding_Decals);

	// If we couldn't load from file, use and save default ones
	if (ArraySize(g_aBleeding_Decals) == 0)
	{
		for (new i = 0; i < sizeof g_Bleeding_Decals; i++)
		{
			ArrayPushCell(g_aBleeding_Decals, g_Bleeding_Decals[i]);
		}

		// Save to external file
		amx_save_setting_int_arr(ZP_SETTINGS_FILE, "Zombie Decals", "DECALS", g_aBleeding_Decals);
	}
}

public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const szModule[])
{
	if (equal(szModule, LIBRARY_NEMESIS) || equal(szModule, LIBRARY_ASSASSIN))
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

public RG_CSGameRules_PlayerKilled_Post(iVictim)
{
	// Remove bleeding task
	remove_task(iVictim + TASK_BLOOD);
}

public Message_Setfov(iMessage_ID, iMessage_Dest, iMessage_Entity)
{
	if (BIT_NOT_VALID(g_iBit_Alive, iMessage_Entity) || !zp_core_is_zombie(iMessage_Entity) || get_msg_arg_int(1) != CS_DEFAULT_FOV)
	{
		return;
	}

	set_msg_arg_int(1, get_msg_argtype(1), get_pcvar_num(g_pCvar_Zombie_Fov));
}

public zp_fw_core_infect_post(iPlayer)
{
	// Set custom FOV?
	if (get_pcvar_num(g_pCvar_Zombie_Fov) != CS_DEFAULT_FOV && get_pcvar_num(g_pCvar_Zombie_Fov) != 0)
	{
		message_begin(MSG_ONE, g_Message_Set_Fov, _, iPlayer);
		write_byte(get_pcvar_num(g_pCvar_Zombie_Fov)); // angle
		message_end();
	}

	// Remove previous tasks
	remove_task(iPlayer + TASK_BLOOD);

	// Nemesis Class loaded?
	if (!LibraryExists(LIBRARY_NEMESIS, LibType_Library) || !zp_class_nemesis_get(iPlayer))
	{
		// Set silent footsteps?
		if (get_pcvar_num(g_pCvar_Zombie_Silent))
		{
			rg_set_user_footsteps(iPlayer, true);
		}

		// Zombie bleeding?
		if (get_pcvar_num(g_pCvar_Zombie_Bleeding))
		{
			set_task(0.7, "Zombie_Bleeding", iPlayer + TASK_BLOOD, _, _, "b");
		}
	}

	// Assassin Class loaded?
	else if (!LibraryExists(LIBRARY_ASSASSIN, LibType_Library) || !zp_class_assassin_get(iPlayer))
	{
		// Set silent footsteps?
		if (get_pcvar_num(g_pCvar_Zombie_Silent))
		{
			rg_set_user_footsteps(iPlayer, true);
		}

		// Zombie bleeding?
		if (get_pcvar_num(g_pCvar_Zombie_Bleeding))
		{
			set_task(0.7, "Zombie_Bleeding", iPlayer + TASK_BLOOD, _, _, "b");
		}
	}

	else
	{
		// Restore normal footsteps?
		rg_set_user_footsteps(iPlayer, false);
	}
}

public zp_fw_core_cure_post(iPlayer)
{
	// Restore FOV?
	if (get_pcvar_num(g_pCvar_Zombie_Fov) != CS_DEFAULT_FOV && get_pcvar_num(g_pCvar_Zombie_Fov) != 0)
	{
		message_begin(MSG_ONE, g_Message_Set_Fov, _, iPlayer);
		write_byte(CS_DEFAULT_FOV); // angle
		message_end();
	}

	// Restore normal footsteps?
	if (get_pcvar_num(g_pCvar_Zombie_Silent))
	{
		rg_set_user_footsteps(iPlayer, false);
	}

	// Remove bleeding task
	remove_task(iPlayer + TASK_BLOOD);
}

// Make zombies leave footsteps and bloodstains on the floor
public Zombie_Bleeding(iTask_ID)
{
	// Only bleed when moving on ground
	if (!(get_entvar(ID_BLOOD, var_flags) & FL_ONGROUND) || _fm_get_speed(ID_BLOOD) < 80)
	{
		return;
	}

	// Get user origin
	static Float:fOrigin[3];

	get_entvar(ID_BLOOD, var_origin, fOrigin);

	// If ducking set a little lower
	if (get_entvar(ID_BLOOD, var_bInDuck))
	{
		fOrigin[2] -= 18.0;
	}

	else
	{
		fOrigin[2] -= 36.0;
	}

	// Send the decal message
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_WORLDDECAL); // TE player
	engfunc(EngFunc_WriteCoord, fOrigin[0]); // x
	engfunc(EngFunc_WriteCoord, fOrigin[1]); // y
	engfunc(EngFunc_WriteCoord, fOrigin[2]); // z
	write_byte(g_Bleeding_Decals[random(sizeof g_Bleeding_Decals) + (g_Is_Mod_CZ * 12)]); // decal number (offsets +12 for CZ)
	message_end();
}

public client_disconnected(iPlayer)
{
	// Remove bleeding task
	remove_task(iPlayer + TASK_BLOOD);

	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}