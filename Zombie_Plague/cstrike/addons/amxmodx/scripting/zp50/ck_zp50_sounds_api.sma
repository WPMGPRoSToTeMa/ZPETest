/* AMX Mod X
*	[ZPE] Sounds for zombie and human.
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

#define PLUGIN "sounds for zombie/human api"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

//	[RU] Текущее количество классов зомби. [ целое число ]
//	[EN] Current number of classes zombies. [ integer ]
#define MAX_ZOMBIE_CLASSES 6


// [RU] Текущее количество классов людей. [ целое число ]
// [EN] Current number of classes humans. [ integer ]
#define MAX_HUMAN_CLASSES 2


	//	[RU] Периодичность воспроизведения звука горения. [ время указывается в секундах ]
	//	[EN] Periodicity of reproduction of sound burning. [ the time is in seconds ]
	#define TIME_FLAME 3.0


	//	[RU] Минимальное время на воспроизведения звука idle. [ время указывается в секундах ]
	//	[EN] Minimum time to play sound idle. [ the time is in seconds ]
	#define TIME_IDLE_MIN_ZOMBIE 50.0


	//	[RU] Максимальное время на воспроизведения звука idle. [ время указывается в секундах ]
	//	[EN] Maximum time to play sound idle. [ the time is in seconds ]
	#define TIME_IDLE_MAX_ZOMBIE 70.0
	
	
	//	[RU] Минимальное время на воспроизведения звука idle. [ время указывается в секундах ]
	//	[EN] Minimum time to play sound idle. [ the time is in seconds ]
	#define TIME_IDLE_MIN_HUMAN 50.0


	//	[RU] Максимальное время на воспроизведения звука idle. [ время указывается в секундах ]
	//	[EN] Maximum time to play sound idle. [ the time is in seconds ]
	#define TIME_IDLE_MAX_HUMAN 70.0

#include <amxmodx>
#include <cs_util>
#include <fakemeta>
#include <ck_zp50_kernel>
#include <ck_zp50_class_human>
#include <ck_zp50_class_zombie>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_assassin>
#include <ck_zp50_class_survivor>
#include <ck_zp50_class_sniper>
#include <ck_zp50_grenade_fire>
#include <ck_zp50_sounds_api>

#define TASK_IDLE_SOUNDS 100
#define TASK_FLAME_SOUNDS 1212

#define ID_IDLE_SOUNDS (iTask_ID - TASK_IDLE_SOUNDS)
#define ID_FLAME_SOUNDS (iTask_ID - TASK_FLAME_SOUNDS)

new Array:g_aZombie_Sounds[MAX_ZOMBIE_CLASSES][ZOMBIE_SOUNDS];
new Array:g_aHuman_Sounds[MAX_HUMAN_CLASSES][HUMAN_SOUNDS];

new g_pCvar_Max_Zombie_Classes;
new g_pCvar_Max_Human_Classes;

new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Max_Zombie_Classes = register_cvar("zpe_max_zombie_classes", "6");
	g_pCvar_Max_Human_Classes = register_cvar("zpe_max_human_classes", "1");

	register_forward(FM_EmitSound, "FM_EmitSound_Zombie_");
	register_forward(FM_EmitSound, "FM_EmitSound_Human_");
}

public plugin_natives()
{
	register_native("zp_class_zombie_register_sound", "_zm_sound_zombie_register");
	register_native("zp_class_human_register_sound", "_zm_human_sound_register");
}

public FM_EmitSound_Zombie_(iPlayer, iChannel, szSample[], Float:fVolume, Float:fAttn, iFlags, iPitch)
{
	if (iPlayer > 32 || BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		return FMRES_IGNORED;
	}

	if (zp_class_nemesis_get(iPlayer) || zp_class_assassin_get(iPlayer) || !zp_core_is_zombie(iPlayer))
	{
		return FMRES_IGNORED;
	}

	static iClass_Zombie;

	iClass_Zombie = zp_class_zombie_get_current(iPlayer);

	static szSound[128];

	if (szSample[7] == 'b' && szSample[8] == 'h' && szSample[9] == 'i' && szSample[10] == 't')
	{
		if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_PAIN, szSound, charsmax(szSound)))
		{
			emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
		}

		return FMRES_SUPERCEDE;
	}

	if (szSample[7] == 'd' && ((szSample[8] == 'i' && szSample[9] == 'e') || (szSample[8] == 'e' && szSample[9] == 'a')))
	{
		if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_DIE, szSound, charsmax(szSound)))
		{
			emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
		}

		return FMRES_SUPERCEDE;
	}

	if (szSample[10] == 'f' && szSample[11] == 'a' && szSample[12] == 'l' && szSample[13] == 'l')
	{
		if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_FALL, szSound, charsmax(szSound)))
		{
			emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
		}

		return FMRES_SUPERCEDE;
	}

	if (szSample[8] == 'k' && szSample[9] == 'n' && szSample[10] == 'i')
	{
		if (szSample[14] == 's' && szSample[15] == 'l' && szSample[16] == 'a')
		{
			if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_MISS_SLASH, szSound, charsmax(szSound)))
			{
				emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
			}

			return FMRES_SUPERCEDE;
		}

		if (szSample[14] == 'h' && szSample[15] == 'i' && szSample[16] == 't')
		{
			if (szSample[17] == 'w')
			{
				if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_MISS_WALL, szSound, charsmax(szSound)))
				{
					emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
				}

				return FMRES_SUPERCEDE;
			}

			else
			{
				if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_HIT_NORMAL, szSound, charsmax(szSound)))
				{
					emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
				}

				return FMRES_SUPERCEDE;
			}
		}

		if (szSample[14] == 's' && szSample[15] == 't' && szSample[16] == 'a')
		{
			if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_HIT_STAB, szSound, charsmax(szSound)))
			{
				emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
			}

			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

public FM_EmitSound_Human_(iPlayer, iChannel, szSample[], Float:fVolume, Float:fAttn, iFlags, iPitch)
{
	if (iPlayer > 32 || BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		return FMRES_IGNORED;
	}

	if (zp_class_survivor_get(iPlayer) || zp_class_sniper_get(iPlayer) || zp_core_is_zombie(iPlayer))
	{
		return FMRES_IGNORED;
	}

	static iClass_Human;

	iClass_Human = zp_class_human_get_current(iPlayer);

	static szSound[128];

	if (szSample[7] == 'b' && szSample[8] == 'h' && szSample[9] == 'i' && szSample[10] == 't')
	{
		if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_PAIN, szSound, charsmax(szSound)))
		{
			emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
		}

		return FMRES_SUPERCEDE;
	}

	if (szSample[7] == 'd' && ((szSample[8] == 'i' && szSample[9] == 'e') || (szSample[8] == 'e' && szSample[9] == 'a')))
	{
		if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_DIE, szSound, charsmax(szSound)))
		{
			emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
		}

		return FMRES_SUPERCEDE;
	}

	if (szSample[10] == 'f' && szSample[11] == 'a' && szSample[12] == 'l' && szSample[13] == 'l')
	{
		if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_FALL, szSound, charsmax(szSound)))
		{
			emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
		}

		return FMRES_SUPERCEDE;
	}

	if (szSample[8] == 'k' && szSample[9] == 'n' && szSample[10] == 'i')
	{
		if (szSample[14] == 's' && szSample[15] == 'l' && szSample[16] == 'a')
		{
			if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_MISS_SLASH, szSound, charsmax(szSound)))
			{
				emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
			}

			return FMRES_SUPERCEDE;
		}

		if (szSample[14] == 'h' && szSample[15] == 'i' && szSample[16] == 't')
		{
			if (szSample[17] == 'w')
			{
				if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_MISS_WALL, szSound, charsmax(szSound)))
				{
					emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
				}

				return FMRES_SUPERCEDE;
			}

			else
			{
				if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_HIT_NORMAL, szSound, charsmax(szSound)))
				{
					emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
				}

				return FMRES_SUPERCEDE;
			}
		}

		if (szSample[14] == 's' && szSample[15] == 't' && szSample[16] == 'a')
		{
			if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_HIT_STAB, szSound, charsmax(szSound)))
			{
				emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
			}

			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

public zp_fw_core_infect_post(iPlayer)
{
	Remove_Tasks(iPlayer);

	if (zp_class_nemesis_get(iPlayer) && zp_class_assassin_get(iPlayer))
	{
		return;
	}

	new szSound[128];

	if (Get_Random_Zombie_Sounds(zp_class_zombie_get_current(iPlayer), ZOMBIE_SOUND_IDLE, szSound, charsmax(szSound)))
	{
		set_task(random_float(TIME_IDLE_MIN_ZOMBIE, TIME_IDLE_MAX_ZOMBIE), "Idle_Zombie_Sounds", iPlayer + TASK_IDLE_SOUNDS, _, _, "b");
	}

	if (Get_Random_Zombie_Sounds(zp_class_zombie_get_current(iPlayer), ZOMBIE_SOUND_INFECT, szSound, charsmax(szSound)))
	{
		emit_sound(iPlayer, CHAN_VOICE, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
}

public Idle_Zombie_Sounds(iTask_ID)
{
	new szSound[128];

	Get_Random_Zombie_Sounds(zp_class_zombie_get_current(ID_IDLE_SOUNDS), ZOMBIE_SOUND_IDLE, szSound, charsmax(szSound));

	emit_sound(ID_IDLE_SOUNDS, CHAN_VOICE, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public zp_fw_core_cure_post(iPlayer)
{
	Remove_Tasks(iPlayer);

	if (zp_class_survivor_get(iPlayer) && zp_class_sniper_get(iPlayer))
	{
		return;
	}
	
	new szSound[128];

	if (Get_Random_Human_Sounds(zp_class_human_get_current(iPlayer), HUMAN_SOUND_IDLE, szSound, charsmax(szSound)))
	{
		set_task(random_float(TIME_IDLE_MIN_HUMAN, TIME_IDLE_MAX_HUMAN), "Idle_Human_Sounds", iPlayer + TASK_IDLE_SOUNDS, _, _, "b");
	}
}

public Idle_Human_Sounds(iTask_ID)
{
	new szSound[128];

	Get_Random_Human_Sounds(zp_class_human_get_current(ID_IDLE_SOUNDS), HUMAN_SOUND_IDLE, szSound, charsmax(szSound));

	emit_sound(ID_IDLE_SOUNDS, CHAN_VOICE, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public zp_fw_grenade_fire_pre(iPlayer)
{
	if (zp_class_nemesis_get(iPlayer) && zp_class_assassin_get(iPlayer))
	{
		return;
	}

	new szSound[128];

	if (Get_Random_Zombie_Sounds(zp_class_zombie_get_current(iPlayer), ZOMBIE_SOUND_FLAME, szSound, charsmax(szSound)))
	{
		set_task(TIME_FLAME, "Flame_Sounds", iPlayer + TASK_FLAME_SOUNDS, _, _, "b");

		emit_sound(iPlayer, CHAN_VOICE, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
}

public Flame_Sounds(iTask_ID)
{
	if (zp_grenade_fire_get(ID_FLAME_SOUNDS))
	{
		new szSound[128];

		Get_Random_Zombie_Sounds(zp_class_zombie_get_current(ID_FLAME_SOUNDS), ZOMBIE_SOUND_FLAME, szSound, charsmax(szSound));

		emit_sound(ID_FLAME_SOUNDS, CHAN_VOICE, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}

	else
	{
		remove_task(iTask_ID);
	}
}

public _zm_sound_zombie_register()
{
	new iClass = get_param(1);

	if (iClass < 0 || iClass >= MAX_ZOMBIE_CLASSES)
	{
		log_error(AMX_ERR_NATIVE, "[ZPE] Class Zombie out of range", iClass);
	}

	new ZOMBIE_SOUNDS:iType = ZOMBIE_SOUNDS:get_param(2);

	if (iType < ZOMBIE_SOUND_PAIN || iType > ZOMBIE_SOUND_FLAME)
	{
		log_error(AMX_ERR_NATIVE, "[ZPE] Zombie Class out of range", iType);
	}

	if (g_aZombie_Sounds[iClass][iType] == Invalid_Array)
	{
		g_aZombie_Sounds[iClass][iType] = ArrayCreate(128);
	}

	new szSound[128];

	get_string(3, szSound, charsmax(szSound));

	ArrayPushString(g_aZombie_Sounds[iClass][iType], szSound);

	precache_sound(szSound);
}

public _zm_human_sound_register()
{
	new iClass = get_param(1);

	if (iClass < 0 || iClass >= MAX_HUMAN_CLASSES)
	{
		log_error(AMX_ERR_NATIVE, "[ZPE] Human Class out of range", iClass);
	}

	new HUMAN_SOUNDS:iType = HUMAN_SOUNDS:get_param(2);

	if (iType < HUMAN_SOUND_PAIN || iType > HUMAN_SOUND_IDLE)
	{
		log_error(AMX_ERR_NATIVE, "[ZPE] Human Class out of range", iType);
	}

	if (g_aHuman_Sounds[iClass][iType] == Invalid_Array)
	{
		g_aHuman_Sounds[iClass][iType] = ArrayCreate(128);
	}

	new szSound[128];

	get_string(3, szSound, charsmax(szSound));

	ArrayPushString(g_aHuman_Sounds[iClass][iType], szSound);

	precache_sound(szSound);
}

bool:Get_Random_Zombie_Sounds(iClass, ZOMBIE_SOUNDS:iType, szSound[], iSize)
{
	if (g_aZombie_Sounds[iClass][iType] != Invalid_Array)
	{
		ArrayGetString(g_aZombie_Sounds[iClass][iType], random(ArraySize(g_aZombie_Sounds[iClass][iType])), szSound, iSize);

		return true;
	}

	return false;
}

bool:Get_Random_Human_Sounds(iClass, HUMAN_SOUNDS:iType, szSound[], iSize)
{
	if (g_aHuman_Sounds[iClass][iType] != Invalid_Array)
	{
		ArrayGetString(g_aHuman_Sounds[iClass][iType], random(ArraySize(g_aHuman_Sounds[iClass][iType])), szSound, iSize);

		return true;
	}

	return false;
}

Remove_Tasks(iPlayer)
{
	remove_task(iPlayer + TASK_IDLE_SOUNDS);
	remove_task(iPlayer + TASK_FLAME_SOUNDS);
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	Remove_Tasks(iPlayer);

	BIT_SUB(g_iBit_Connected, iPlayer);
}