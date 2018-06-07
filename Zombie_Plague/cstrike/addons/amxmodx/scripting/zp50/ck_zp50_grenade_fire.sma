/* AMX Mod X
*	[ZP] Grenade Fire.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "grenade fire"
#define VERSION "5.2.11.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_items.ini"

new g_V_Model_Grenade_Fire[64] = "models/zombie_plague/v_grenade_fire.mdl";
new g_P_Model_Grenade_Fire[64] = "models/p_hegrenade.mdl";
new g_W_Model_Grenade_Fire[64] = "models/w_hegrenade.mdl";

new g_Sprite_Grenade_Fire[64] = "sprites/flame.spr";

new const g_Sound_Grenade_Fire_Explode[][] =
{
	"zombie_plague/grenade_explode.wav"
};

#define GRENADE_FIRE_SPRITE_TRAIL "sprites/laserbeam.spr"
#define GRENADE_FIRE_SPRITE_RING "sprites/shockwave.spr"
#define GRENADE_FIRE_SPRITE_SMOKE "sprites/black_smoke3.spr"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <ck_cs_weap_models_api>
#include <ck_zp50_kernel>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_assassin>

// HACK: var_ field used to store custom nade types and their values
#define PEV_NADE_TYPE var_flTimeStepSound
#define NADE_TYPE_NAPALM 2222

#define TASK_BURN 100
#define ID_BURN (Task_ID - TASK_BURN)

#define MODEL_MAX_LENGTH 64
#define SOUND_MAX_LENGTH 64
#define SPRITE_MAX_LENGTH 64

// Custom Forwards
enum TOTAL_FORWARDS
{
	FW_USER_BURN_PRE = 0
};

new g_Forwards[TOTAL_FORWARDS];
new g_Forward_Result;

new g_Explode_Sprite;

new g_Burning_Duration[33];

new Array:g_aSound_Grenade_Fire_Explode;

new g_Trail_Sprite;
new g_Flame_Sprite;
new g_Smoke_Sprite;

new g_Message_Damage;

new g_iStatus_Icon;

new g_pCvar_Grenade_Fire_Duration;
new g_pCvar_Grenade_Fire_Damage;
new g_pCvar_Grenade_Fire_Slowdown;
new g_pCvar_Grenade_Fire_Hudicon_Player;
new g_pCvar_Grenade_Fire_Hudicon_Enemy;
new g_pCvar_Grenade_Fire_Explosion;

new g_pCvar_Grenade_Fire_Hudicon_Player_Color_R;
new g_pCvar_Grenade_Fire_Hudicon_Player_Color_G;
new g_pCvar_Grenade_Fire_Hudicon_Player_Color_B;

new g_pCvar_Grenade_Fire_Glow_Rendering_R;
new g_pCvar_Grenade_Fire_Glow_Rendering_G;
new g_pCvar_Grenade_Fire_Glow_Rendering_B;

new g_pCvar_Grenade_Fire_Trail_Rendering_R;
new g_pCvar_Grenade_Fire_Trail_Rendering_G;
new g_pCvar_Grenade_Fire_Trail_Rendering_B;

new g_pCvar_Grenade_Fire_Small_Ring_Rendering_R;
new g_pCvar_Grenade_Fire_Small_Ring_Rendering_G;
new g_pCvar_Grenade_Fire_Small_Ring_Rendering_B;

new g_pCvar_Grenade_Fire_Medium_Ring_Rendering_R;
new g_pCvar_Grenade_Fire_Medium_Ring_Rendering_G;
new g_pCvar_Grenade_Fire_Medium_Ring_Rendering_B;

new g_pCvar_Grenade_Fire_Largest_Ring_Rendering_R;
new g_pCvar_Grenade_Fire_Largest_Ring_Rendering_G;
new g_pCvar_Grenade_Fire_Largest_Ring_Rendering_B;

new g_pCvar_Grenade_Fire_Explosion_Radius;

new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Grenade_Fire_Duration = register_cvar("zm_grenade_fire_duration", "10");
	g_pCvar_Grenade_Fire_Damage = register_cvar("zm_grenade_fire_damage", "5");
	g_pCvar_Grenade_Fire_Slowdown = register_cvar("zm_grenade_fire_slowdown", "0.5");
	g_pCvar_Grenade_Fire_Hudicon_Player = register_cvar("zm_grenade_fire_hudicon_player", "1");
	g_pCvar_Grenade_Fire_Hudicon_Enemy = register_cvar("zm_grenade_fire_hudicon_enemy", "1");
	g_pCvar_Grenade_Fire_Explosion = register_cvar("zm_grenade_fire_explosion", "0");
	
	g_pCvar_Grenade_Fire_Hudicon_Player_Color_R = register_cvar("zm_grenade_fire_hudicon_player_color_r", "255");
	g_pCvar_Grenade_Fire_Hudicon_Player_Color_G = register_cvar("zm_grenade_fire_hudicon_player_color_g", "0");
	g_pCvar_Grenade_Fire_Hudicon_Player_Color_B = register_cvar("zm_grenade_fire_hudicon_player_color_b", "0");

	g_pCvar_Grenade_Fire_Glow_Rendering_R = register_cvar("zm_grenade_fire_glow_rendering_r", "200");
	g_pCvar_Grenade_Fire_Glow_Rendering_G = register_cvar("zm_grenade_fire_glow_rendering_g", "0");
	g_pCvar_Grenade_Fire_Glow_Rendering_B = register_cvar("zm_grenade_fire_glow_rendering_b", "0");

	g_pCvar_Grenade_Fire_Trail_Rendering_R = register_cvar("zm_grenade_fire_trail_rendering_r", "200");
	g_pCvar_Grenade_Fire_Trail_Rendering_G = register_cvar("zm_grenade_fire_trail_rendering_g", "0");
	g_pCvar_Grenade_Fire_Trail_Rendering_B = register_cvar("zm_grenade_fire_trail_rendering_b", "0");

	g_pCvar_Grenade_Fire_Small_Ring_Rendering_R = register_cvar("zm_grenade_fire_small_ring_rendering_r", "200");
	g_pCvar_Grenade_Fire_Small_Ring_Rendering_G = register_cvar("zm_grenade_fire_small_ring_rendering_g", "100");
	g_pCvar_Grenade_Fire_Small_Ring_Rendering_B = register_cvar("zm_grenade_fire_small_ring_rendering_b", "0");

	g_pCvar_Grenade_Fire_Medium_Ring_Rendering_R = register_cvar("zm_grenade_fire_medium_ring_rendering_r", "200");
	g_pCvar_Grenade_Fire_Medium_Ring_Rendering_G = register_cvar("zm_grenade_fire_medium_ring_rendering_g", "50");
	g_pCvar_Grenade_Fire_Medium_Ring_Rendering_B = register_cvar("zm_grenade_fire_medium_ring_rendering_b", "0");

	g_pCvar_Grenade_Fire_Largest_Ring_Rendering_R = register_cvar("zm_grenade_fire_largest_ring_rendering_r", "200");
	g_pCvar_Grenade_Fire_Largest_Ring_Rendering_G = register_cvar("zm_grenade_fire_largest_ring_rendering_g", "0");
	g_pCvar_Grenade_Fire_Largest_Ring_Rendering_B = register_cvar("zm_grenade_fire_largest_ring_rendering_b", "0");

	g_pCvar_Grenade_Fire_Explosion_Radius = register_cvar("zm_grenade_fire_explosion_radius", "240");

	RegisterHam(Ham_Think, "grenade", "Ham_Think_Grenade_");

	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_Post", 1);

	register_forward(FM_SetModel, "FM_SetModel_");

	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1");
	register_event("DeathMsg", "Event_DeathMsg", "a");

	g_iStatus_Icon = get_user_msgid("StatusIcon");
	g_Message_Damage = get_user_msgid("Damage");

	g_Forwards[FW_USER_BURN_PRE] = CreateMultiForward("zp_fw_grenade_fire_pre", ET_CONTINUE, FP_CELL);
}

public plugin_precache()
{
	// Initialize arrays
	g_aSound_Grenade_Fire_Explode = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "GRENADE FIRE EXPLODE", g_aSound_Grenade_Fire_Explode);
	
	// Load from external file, save if not found
	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V GRENADE FIRE", g_V_Model_Grenade_Fire, charsmax(g_V_Model_Grenade_Fire)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V GRENADE FIRE", g_V_Model_Grenade_Fire);
	}

	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "P GRENADE FIRE", g_P_Model_Grenade_Fire, charsmax(g_P_Model_Grenade_Fire)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "P GRENADE FIRE", g_P_Model_Grenade_Fire);
	}

	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "W GRENADE FIRE", g_W_Model_Grenade_Fire, charsmax(g_W_Model_Grenade_Fire)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "W GRENADE FIRE", g_W_Model_Grenade_Fire);
	}

	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Grenade Sprites", "FIRE", g_Sprite_Grenade_Fire, charsmax(g_Sprite_Grenade_Fire)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Grenade Sprites", "FIRE", g_Sprite_Grenade_Fire);
	}

	// If we couldn't load custom sounds from file, use and save default ones
	if (ArraySize(g_aSound_Grenade_Fire_Explode) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Grenade_Fire_Explode; i++)
		{
			ArrayPushString(g_aSound_Grenade_Fire_Explode, g_Sound_Grenade_Fire_Explode[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "GRENADE FIRE EXPLODE", g_aSound_Grenade_Fire_Explode);
	}

	for (new i = 0; i < sizeof g_Sound_Grenade_Fire_Explode; i++)
	{
		precache_sound(g_Sound_Grenade_Fire_Explode[i]);
	}

	g_Explode_Sprite = precache_model(GRENADE_FIRE_SPRITE_RING);

	// Precache models
	precache_model(g_V_Model_Grenade_Fire);
	precache_model(g_P_Model_Grenade_Fire);
	precache_model(g_W_Model_Grenade_Fire);

	g_Trail_Sprite = precache_model(GRENADE_FIRE_SPRITE_TRAIL);
	g_Flame_Sprite = precache_model(g_Sprite_Grenade_Fire);
	g_Smoke_Sprite = precache_model(GRENADE_FIRE_SPRITE_SMOKE);
}

public plugin_natives()
{
	register_library("ck_zp50_grenade_fire");

	register_native("zp_grenade_fire_get", "native_grenade_fire_get");
	register_native("zp_grenade_fire_set", "native_grenade_fire_set");
}

public native_grenade_fire_get(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	return task_exists(iPlayer + TASK_BURN);
}

public native_grenade_fire_set(iPlugin_ID, iNum_Params)
{
	new iPlayer = get_param(1);

	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player (%d)", iPlayer);

		return false;
	}

	new iSet = get_param(2);

	// End fire
	if (!iSet)
	{
		// Not burning
		if (!task_exists(iPlayer + TASK_BURN))
		{
			return true;
		}

		// Get player origin
		static iOrigin[3];

		get_user_origin(iPlayer, iOrigin);

		// Smoke sprite
		message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
		write_byte(TE_SMOKE); // TE player
		write_coord(iOrigin[0]); // x
		write_coord(iOrigin[1]); // y
		write_coord(iOrigin[2] - 50); // z
		write_short(g_Smoke_Sprite); // sprite
		write_byte(random_num(15, 20)); // scale
		write_byte(random_num(10, 20)); // framerate
		message_end();

		// Task not needed anymore
		remove_task(iPlayer + TASK_BURN);

		return true;
	}

	// Set on fire
	return Set_On_Fire(iPlayer);
}

public zp_fw_core_cure_post(iPlayer)
{
	// Stop burning
	remove_task(iPlayer + TASK_BURN);

	g_Burning_Duration[iPlayer] = 0;

	// Set custom grenade model
	cs_set_player_view_model(iPlayer, CSW_HEGRENADE, g_V_Model_Grenade_Fire);
	cs_set_player_weap_model(iPlayer, CSW_HEGRENADE, g_P_Model_Grenade_Fire);
}

public zp_fw_core_infect(iPlayer)
{
	// Remove custom grenade model
	cs_reset_player_view_model(iPlayer, CSW_HEGRENADE);
}

public RG_CSGameRules_PlayerKilled_Post(iVictim)
{
	// Stop burning
	remove_task(iVictim + TASK_BURN);

	g_Burning_Duration[iVictim] = 0;
}

// Forward Set Model
public FM_SetModel_(iEntity, const sModel[])
{
	// We don't care
	if (strlen(sModel) < 8)
	{
		return FMRES_IGNORED;
	}

	// Narrow down our matches a bit
	if (sModel[7] != 'w' || sModel[8] != '_')
	{
		return FMRES_IGNORED;
	}

	// Get damage time of grenade
	static Float:fDamage_Time;

	get_entvar(iEntity, var_dmgtime, fDamage_Time);

	// Grenade not yet thrown
	if (fDamage_Time == 0.0)
	{
		return FMRES_IGNORED;
	}

	// Grenade's owner is zombie?
	if (zp_core_is_zombie(get_entvar(iEntity, var_owner)))
	{
		return FMRES_IGNORED;
	}

	// HE Grenade
	if (sModel[9] == 'h' && sModel[10] == 'e')
	{
		// Give it a glow
		rh_set_user_rendering(iEntity, kRenderFxGlowShell, get_pcvar_num(g_pCvar_Grenade_Fire_Glow_Rendering_R), get_pcvar_num(g_pCvar_Grenade_Fire_Glow_Rendering_G), get_pcvar_num(g_pCvar_Grenade_Fire_Glow_Rendering_B), kRenderNormal, 16);

		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW); // TE player
		write_short(iEntity); // entity
		write_short(g_Trail_Sprite); // sprite
		write_byte(10); // life
		write_byte(10); // width
		write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Trail_Rendering_R)); // r
		write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Trail_Rendering_G)); // g
		write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Trail_Rendering_B)); // b
		write_byte(200); // brightness
		message_end();

		// Set grenade type on the thrown grenade entity
		set_entvar(iEntity, PEV_NADE_TYPE, NADE_TYPE_NAPALM);

		engfunc(EngFunc_SetModel, iEntity, g_W_Model_Grenade_Fire);

		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

// Ham Grenade Think Forward
public Ham_Think_Grenade_(iEntity)
{
	// Invalid entity
	if (!is_entity(iEntity))
	{
		return HAM_IGNORED;
	}

	// Get damage time of grenade
	static Float:fDamage_Time;

	get_entvar(iEntity, var_dmgtime, fDamage_Time);

	// Check if it's time to go off
	if (fDamage_Time > get_gametime())
	{
		return HAM_IGNORED;
	}

	// Not a napalm grenade
	if (get_entvar(iEntity, PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
	{
		return HAM_IGNORED;
	}

	Fire_Explode(iEntity);

	// Keep the original explosion?
	if (get_pcvar_num(g_pCvar_Grenade_Fire_Explosion))
	{
		set_entvar(iEntity, PEV_NADE_TYPE, 0);

		return HAM_IGNORED;
	}

	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, iEntity);

	return HAM_SUPERCEDE;
}

public client_disconnected(iPlayer)
{
	// Stop burning
	remove_task(iPlayer + TASK_BURN);

	g_Burning_Duration[iPlayer] = 0;

	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}

public zp_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

// Fire Grenade Explosion
Fire_Explode(iEntity)
{
	// Get origin
	static Float:fOrigin[3];

	get_entvar(iEntity, var_origin, fOrigin);

	// Override original HE grenade explosion?
	if (!get_pcvar_num(g_pCvar_Grenade_Fire_Explosion))
	{
		// Make the explosion
		Create_Blast2(fOrigin);

		// Fire nade explode sound
		emit_sound(iEntity, CHAN_VOICE, g_Sound_Grenade_Fire_Explode[random(sizeof g_Sound_Grenade_Fire_Explode)], 1.0, ATTN_NORM, 0, PITCH_NORM);
	}

	// Collisions
	new iVictim = -1;

	while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, fOrigin, get_pcvar_num(g_pCvar_Grenade_Fire_Explosion_Radius))) != 0)
	{
		// Only effect alive zombies
		if (iVictim > 32 || BIT_NOT_VALID(g_iBit_Alive, iVictim) || !zp_core_is_zombie(iVictim))
		{
			continue;
		}

		Set_On_Fire(iVictim);
	}
}

Set_On_Fire(iVictim)
{
	// Allow other plugins to decide whether player should be burned or not
	ExecuteForward(g_Forwards[FW_USER_BURN_PRE], g_Forward_Result, iVictim);

	if (g_Forward_Result >= PLUGIN_HANDLED)
	{
		return false;
	}

	// Heat icon?
	if (get_pcvar_num(g_pCvar_Grenade_Fire_Hudicon_Enemy))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_Message_Damage, _, iVictim);
		write_byte(0); // damage save
		write_byte(0); // damage take
		write_long(DMG_BURN); // damage type
		write_coord(0); // x
		write_coord(0); // y
		write_coord(0); // z
		message_end();
	}

	// Reduced duration for nemesis
	if (zp_class_nemesis_get(iVictim))
	{
		// Fire duration (nemesis)
		g_Burning_Duration[iVictim] += get_pcvar_num(g_pCvar_Grenade_Fire_Duration);
	}

	// Reduced duration for assassin
	if (zp_class_assassin_get(iVictim))
	{
		// Fire duration (assassin)
		g_Burning_Duration[iVictim] += get_pcvar_num(g_pCvar_Grenade_Fire_Duration);
	}

	else
	{
		// Fire duration (zombie)
		g_Burning_Duration[iVictim] += get_pcvar_num(g_pCvar_Grenade_Fire_Duration) * 5;
	}

	// Set burning task on victim
	remove_task(iVictim + TASK_BURN);

	set_task(0.2, "Burning_Flame", iVictim + TASK_BURN, _, _, "b");

	return true;
}

// Burning Flames
public Burning_Flame(Task_ID)
{
	// Get player origin and flags
	static iOrigin[3];

	get_user_origin(ID_BURN, iOrigin);

	new iFlags = get_entvar(ID_BURN, var_flags);

	// In water or burning stopped
	if ((iFlags & FL_INWATER) || g_Burning_Duration[ID_BURN] < 1)
	{
		// Smoke sprite
		message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
		write_byte(TE_SMOKE); // TE player
		write_coord(iOrigin[0]); // x
		write_coord(iOrigin[1]); // y
		write_coord(iOrigin[2] - 50); // z
		write_short(g_Smoke_Sprite); // sprite
		write_byte(random_num(15, 20)); // scale
		write_byte(random_num(10, 20)); // framerate
		message_end();

		// Task not needed anymore
		remove_task(Task_ID);

		return;
	}

	// Nemesis Class loaded?
	if (!zp_class_nemesis_get(ID_BURN))
	{
		// Fire slow down
		if ((iFlags & FL_ONGROUND) && get_pcvar_float(g_pCvar_Grenade_Fire_Slowdown) > 0.0)
		{
			static Float:fVelocity[3];

			get_entvar(ID_BURN, var_velocity, fVelocity);

			xs_vec_mul_scalar(fVelocity, get_pcvar_float(g_pCvar_Grenade_Fire_Slowdown), fVelocity);

			set_entvar(ID_BURN, var_velocity, fVelocity);
		}
	}

	// Assassin Class loaded?
	if (!zp_class_assassin_get(ID_BURN))
	{
		// Fire slow down
		if ((iFlags & FL_ONGROUND) && get_pcvar_float(g_pCvar_Grenade_Fire_Slowdown) > 0.0)
		{
			static Float:fVelocity[3];

			get_entvar(ID_BURN, var_velocity, fVelocity);

			xs_vec_mul_scalar(fVelocity, get_pcvar_float(g_pCvar_Grenade_Fire_Slowdown), fVelocity);

			set_entvar(ID_BURN, var_velocity, fVelocity);
		}
	}

	// Get player's health
	new iHealth = GET_USER_HEALTH(ID_BURN);

	// Take damage from the fire
	if (iHealth - floatround(get_pcvar_float(g_pCvar_Grenade_Fire_Damage), floatround_ceil) > 0)
	{
		SET_USER_HEALTH(ID_BURN, Float:iHealth - floatround(get_pcvar_float(g_pCvar_Grenade_Fire_Damage), floatround_ceil));
	}

	// Flame sprite
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
	write_byte(TE_SPRITE); // TE player
	write_coord(iOrigin[0] + random_num(-5, 5)); // x
	write_coord(iOrigin[1] + random_num(-5, 5)); // y
	write_coord(iOrigin[2] + random_num(-10, 10)); // z
	write_short(g_Flame_Sprite); // sprite
	write_byte(random_num(5, 10)); // scale
	write_byte(200); // brightness
	message_end();

	// Decrease burning duration counter
	g_Burning_Duration[ID_BURN] -= 1;
}

public Event_CurWeapon(iPlayer)
{
	if (get_pcvar_num(g_pCvar_Grenade_Fire_Hudicon_Player))
	{
		// TODO: if zp_core_is_zombie - crutch. Use wpn key
		if (read_data(2) == CSW_HEGRENADE && !zp_core_is_zombie(iPlayer))
		{
			message_begin(MSG_ONE, g_iStatus_Icon, _, iPlayer);
			write_byte(1);
			write_string("dmg_heat");
			write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Hudicon_Player_Color_R));
			write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Hudicon_Player_Color_G));
			write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Hudicon_Player_Color_B));
			message_end();
		}

		else
		{
			Grenade_Icon_Remove(iPlayer);

			return;
		}
	}
}

public Event_DeathMsg()
{
	if (get_pcvar_num(g_pCvar_Grenade_Fire_Hudicon_Player))
	{
		Grenade_Icon_Remove(read_data(2));
	}
}

Grenade_Icon_Remove(iPlayer)
{
	message_begin(MSG_ONE, g_iStatus_Icon, _, iPlayer);
	write_byte(0);
	write_string("dmg_heat");
	message_end();
}

// Fire Grenade: Fire Blast
Create_Blast2(const Float:fOrigin[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0);
	write_byte(TE_BEAMCYLINDER); // TE player
	engfunc(EngFunc_WriteCoord, fOrigin[0]); // x
	engfunc(EngFunc_WriteCoord, fOrigin[1]); // y
	engfunc(EngFunc_WriteCoord, fOrigin[2]); // z
	engfunc(EngFunc_WriteCoord, fOrigin[0]); // x axis
	engfunc(EngFunc_WriteCoord, fOrigin[1]); // y axis
	engfunc(EngFunc_WriteCoord, fOrigin[2] + 385.0); // z axis
	write_short(g_Explode_Sprite); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Small_Ring_Rendering_R)); // red
	write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Small_Ring_Rendering_G)); // green
	write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Small_Ring_Rendering_B)); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();

	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0);
	write_byte(TE_BEAMCYLINDER); // TE player
	engfunc(EngFunc_WriteCoord, fOrigin[0]); // x
	engfunc(EngFunc_WriteCoord, fOrigin[1]); // y
	engfunc(EngFunc_WriteCoord, fOrigin[2]); // z
	engfunc(EngFunc_WriteCoord, fOrigin[0]); // x axis
	engfunc(EngFunc_WriteCoord, fOrigin[1]); // y axis
	engfunc(EngFunc_WriteCoord, fOrigin[2] + 470.0); // z axis
	write_short(g_Explode_Sprite); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Medium_Ring_Rendering_R)); // red
	write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Medium_Ring_Rendering_G)); // green
	write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Medium_Ring_Rendering_B)); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();

	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0);
	write_byte(TE_BEAMCYLINDER); // TE player
	engfunc(EngFunc_WriteCoord, fOrigin[0]); // x
	engfunc(EngFunc_WriteCoord, fOrigin[1]); // y
	engfunc(EngFunc_WriteCoord, fOrigin[2]); // z
	engfunc(EngFunc_WriteCoord, fOrigin[0]); // x axis
	engfunc(EngFunc_WriteCoord, fOrigin[1]); // y axis
	engfunc(EngFunc_WriteCoord, fOrigin[2] + 555.0); // z axis
	write_short(g_Explode_Sprite); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Largest_Ring_Rendering_R)); // red
	write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Largest_Ring_Rendering_G)); // green
	write_byte(get_pcvar_num(g_pCvar_Grenade_Fire_Largest_Ring_Rendering_B)); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
}