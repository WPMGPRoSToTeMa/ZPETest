/* AMX Mod X
*	[ZP] Item Zombie Madness.
*	Author: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "item zombie madness"
#define VERSION "1.0.0.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_items.ini"

new const g_szDefault_Sound_Zombie_Madness[] = "zombie_plague/zombie_madness1.wav";

#define ITEM_NAME "Zombie Madness"
#define ITEM_COST 1

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_zp50_kernel>
#include <ck_zp50_items>
#include <ck_zp50_class_zombie>
#include <ck_zp50_grenade_frost>
#include <ck_zp50_grenade_fire>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_assassin>

#define SOUND_MAX_LENGTH 64

#define TASK_MADNESS 100
#define TASK_AURA 200

#define ID_MADNESS (iTask_ID - TASK_MADNESS)
#define ID_AURA (iTask_ID - TASK_AURA)

#define ZP_ZOMBIE_CLASS_SETTINGS_PATH "ZPE/classes/zombie"

new const g_szSound_Section_Name[] = "Sounds";

new Array:g_aSound_Zombie_Madness;

new g_Item_ID;

new g_Madness_Block_Damage;

new g_pCvar_Zombie_Madness_Time;

new g_pCvar_Madness_Aura_Color_R;
new g_pCvar_Madness_Aura_Color_G;
new g_pCvar_Madness_Aura_Color_B;

new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Zombie_Madness_Time = register_cvar("zm_zombie_madness_time", "5");

	g_pCvar_Madness_Aura_Color_R = register_cvar("zm_zombie_madness_aura_color_R", "150");
	g_pCvar_Madness_Aura_Color_G = register_cvar("zm_zombie_madness_aura_color_G", "0");
	g_pCvar_Madness_Aura_Color_B = register_cvar("zm_zombie_madness_aura_color_B", "0");

	RegisterHookChain(RG_CBasePlayer_TraceAttack, "RG_CBasePlayer_TraceAttack_");
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_");
	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_Post", 1);

	g_Item_ID = zp_items_register(ITEM_NAME, ITEM_COST);
}

public zp_fw_class_zombie_register_post(classid)
{
	if (g_aSound_Zombie_Madness == Invalid_Array)
	{
		g_aSound_Zombie_Madness = ArrayCreate(1, 1);
	}
	
	new szReal_Name[32];
	zp_class_zombie_get_real_name(classid, szReal_Name, charsmax(szReal_Name));
	
	new szClass_Config_Path[64];
	formatex(szClass_Config_Path, charsmax(szClass_Config_Path), "%s/%s.ini", ZP_ZOMBIE_CLASS_SETTINGS_PATH, szReal_Name);
	
	new Array:aMadness_Sounds = ArrayCreate(SOUND_MAX_LENGTH, 1);
	amx_load_setting_string_arr(szClass_Config_Path, g_szSound_Section_Name, "MADNESS", aMadness_Sounds);
	new iArray_Size = ArraySize(aMadness_Sounds);
	
	if (iArray_Size > 0)
	{
		new szSound_Path[64];
		
		for (new i = 0; i < iArray_Size; i++)
		{
			ArrayGetString(aMadness_Sounds, i, szSound_Path, charsmax(szSound_Path));
			precache_sound(szSound_Path);
		}
	}
	
	else
	{
		ArrayDestroy(aMadness_Sounds);
		amx_save_setting_string(szClass_Config_Path, g_szSound_Section_Name, "MADNESS", g_szDefault_Sound_Zombie_Madness);
	}
	
	ArrayPushCell(g_aSound_Zombie_Madness, aMadness_Sounds);
}

public plugin_natives()
{
	register_library("ck_zp50_item_zombie_madness");

	register_native("zp_item_zombie_madness_get", "native_item_zombie_madness_get");
}

public native_item_zombie_madness_get(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid Player (%d)", iPlayer);

		return false;
	}

	return BIT_VALID(g_Madness_Block_Damage, iPlayer);
}

public zp_fw_items_select_pre(iPlayer, iItem_ID)
{
	// This is not our item
	if (iItem_ID != g_Item_ID)
	{
		return ZP_ITEM_AVAILABLE;
	}

	// Zombie madness only available to zombies
	if (!zp_core_is_zombie(iPlayer))
	{
		return ZP_ITEM_DONT_SHOW;
	}

	// Zombie madness not available to Nemesis/Assassin
	if (zp_class_nemesis_get(iPlayer) || zp_class_assassin_get(iPlayer))
	{
		return ZP_ITEM_DONT_SHOW;
	}

	// Player already has madness
	if (BIT_VALID(g_Madness_Block_Damage, iPlayer))
	{
		return ZP_ITEM_NOT_AVAILABLE;
	}

	return ZP_ITEM_AVAILABLE;
}

public zp_fw_items_select_post(iPlayer, iItem_ID)
{
	// This is not our item
	if (iItem_ID != g_Item_ID)
	{
		return;
	}

	// Do not take damage
	BIT_ADD(g_Madness_Block_Damage, iPlayer);

	// Madness aura
	set_task(0.1, "Madness_Aura", iPlayer + TASK_AURA, _, _, "b");

	// Madness sound
	new Array:aMadness_Sounds = ArrayGetCell(g_aSound_Zombie_Madness, zp_class_zombie_get_current(iPlayer));
	
	if (aMadness_Sounds != Invalid_Array)
	{
		new szSound_Path[64];
		ArrayGetString(aMadness_Sounds, random(ArraySize(aMadness_Sounds)), szSound_Path, charsmax(szSound_Path));
		emit_sound(iPlayer, CHAN_VOICE, szSound_Path, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	
	else
	{
		emit_sound(iPlayer, CHAN_VOICE, g_szDefault_Sound_Zombie_Madness, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}

	// Set task to remove it
	set_task(float(get_pcvar_num(g_pCvar_Zombie_Madness_Time)), "Remove_Zombie_Madness", iPlayer + TASK_MADNESS);
}

public RG_CBasePlayer_TraceAttack_(iVictim, iAttacker)
{
	// Non-player damage or self damage
	if (iVictim == iAttacker || BIT_NOT_VALID(g_iBit_Alive, iAttacker))
	{
		return HC_CONTINUE;
	}

	// Prevent attacks when victim has zombie madness
	if (BIT_VALID(g_Madness_Block_Damage, iVictim))
	{
		return HC_SUPERCEDE;
	}

	return HC_CONTINUE;
}

// Needed to block explosion damage too
public RG_CBasePlayer_TakeDamage_(iVictim, iInflictor, iAttacker)
{
	// Non-player damage or self damage
	if (iVictim == iAttacker || BIT_NOT_VALID(g_iBit_Alive, iAttacker))
	{
		return HC_CONTINUE;
	}

	// Prevent attacks when victim has zombie madness
	if (BIT_VALID(g_Madness_Block_Damage, iVictim))
	{
		return HC_SUPERCEDE;
	}

	return HC_CONTINUE;
}

public zp_fw_grenade_frost_pre(iPlayer)
{
	// Prevent frost when victim has zombie madness
	if (BIT_VALID(g_Madness_Block_Damage, iPlayer))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_grenade_fire_pre(iPlayer)
{
	// Prevent burning when victim has zombie madness
	if (BIT_VALID(g_Madness_Block_Damage, iPlayer))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public zp_fw_core_cure(iPlayer)
{
	// Remove zombie madness task
	remove_task(iPlayer + TASK_MADNESS);
	remove_task(iPlayer + TASK_AURA);

	BIT_SUB(g_Madness_Block_Damage, iPlayer);
}

public RG_CSGameRules_PlayerKilled_Post(iVictim)
{
	// Remove zombie madness task
	remove_task(iVictim + TASK_MADNESS);
	remove_task(iVictim + TASK_AURA);

	BIT_SUB(g_Madness_Block_Damage, iVictim);
}

// Remove Spawn Protection Task
public Remove_Zombie_Madness(iTask_ID)
{
	// Remove aura
	remove_task(ID_MADNESS + TASK_AURA);

	// Remove zombie madness
	BIT_SUB(g_Madness_Block_Damage, ID_MADNESS);
}

public client_disconnected(iPlayer)
{
	// Remove tasks on disconnect
	remove_task(iPlayer + TASK_MADNESS);
	remove_task(iPlayer + TASK_AURA);

	BIT_SUB(g_Madness_Block_Damage, iPlayer);

	BIT_SUB(g_iBit_Alive, iPlayer);
}

// Madness aura task
public Madness_Aura(iTask_ID)
{
	// Get player's origin
	static iOrigin[3];

	get_user_origin(ID_AURA, iOrigin);

	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
	write_byte(TE_DLIGHT); // TE id
	write_coord(iOrigin[0]); // x
	write_coord(iOrigin[1]); // y
	write_coord(iOrigin[2]); // z
	write_byte(20); // radius
	write_byte(get_pcvar_num(g_pCvar_Madness_Aura_Color_R)); // r
	write_byte(get_pcvar_num(g_pCvar_Madness_Aura_Color_G)); // g
	write_byte(get_pcvar_num(g_pCvar_Madness_Aura_Color_B)); // b
	write_byte(2); // life
	write_byte(0); // decay rate
	message_end();
}

public zpe_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zpe_fw_spawn_post_add_bit(iPlayer)
{
	// Remove zombie madness from a previous round
	remove_task(iPlayer + TASK_MADNESS);
	remove_task(iPlayer + TASK_AURA);

	BIT_SUB(g_Madness_Block_Damage, iPlayer);

	BIT_ADD(g_iBit_Alive, iPlayer);
}