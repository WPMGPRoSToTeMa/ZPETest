/* AMX Mod X
*	[ZPE] Effects Lighting.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	https://git.ckcorp.ru/ck/amxx-modes/zpe - development.
*
*	Support is provided only on the site.
*/

#define PLUGIN "effects lighting"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#define ZPE_SETTINGS_FILE "ZPE/zpe_settings.ini"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <engine>

#define LIGHTS_MAX_LENGTH 32
#define SKYNAME_MAX_LENGTH 32

#define TASK_THUNDER 100
#define TASK_THUNDER_LIGHTS 200

new Array:g_aSky_Names;
new Array:g_aThunder_Lights;
new Array:g_aSound_Thunder;

new g_Sky_Custom_Enable = 1;

new g_Thunder_Light_Index;
new g_Thunder_Light_Max_Len;
new g_Thunder_Light[32];

new g_pCvar_Lighting;
new g_pCvar_Thunder_Time;
new g_pCvar_Triggered_Lights;

new g_Sky_Index;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Lighting = register_cvar("zpe_lighting", "d");
	g_pCvar_Thunder_Time = register_cvar("zpe_thunder_time", "0");
	g_pCvar_Triggered_Lights = register_cvar("zpe_triggered_lights", "1");

	register_event("HLTV", "Event_Round_Start", "a", "1=0", "2=0");

	// Set a random skybox?
	if (g_Sky_Custom_Enable)
	{
		new szSky_Name[SKYNAME_MAX_LENGTH];
		ArrayGetString(g_aSky_Names, g_Sky_Index, szSky_Name, charsmax(szSky_Name));
		set_cvar_string("sv_skyname", szSky_Name);
	}
}

public plugin_precache()
{
	g_aSky_Names = ArrayCreate(SKYNAME_MAX_LENGTH, 1);
	g_aThunder_Lights = ArrayCreate(LIGHTS_MAX_LENGTH, 1);
	g_aSound_Thunder = ArrayCreate(SOUND_MAX_LENGTH, 1);

	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Custom Skies", "SKY NAMES", g_aSky_Names);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Lightning Lights Cycle", "LIGHTS", g_aThunder_Lights);
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "THUNDER", g_aSound_Thunder);

	// Choose random sky and precache sky files
	if (g_Sky_Custom_Enable)
	{
		g_Sky_Index = RANDOM(ArraySize(g_aSky_Names));

		new szSky_Name[SKYNAME_MAX_LENGTH];
		ArrayGetString(g_aSky_Names, g_Sky_Index, szSky_Name, charsmax(szSky_Name));

		new szPath[128];

		formatex(szPath, charsmax(szPath), "gfx/env/%sbk.tga", szSky_Name);
		precache_generic(szPath);

		formatex(szPath, charsmax(szPath), "gfx/env/%sdn.tga", szSky_Name);
		precache_generic(szPath);

		formatex(szPath, charsmax(szPath), "gfx/env/%sft.tga", szSky_Name);
		precache_generic(szPath);

		formatex(szPath, charsmax(szPath), "gfx/env/%slf.tga", szSky_Name);
		precache_generic(szPath);

		formatex(szPath, charsmax(szPath), "gfx/env/%srt.tga", szSky_Name);
		precache_generic(szPath);

		formatex(szPath, charsmax(szPath), "gfx/env/%sup.tga", szSky_Name);
		precache_generic(szPath);
	}

	Precache_Sounds(g_aSound_Thunder);
}

public plugin_cfg()
{
	// Get lighting style
	new szLighting[2];

	get_pcvar_string(g_pCvar_Lighting, szLighting, charsmax(szLighting));

	set_lights(szLighting);

	// Lighting task
	set_task(1.0, "Lighting_Task", _, _, _, "b");

	// Call roundstart manually
	Event_Round_Start();
}

// Event round start
public Event_Round_Start()
{
	// Remove lights?
	if (!get_pcvar_num(g_pCvar_Triggered_Lights))
	{
		set_task(0.1, "Remove_Lights");
	}
}

// Remove stuff task
public Remove_Lights()
{
	new iEntity;

	// Triggered lights
	iEntity = -1;

	while ((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "light")) != 0)
	{
		dllfunc(DLLFunc_Use, iEntity, 0); // Turn off the light

		set_entvar(iEntity, var_targetname, 0); // Prevent it from being triggered
	}
}

// Lighting task
public Lighting_Task()
{
	// Set thunder task if enabled and not already in place
	if (get_pcvar_float(g_pCvar_Thunder_Time) > 0.0 && !task_exists(TASK_THUNDER) && !task_exists(TASK_THUNDER_LIGHTS))
	{
		g_Thunder_Light_Index = 0;

		ArrayGetString(g_aThunder_Lights, RANDOM(ArraySize(g_aThunder_Lights)), g_Thunder_Light, charsmax(g_Thunder_Light));

		g_Thunder_Light_Max_Len = strlen(g_Thunder_Light);

		set_task(get_pcvar_float(g_pCvar_Thunder_Time), "Thunder_Task", TASK_THUNDER);
	}
}

// Thunder task
public Thunder_Task()
{
	// Lighting cycle starting?
	if (g_Thunder_Light_Index == 0)
	{
		// Play thunder sound
		new szSound[SOUND_MAX_LENGTH];
		ArrayGetString(g_aSound_Thunder, RANDOM(ArraySize(g_aSound_Thunder)), szSound, charsmax(szSound));
		Play_Sound_To_Clients(szSound);

		// Set thunder lights task
		set_task(0.1, "Thunder_Task", TASK_THUNDER_LIGHTS, _, _, "b");
	}

	// Apply current thunder light index
	new iLighting[2];

	iLighting[0] = g_Thunder_Light[g_Thunder_Light_Index];

	set_lights(iLighting);

	// Increase thunder light index
	g_Thunder_Light_Index++;

	// Lighting cycle end?
	if (g_Thunder_Light_Index >= g_Thunder_Light_Max_Len)
	{
		remove_task(TASK_THUNDER_LIGHTS);

		Lighting_Task();
	}
}

// Plays a sound on clients
Play_Sound_To_Clients(const szSound[])
{
	if (equal(szSound[strlen(szSound) - 4], ".mp3"))
	{
		client_cmd(0, "mp3 play ^"sound/%s^"", szSound);
	}

	else
	{
		client_cmd(0, "spk ^"%s^"", szSound);
	}
}