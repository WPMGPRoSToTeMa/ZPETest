/* AMX Mod X
*	[ZP] Sounds for zombie and human.
*	Author: C&K Corporation.
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*	http://wiki.ckcorp.ru/ - documentation and other useful information.
*
*	Support is provided only on the site.
*/

#define PLUGIN "sounds for zombie/human"
#define VERSION "8.5.12.0"
#define AUTHOR "C&K Corporation"

//	[RU] Текущее количество классов зомби. [ целое число ]
//	[EN] Current number of classes zombies. [ integer ]
#define MAX_ZOMBIE_CLASSES 6


//	[RU] Текущее количество классов людей. [ целое число ]
//	[EN] Current number of classes humans. [ integer ]
#define MAX_HUMAN_CLASSES 2


//	[RU] Поддержка глобальных модов.
//	[EN] Support for global modes.
//	[ 0 - Zombie Plague 4.3 // 1 - Zombie Plague 5.0.8 // 2 - Fork Zombie Plague 5.0.8 // 3 - Zombie Plague Advanced // 4 - Biohazard (cheap_suit) ]
#define GLOBAL_MODES 2

// [RU] Для Fork Zombie Plague 5.0.8 не актуально! У Fork Zombie Plague 5.0.8 настройки игровых режимов находятся в include/settings/zp50_const_gamemodes.inc.
// [EN] For Fork Zombie Plague 5.0.8 is not relevant! Fork Zombie Plague 5.0.8 settings of game modes are in include/settings/zp50_const_gamemodes.inc.
#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2

	//	[RU] Периодичность воспроизведения звука горения. [ время указывается в секундах ]
	//	[EN] Periodicity of reproduction of sound burning. [ the time is in seconds ]
	#define TIME_FLAME 3


	//	[RU] Минимальное время на воспроизведения звука idle. [ время указывается в секундах ]
	//	[EN] Minimum time to play sound idle. [ the time is in seconds ]
	#define TIME_IDLE_MIN 50


	//	[RU] Максимальное время на воспроизведения звука idle. [ время указывается в секундах ]
	//	[EN] Maximum time to play sound idle. [ the time is in seconds ]
	#define TIME_IDLE_MAX 70

#endif

#include <amxmodx>
#include <cs_util>
#include <fakemeta>

#if GLOBAL_MODES == 2 // Fork ZP 5.0.8

	#include <ck_zp50_kernel>
	#include <ck_zp50_class_human>
	#include <ck_zp50_class_zombie>

	#define LIBRARY_NEMESIS "ck_zp50_class_nemesis"
	#include <ck_zp50_class_nemesis>

	#define LIBRARY_ASSASSIN "ck_zp50_class_assassin"
	#include <ck_zp50_class_assassin>

	#define LIBRARY_SURVIVOR "ck_zp50_class_survivor"
	#include <ck_zp50_class_survivor>

	#define LIBRARY_SNIPER "ck_zp50_class_sniper"
	#include <ck_zp50_class_sniper>

	#define LIBRARY_GRENADE_FIRE "ck_zp50_grenade_fire"
	#include <ck_zp50_grenade_fire>

#endif

#if GLOBAL_MODES == 1 // ZP 5.0.8

	#include <zp50_core>
	#include <zp50_class_human>
	#include <zp50_class_zombie>

	#define LIBRARY_NEMESIS "zp50_class_nemesis"
	#include <zp50_class_nemesis>

	#define LIBRARY_ASSASSIN "zp50_class_assassin"
	#include <zp50_class_assassin>

	#define LIBRARY_SURVIVOR "zp50_class_survivor"
	#include <zp50_class_survivor>

	#define LIBRARY_SNIPER "zp50_class_sniper"
	#include <zp50_class_sniper>

	#define LIBRARY_GRENADE_FIRE "zp50_grenade_fire"
	#include <zp50_grenade_fire>

#endif

// ZP 4.3
#if GLOBAL_MODES == 0

	#include <zombieplague>

#endif

// ZPA
#if GLOBAL_MODES == 3

	#include <zombie_plague_advance>

#endif

// Biohazard
#if GLOBAL_MODES == 4

	#include <biohazard>

#endif

#include <zp_sounds_api>

#define TASK_IDLE_SOUNDS 100
#define TASK_FLAME_SOUNDS 1212

#define ID_IDLE_SOUNDS (iTask_ID - TASK_IDLE_SOUNDS)
#define ID_FLAME_SOUNDS (iTask_ID - TASK_FLAME_SOUNDS)

#if GLOBAL_MODES == 0 || GLOBAL_MODES == 3 // ZP 4.3 or ZPA

	#define is_user_zombie(%0) zp_get_user_zombie(%0)
	#define is_user_nemesis(%0) zp_get_user_nemesis(%0)
	#define is_user_assassin(%0) zp_get_user_assassin(%0)
	#define get_user_current_zombie_class(%0) zp_get_user_zombie_class(%0)

#elseif GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

	#define is_user_zombie(%0) zp_core_is_zombie(%0)
	#define is_user_nemesis(%0) zp_class_nemesis_get(%0)
	#define is_user_assassin(%0) zp_class_assassin_get(%0)
	#define get_user_current_zombie_class(%0) zp_class_zombie_get_current(%0)

#elseif GLOBAL_MODES == 4 // Biohazard

	#define get_user_current_zombie_class(%0) get_user_class(%0)

#endif

new Array:g_aZombie_Sounds[MAX_ZOMBIE_CLASSES][ZOMBIE_SOUNDS];

#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

	new Array:g_aHuman_Sounds[MAX_HUMAN_CLASSES][HUMAN_SOUNDS];

#endif

new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward(FM_EmitSound, "FM_EmitSound_Zombie_");

	#if GLOBAL_MODES != 2

		RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_Pre");

	#endif

	#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

		register_forward(FM_EmitSound, "FM_EmitSound_Human_");

	#endif
}

public plugin_natives()
{
	register_native("zp_class_zombie_register_sound", "_zm_sound_zombie_register");

	#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

		register_native("zp_class_human_register_sound", "_zm_human_sound_register");

	#endif

	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const szModule[])
{
	if (equal(szModule, LIBRARY_NEMESIS) || equal(szModule, LIBRARY_ASSASSIN) || equal(szModule, LIBRARY_SURVIVOR) || equal(szModule, LIBRARY_SNIPER) || equal(szModule, LIBRARY_GRENADE_FIRE))
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

public FM_EmitSound_Zombie_(iPlayer, iChannel, iSample[], Float:fVolume, Float:fAttn, iFlags, iPitch)
{
	if (iPlayer > 32 || BIT_NOT_VALID(g_iBit_Connected, iPlayer))
	{
		return FMRES_IGNORED;
	}

	#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

		if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
		{
			return FMRES_IGNORED;
		}

	#endif

	if (is_user_nemesis(iPlayer))
	{
		return FMRES_IGNORED;
	}

	#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

		if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
		{
			return FMRES_IGNORED;
		}

	#endif

	if (is_user_assassin(iPlayer))
	{
		return FMRES_IGNORED;
	}

	if (!is_user_zombie(iPlayer))
	{
		return FMRES_IGNORED;
	}

	static iClass_Zombie;

	iClass_Zombie = get_user_current_zombie_class(iPlayer);

	static szSound[128];

	if (iSample[7] == 'b' && iSample[8] == 'h' && iSample[9] == 'i' && iSample[10] == 't')
	{
		if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_PAIN, szSound, charsmax(szSound)))
		{
			emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
		}

		return FMRES_SUPERCEDE;
	}

	if (iSample[7] == 'd' && ((iSample[8] == 'i' && iSample[9] == 'e') || (iSample[8] == 'e' && iSample[9] == 'a')))
	{
		if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_DIE, szSound, charsmax(szSound)))
		{
			emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
		}

		return FMRES_SUPERCEDE;
	}

	if (iSample[10] == 'f' && iSample[11] == 'a' && iSample[12] == 'l' && iSample[13] == 'l')
	{
		if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_FALL, szSound, charsmax(szSound)))
		{
			emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
		}

		return FMRES_SUPERCEDE;
	}

	if (iSample[8] == 'k' && iSample[9] == 'n' && iSample[10] == 'i')
	{
		if (iSample[14] == 's' && iSample[15] == 'l' && iSample[16] == 'a')
		{
			if (Get_Random_Zombie_Sounds(iClass_Zombie, ZOMBIE_SOUND_MISS_SLASH, szSound, charsmax(szSound)))
			{
				emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
			}

			return FMRES_SUPERCEDE;
		}

		if (iSample[14] == 'h' && iSample[15] == 'i' && iSample[16] == 't')
		{
			if (iSample[17] == 'w')
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

		if (iSample[14] == 's' && iSample[15] == 't' && iSample[16] == 'a')
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

#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or ZP 5.0.8

	public FM_EmitSound_Human_(iPlayer, iChannel, iSample[], Float:fVolume, Float:fAttn, iFlags, iPitch)
	{
		if (iPlayer > 32 || BIT_NOT_VALID(g_iBit_Connected, iPlayer))
		{
			return FMRES_IGNORED;
		}

		#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8
			
			if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
			{
				return FMRES_IGNORED;
			}
		
		#endif
		
		if (zp_class_survivor_get(iPlayer))
		{
			return FMRES_IGNORED;
		}
		
		#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

			if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
			{
				return FMRES_IGNORED;
			}
		
		#endif
		
		if (zp_class_sniper_get(iPlayer))
		{
			return FMRES_IGNORED;
		}

		if (is_user_zombie(iPlayer))
		{
			return FMRES_IGNORED;
		}

		static iClass_Human;

		iClass_Human = zp_class_human_get_current(iPlayer);

		static szSound[128];

		if (iSample[7] == 'b' && iSample[8] == 'h' && iSample[9] == 'i' && iSample[10] == 't')
		{
			if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_PAIN, szSound, charsmax(szSound)))
			{
				emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
			}

			return FMRES_SUPERCEDE;
		}

		if (iSample[7] == 'd' && ((iSample[8] == 'i' && iSample[9] == 'e') || (iSample[8] == 'e' && iSample[9] == 'a')))
		{
			if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_DIE, szSound, charsmax(szSound)))
			{
				emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
			}

			return FMRES_SUPERCEDE;
		}

		if (iSample[10] == 'f' && iSample[11] == 'a' && iSample[12] == 'l' && iSample[13] == 'l')
		{
			if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_FALL, szSound, charsmax(szSound)))
			{
				emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
			}

			return FMRES_SUPERCEDE;
		}

		if (iSample[8] == 'k' && iSample[9] == 'n' && iSample[10] == 'i')
		{
			if (iSample[14] == 's' && iSample[15] == 'l' && iSample[16] == 'a')
			{
				if (Get_Random_Human_Sounds(iClass_Human, HUMAN_SOUND_MISS_SLASH, szSound, charsmax(szSound)))
				{
					emit_sound(iPlayer, iChannel, szSound, fVolume, fAttn, iFlags, iPitch);
				}

				return FMRES_SUPERCEDE;
			}

			if (iSample[14] == 'h' && iSample[15] == 'i' && iSample[16] == 't')
			{
				if (iSample[17] == 'w')
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

			if (iSample[14] == 's' && iSample[15] == 't' && iSample[16] == 'a')
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

#endif

#if GLOBAL_MODES == 0 || GLOBAL_MODES == 3 // ZP 4.3 or ZPA

	public zp_user_infected_post(iPlayer)

#elseif GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

	public zp_fw_core_infect_post(iPlayer)

#elseif GLOBAL_MODES == 3 // Biohazard

	public event_infect(iPlayer)

#endif

{
	Remove_Tasks(iPlayer);

	#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8
	
		if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
		{
			return;
		}
	
	#endif
	
	if (is_user_nemesis(iPlayer))
	{
		return;
	}

	#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

		if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
		{
			return;
		}
	
	#endif
	
	if (is_user_assassin(iPlayer))
	{
		return;
	}

	new szSound[128];

	if (Get_Random_Zombie_Sounds(get_user_current_zombie_class(iPlayer), ZOMBIE_SOUND_IDLE, szSound, charsmax(szSound)))
	{
		set_task(random_float(float(TIME_IDLE_MIN), float(TIME_IDLE_MAX)), "Idle_Zombie_Sounds", iPlayer + TASK_IDLE_SOUNDS, _, _, "b");
	}

	if (Get_Random_Zombie_Sounds(get_user_current_zombie_class(iPlayer), ZOMBIE_SOUND_INFECT, szSound, charsmax(szSound)))
	{
		emit_sound(iPlayer, CHAN_VOICE, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
}

public Idle_Zombie_Sounds(iTask_ID)
{
	new szSound[128];

	Get_Random_Zombie_Sounds(get_user_current_zombie_class(ID_IDLE_SOUNDS), ZOMBIE_SOUND_IDLE, szSound, charsmax(szSound));

	emit_sound(ID_IDLE_SOUNDS, CHAN_VOICE, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
}

#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

	public zp_fw_core_cure_post(iPlayer)
	{
		Remove_Tasks(iPlayer);

		#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8
		
			if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
			{
				return;
			}
		
		#endif
		
		if (zp_class_survivor_get(iPlayer))
		{
			return;
		}

		#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8
		
			if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
			{
				return;
			}
		
		#endif
		
		if (zp_class_sniper_get(iPlayer))
		{
			return;
		}

		new szSound[128];

		if (Get_Random_Human_Sounds(zp_class_human_get_current(iPlayer), HUMAN_SOUND_IDLE, szSound, charsmax(szSound)))
		{
			set_task(random_float(float(TIME_IDLE_MIN), float(TIME_IDLE_MAX)), "Idle_Human_Sounds", iPlayer + TASK_IDLE_SOUNDS, _, _, "b");
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
		#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8
		
			if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
			{
				return;
			}
		
		#endif
		
		if (is_user_nemesis(iPlayer))
		{
			return;
		}
		
		#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8
		
			if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
			{
				return;
			}
		
		#endif
		
		if (is_user_assassin(iPlayer))
		{
			return;
		}
		
		new szSound[128];

		if (Get_Random_Zombie_Sounds(get_user_current_zombie_class(iPlayer), ZOMBIE_SOUND_FLAME, szSound, charsmax(szSound)))
		{
			set_task(float(TIME_FLAME), "Flame_Sounds", iPlayer + TASK_FLAME_SOUNDS, _, _, "b");

			emit_sound(iPlayer, CHAN_VOICE, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
	}
	
	public Flame_Sounds(iTask_ID)
	{
		if (zp_grenade_fire_get(ID_FLAME_SOUNDS))
		{
			new szSound[128];

			Get_Random_Zombie_Sounds(get_user_current_zombie_class(ID_FLAME_SOUNDS), ZOMBIE_SOUND_FLAME, szSound, charsmax(szSound));

			emit_sound(ID_FLAME_SOUNDS, CHAN_VOICE, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}

		else
		{
			remove_task(iTask_ID);
		}
	}

#endif

public _zm_sound_zombie_register()
{
	new iClass = get_param(1);

	if (iClass < 0 || iClass >= MAX_ZOMBIE_CLASSES)
	{
		#if GLOBAL_MODES == 2 // Fork ZP 5.0.8

			log_error(AMX_ERR_NATIVE, "Zombie Class out of range");

		#else

			log_error(AMX_ERR_NATIVE, "[ZP] Zombie Class out of range", iClass);

		#endif
	}

	new ZOMBIE_SOUNDS:iType = ZOMBIE_SOUNDS:get_param(2);

	if (iType < ZOMBIE_SOUND_PAIN || iType > ZOMBIE_SOUND_FLAME)
	{
		#if GLOBAL_MODES == 2 // Fork ZP 5.0.8

			log_error(AMX_ERR_NATIVE, "Zombie Sound Type out of range");

		#else

			log_error(AMX_ERR_NATIVE, "[ZP] Zombie Class out of range", iType);

		#endif
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

#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

	public _zm_human_sound_register()
	{
		new iClass = get_param(1);

		if (iClass < 0 || iClass >= MAX_HUMAN_CLASSES)
		{
			#if GLOBAL_MODES == 2 // Fork ZP 5.0.8

				log_error(AMX_ERR_NATIVE, "Human Class out of range");

			#else

				log_error(AMX_ERR_NATIVE, "[ZP] Human Class out of range", iClass);

			#endif
		}

		new HUMAN_SOUNDS:iType = HUMAN_SOUNDS:get_param(2);

		if (iType < HUMAN_SOUND_PAIN || iType > HUMAN_SOUND_IDLE)
		{
			#if GLOBAL_MODES == 2 // Fork ZP 5.0.8

				log_error(AMX_ERR_NATIVE, "Human Sound Type out of range");

			#else

				log_error(AMX_ERR_NATIVE, "[ZP] Human Class out of range", iType);

			#endif
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

#endif

bool:Get_Random_Zombie_Sounds(const iClass, const ZOMBIE_SOUNDS:iType, szSound[], const iSize)
{
	if (g_aZombie_Sounds[iClass][iType] != Invalid_Array)
	{
		ArrayGetString(g_aZombie_Sounds[iClass][iType], random(ArraySize(g_aZombie_Sounds[iClass][iType])), szSound, iSize);

		return true;
	}

	return false;
}

#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

	bool:Get_Random_Human_Sounds(const iClass, const HUMAN_SOUNDS:iType, szSound[], const iSize)
	{
		if (g_aHuman_Sounds[iClass][iType] != Invalid_Array)
		{
			ArrayGetString(g_aHuman_Sounds[iClass][iType], random(ArraySize(g_aHuman_Sounds[iClass][iType])), szSound, iSize);

			return true;
		}

		return false;
	}

#endif

Remove_Tasks(iPlayer)
{
	remove_task(iPlayer + TASK_IDLE_SOUNDS);

	#if GLOBAL_MODES == 1 || GLOBAL_MODES == 2 // ZP 5.0.8 or Fork ZP 5.0.8

		remove_task(iPlayer + TASK_FLAME_SOUNDS);

	#endif
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

#if GLOBAL_MODES == 2

	public zp_fw_kill_pre_bit_sub(iPlayer)
	{
		Remove_Tasks(iPlayer);
	}

#else

	public RG_CSGameRules_PlayerKilled_Pre(iPlayer)
	{
		Remove_Tasks(iPlayer);
	}

#endif
