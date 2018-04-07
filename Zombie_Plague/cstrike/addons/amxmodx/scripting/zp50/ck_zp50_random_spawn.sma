/* AMX Mod X
*	[ZP] Random Spawn.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "random spawn"
#define VERSION "5.2.5.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <amxmisc>
#include <cs_util>
#include <fakemeta>
#include <ck_zp50_kernel>

#define SPAWN_DATA_ORIGIN_X 0
#define SPAWN_DATA_ORIGIN_Y 1
#define SPAWN_DATA_ORIGIN_Z 2
#define SPAWN_DATA_ANGLES_X 3
#define SPAWN_DATA_ANGLES_Y 4
#define SPAWN_DATA_ANGLES_Z 5
#define SPAWN_DATA_V_ANGLES_X 6
#define SPAWN_DATA_V_ANGLES_Y 7
#define SPAWN_DATA_V_ANGLES_Z 8

new Float:g_fSpawns_CSDM[128][SPAWN_DATA_V_ANGLES_Z + 1];
new Float:g_fSpawns_Regular[128][SPAWN_DATA_V_ANGLES_Z + 1];

new g_Spawn_Count_CSDM;
new g_Spawn_Count_Regular;

new g_pCvar_Random_Spawning;

new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Random_Spawning = register_cvar("zm_random_spawning_csdm", "1"); // 1-use CSDM spawns // 0-use regular spawns

	// Collect random spawn points
	Load_Spawns();
}

public plugin_natives()
{
	register_library("ck_zp50_random_spawn");

	register_native("zp_random_spawn_do", "native_random_spawn_do");
}

public native_random_spawn_do(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	new iCSDM_Spawns = get_param(2);

	Do_Random_Spawn(iPlayer, iCSDM_Spawns);

	return true;
}

// ZP Player Spawn Post Forward
public zp_fw_core_spawn_post(iPlayer)
{
	Do_Random_Spawn(iPlayer, get_pcvar_num(g_pCvar_Random_Spawning));
}

// Place user at a random spawn
Do_Random_Spawn(iPlayer, iCSDM_Spawns = true)
{
	new iHull;
	new iSpawn_Index;
	new iCurrent_Index;

	// Get whether the player is crouching
	iHull = (get_entvar(iPlayer, var_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN;

	// Use CSDM spawns?
	if (iCSDM_Spawns && g_Spawn_Count_CSDM)
	{
		// Choose random spawn to start looping at
		iSpawn_Index = random(g_Spawn_Count_CSDM);

		// Try to find a clear spawn
		for (iCurrent_Index = iSpawn_Index + 1; /*no condition*/; iCurrent_Index++)
		{
			// Start over when we reach the end
			if (iCurrent_Index >= g_Spawn_Count_CSDM)
			{
				iCurrent_Index = 0;
			}

			// Fetch spawn data: origin
			static Float:fSpawndata[3];

			fSpawndata[0] = g_fSpawns_CSDM[iCurrent_Index][SPAWN_DATA_ORIGIN_X];
			fSpawndata[1] = g_fSpawns_CSDM[iCurrent_Index][SPAWN_DATA_ORIGIN_Y];
			fSpawndata[2] = g_fSpawns_CSDM[iCurrent_Index][SPAWN_DATA_ORIGIN_Z];

			// Free spawn space?
			if (Is_Hull_Vacant(fSpawndata, iHull))
			{
				// Engfunc_SetOrigin is used so entity's mins and maxs get updated instantly
				engfunc(EngFunc_SetOrigin, iPlayer, fSpawndata);

				// Fetch spawn data: angles
				fSpawndata[0] = g_fSpawns_CSDM[iCurrent_Index][SPAWN_DATA_ANGLES_X];
				fSpawndata[1] = g_fSpawns_CSDM[iCurrent_Index][SPAWN_DATA_ANGLES_Y];
				fSpawndata[2] = g_fSpawns_CSDM[iCurrent_Index][SPAWN_DATA_ANGLES_Z];

				set_entvar(iPlayer, var_angles, fSpawndata);

				// Fetch spawn data: view angles
				fSpawndata[0] = g_fSpawns_CSDM[iCurrent_Index][SPAWN_DATA_V_ANGLES_X];
				fSpawndata[1] = g_fSpawns_CSDM[iCurrent_Index][SPAWN_DATA_V_ANGLES_Y];
				fSpawndata[2] = g_fSpawns_CSDM[iCurrent_Index][SPAWN_DATA_V_ANGLES_Z];

				set_entvar(iPlayer, var_v_angle, fSpawndata);

				break;
			}

			// Loop completed, no free space found
			if (iCurrent_Index == iSpawn_Index)
			{
				break;
			}
		}
	}

	else if (g_Spawn_Count_Regular)
	{
		// Choose random spawn to start looping at
		iSpawn_Index = random_num(0, g_Spawn_Count_Regular - 1);

		// Try to find a clear spawn
		for (iCurrent_Index = iSpawn_Index + 1; /*no condition*/; iCurrent_Index++)
		{
			// Start over when we reach the end
			if (iCurrent_Index >= g_Spawn_Count_Regular)
			{
				iCurrent_Index = 0;
			}

			// Fetch spawn data: origin
			static Float:fSpawndata[3];

			fSpawndata[0] = g_fSpawns_Regular[iCurrent_Index][SPAWN_DATA_ORIGIN_X];
			fSpawndata[1] = g_fSpawns_Regular[iCurrent_Index][SPAWN_DATA_ORIGIN_Y];
			fSpawndata[2] = g_fSpawns_Regular[iCurrent_Index][SPAWN_DATA_ORIGIN_Z];

			// Free spawn space?
			if (Is_Hull_Vacant(fSpawndata, iHull))
			{
				// Engfunc_SetOrigin is used so entity's mins and maxs get updated instantly
				engfunc(EngFunc_SetOrigin, iPlayer, fSpawndata);

				// Fetch spawn data: angles
				fSpawndata[0] = g_fSpawns_Regular[iCurrent_Index][SPAWN_DATA_ANGLES_X];
				fSpawndata[1] = g_fSpawns_Regular[iCurrent_Index][SPAWN_DATA_ANGLES_Y];
				fSpawndata[2] = g_fSpawns_Regular[iCurrent_Index][SPAWN_DATA_ANGLES_Z];

				set_entvar(iPlayer, var_angles, fSpawndata);

				// Fetch spawn data: view angles
				fSpawndata[0] = g_fSpawns_Regular[iCurrent_Index][SPAWN_DATA_V_ANGLES_X];
				fSpawndata[1] = g_fSpawns_Regular[iCurrent_Index][SPAWN_DATA_V_ANGLES_Y];
				fSpawndata[2] = g_fSpawns_Regular[iCurrent_Index][SPAWN_DATA_V_ANGLES_Z];

				set_entvar(iPlayer, var_v_angle, fSpawndata);

				break;
			}

			// Loop completed, no free space found
			if (iCurrent_Index == iSpawn_Index)
			{
				break;
			}
		}
	}
}

// Collect spawn points from entity origins
stock Collect_Spawns_Entity(const szClassname[])
{
	new Float:fData[3];

	new iEntity = -1;

	while ((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", szClassname)) != 0)
	{
		// Get origin
		get_entvar(iEntity, var_origin, fData);

		g_fSpawns_Regular[g_Spawn_Count_Regular][SPAWN_DATA_ORIGIN_X] = fData[0];
		g_fSpawns_Regular[g_Spawn_Count_Regular][SPAWN_DATA_ORIGIN_Y] = fData[1];
		g_fSpawns_Regular[g_Spawn_Count_Regular][SPAWN_DATA_ORIGIN_Z] = fData[2];

		// Angles
		get_entvar(iEntity, var_angles, fData);

		g_fSpawns_Regular[g_Spawn_Count_Regular][SPAWN_DATA_ANGLES_X] = fData[0];
		g_fSpawns_Regular[g_Spawn_Count_Regular][SPAWN_DATA_ANGLES_Y] = fData[1];
		g_fSpawns_Regular[g_Spawn_Count_Regular][SPAWN_DATA_ANGLES_Z] = fData[2];

		// View angles
		get_entvar(iEntity, var_v_angle, fData);

		g_fSpawns_Regular[g_Spawn_Count_Regular][SPAWN_DATA_V_ANGLES_X] = fData[0];
		g_fSpawns_Regular[g_Spawn_Count_Regular][SPAWN_DATA_V_ANGLES_Y] = fData[1];
		g_fSpawns_Regular[g_Spawn_Count_Regular][SPAWN_DATA_V_ANGLES_Z] = fData[2];

		// Increase spawn count
		g_Spawn_Count_Regular++;

		if (g_Spawn_Count_Regular >= sizeof g_fSpawns_Regular)
		{
			break;
		}
	}
}

// Collect random spawn points
stock Load_Spawns()
{
	// Check for CSDM spawns of the current map
	new szConfig_Directory[32];
	new szMapname[32];
	new szFilepath[100];
	new szLinedata[64];

	get_configsdir(szConfig_Directory, charsmax(szConfig_Directory));
	get_mapname(szMapname, charsmax(szMapname));

	formatex(szFilepath, charsmax(szFilepath), "%s/csdm/%s.spawns.cfg", szConfig_Directory, szMapname);

	// Load CSDM spawns if present
	if (file_exists(szFilepath))
	{
		new fCSDM_Data[10][6];

		new iFile = fopen(szFilepath, "rt");

		while (iFile && !feof(iFile))
		{
			fgets(iFile, szLinedata, charsmax(szLinedata));

			// Invalid spawn
			if (!szLinedata[0] || Str_Count(szLinedata, ' ') < 2)
			{
				continue;
			}

			// Get spawn point data
			parse(szLinedata, fCSDM_Data[0], 5, fCSDM_Data[1], 5, fCSDM_Data[2], 5, fCSDM_Data[3], 5, fCSDM_Data[4], 5, fCSDM_Data[5], 5, fCSDM_Data[6], 5, fCSDM_Data[7], 5, fCSDM_Data[8], 5, fCSDM_Data[9], 5);

			// Origin
			g_fSpawns_CSDM[g_Spawn_Count_CSDM][SPAWN_DATA_ORIGIN_X] = floatstr(fCSDM_Data[0]);
			g_fSpawns_CSDM[g_Spawn_Count_CSDM][SPAWN_DATA_ORIGIN_Y] = floatstr(fCSDM_Data[1]);
			g_fSpawns_CSDM[g_Spawn_Count_CSDM][SPAWN_DATA_ORIGIN_Z] = floatstr(fCSDM_Data[2]);

			// Angles
			g_fSpawns_CSDM[g_Spawn_Count_CSDM][SPAWN_DATA_ANGLES_X] = floatstr(fCSDM_Data[3]);
			g_fSpawns_CSDM[g_Spawn_Count_CSDM][SPAWN_DATA_ANGLES_Y] = floatstr(fCSDM_Data[4]);
			g_fSpawns_CSDM[g_Spawn_Count_CSDM][SPAWN_DATA_ANGLES_Z] = floatstr(fCSDM_Data[5]);

			// View angles
			g_fSpawns_CSDM[g_Spawn_Count_CSDM][SPAWN_DATA_V_ANGLES_X] = floatstr(fCSDM_Data[7]);
			g_fSpawns_CSDM[g_Spawn_Count_CSDM][SPAWN_DATA_V_ANGLES_Y] = floatstr(fCSDM_Data[8]);
			g_fSpawns_CSDM[g_Spawn_Count_CSDM][SPAWN_DATA_V_ANGLES_Z] = floatstr(fCSDM_Data[9]);

			// Increase spawn count
			g_Spawn_Count_CSDM++;

			if (g_Spawn_Count_CSDM >= sizeof g_fSpawns_CSDM)
			{
				break;
			}
		}

		if (iFile)
		{
			fclose(iFile);
		}
	}

	else
	{
		// Collect regular spawns
		Collect_Spawns_Entity("info_player_start");
		Collect_Spawns_Entity("info_player_deathmatch");
	}
}

public client_disconnected(iPlayer)
{
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