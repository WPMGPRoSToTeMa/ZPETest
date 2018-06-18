/* AMX Mod X
*	[ZP] Item Infection Bomb.
*	Author: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "grenade infection"
#define VERSION "1.0.0.0"
#define AUTHOR "C&K Corporation"

#define ZP_SETTINGS_FILE "zm_items.ini"

new g_V_Model_Grenade_Infection[64] = "models/zombie_plague/v_grenade_infect.mdl"
new g_P_Model_Grenade_Infection[64] = "models/p_hegrenade.mdl";
new g_W_Model_Grenade_Infection[64] = "models/w_hegrenade.mdl";

// Default sounds
new const g_Sound_Grenade_Infect_Explode[][] =
{
	"zombie_plague/grenade_infect.wav"
};

new const g_Sound_Grenade_Infect_Player[][] =
{
	"scientist/scream20.wav",
	"scientist/scream22.wav",
	"scientist/scream05.wav"
};

#define ITEM_NAME "Infection Bomb"
#define ITEM_COST 1

#define GRENADE_INFECTION_SPRITE_TRAIL "sprites/laserbeam.spr"
#define GRENADE_INFECTION_SPRITE_RING "sprites/shockwave.spr"

#include <amxmodx>
#include <cs_util>
#include <ck_cs_weap_models_api>
#include <amx_settings_api>
#include <fakemeta>
#include <hamsandwich>
#include <ck_zp50_kernel>
#include <ck_zp50_items>
#include <ck_zp50_gamemodes>

#define SOUND_MAX_LENGTH 64

// HACK: var_ field used to store custom nade types and their values
#define PEV_NADE_TYPE var_flTimeStepSound
#define NADE_TYPE_INFECTION 1111

new Array:g_aSound_Grenade_Infect_Explode;
new Array:g_aSound_Grenade_Infect_Player;

new g_Trail_Sprite;
new g_Explode_Sprite;

new g_Item_ID;

new g_Game_Mode_Infection_ID;
new g_Game_Mode_Multi_ID;

new g_Infection_Bomb_Counter;

new g_pCvar_Grenade_Infection_Explosion_Radius;

new g_pCvar_Grenade_Infection_Glow_Rendering_R;
new g_pCvar_Grenade_Infection_Glow_Rendering_G;
new g_pCvar_Grenade_Infection_Glow_Rendering_B;

new g_pCvar_Grenade_Infection_Trail_Rendering_R;
new g_pCvar_Grenade_Infection_Trail_Rendering_G;
new g_pCvar_Grenade_Infection_Trail_Rendering_B;

new g_pCvar_Grenade_Infection_Small_Ring_Rendering_R;
new g_pCvar_Grenade_Infection_Small_Ring_Rendering_G;
new g_pCvar_Grenade_Infection_Small_Ring_Rendering_B;

new g_pCvar_Grenade_Infection_Medium_Ring_Rendering_R;
new g_pCvar_Grenade_Infection_Medium_Ring_Rendering_G;
new g_pCvar_Grenade_Infection_Medium_Ring_Rendering_B;

new g_pCvar_Grenade_Infection_Largest_Ring_Rendering_R;
new g_pCvar_Grenade_Infection_Largest_Ring_Rendering_G;
new g_pCvar_Grenade_Infection_Largest_Ring_Rendering_B;

new g_iBit_Alive;
new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Grenade_Infection_Explosion_Radius = register_cvar("zm_grenade_infection_explosion_radius", "240");

	g_pCvar_Grenade_Infection_Glow_Rendering_R = register_cvar("zm_grenade_infection_glow_rendering_r", "0");
	g_pCvar_Grenade_Infection_Glow_Rendering_G = register_cvar("zm_grenade_infection_glow_rendering_g", "200");
	g_pCvar_Grenade_Infection_Glow_Rendering_B = register_cvar("zm_grenade_infection_glow_rendering_b", "0");

	g_pCvar_Grenade_Infection_Trail_Rendering_R = register_cvar("zm_grenade_infection_trail_rendering_r", "0");
	g_pCvar_Grenade_Infection_Trail_Rendering_G = register_cvar("zm_grenade_infection_trail_rendering_g", "200");
	g_pCvar_Grenade_Infection_Trail_Rendering_B = register_cvar("zm_grenade_infection_trail_rendering_b", "0");

	g_pCvar_Grenade_Infection_Small_Ring_Rendering_R = register_cvar("zm_grenade_infection_small_ring_rendering_r", "0");
	g_pCvar_Grenade_Infection_Small_Ring_Rendering_G = register_cvar("zm_grenade_infection_small_ring_rendering_g", "200");
	g_pCvar_Grenade_Infection_Small_Ring_Rendering_B = register_cvar("zm_grenade_infection_small_ring_rendering_b", "0");

	g_pCvar_Grenade_Infection_Medium_Ring_Rendering_R = register_cvar("zm_grenade_infection_medium_ring_rendering_r", "0");
	g_pCvar_Grenade_Infection_Medium_Ring_Rendering_G = register_cvar("zm_grenade_infection_medium_ring_rendering_g", "200");
	g_pCvar_Grenade_Infection_Medium_Ring_Rendering_B = register_cvar("zm_grenade_infection_medium_ring_rendering_b", "0");

	g_pCvar_Grenade_Infection_Largest_Ring_Rendering_R = register_cvar("zm_grenade_infection_largest_ring_rendering_r", "0");
	g_pCvar_Grenade_Infection_Largest_Ring_Rendering_G = register_cvar("zm_grenade_infection_largest_ring_rendering_g", "200");
	g_pCvar_Grenade_Infection_Largest_Ring_Rendering_B = register_cvar("zm_grenade_infection_largest_ring_rendering_b", "0");

	RegisterHam(Ham_Think, "grenade", "Ham_Think_Grenade_");

	register_event("HLTV", "Event_Round_Start", "a", "1=0", "2=0");

	register_forward(FM_SetModel, "FM_SetModel_");

	g_Item_ID = zp_items_register(ITEM_NAME, ITEM_COST);
}

public plugin_precache()
{
	// Initialize arrays
	g_aSound_Grenade_Infect_Explode = ArrayCreate(SOUND_MAX_LENGTH, 1);
	g_aSound_Grenade_Infect_Player = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "GRENADE INFECTION EXPLODE", g_aSound_Grenade_Infect_Explode);
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "GRENADE INFECTION PLAYER", g_aSound_Grenade_Infect_Player);

	// Load from external file, save if not found
	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V GRENADE INFECTION", g_V_Model_Grenade_Infection, charsmax(g_V_Model_Grenade_Infection)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "V GRENADE INFECTION", g_V_Model_Grenade_Infection);
	}

	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "P GRENADE INFECTION", g_P_Model_Grenade_Infection, charsmax(g_P_Model_Grenade_Infection)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "P GRENADE INFECTION", g_P_Model_Grenade_Infection);
	}

	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "W GRENADE INFECTION", g_W_Model_Grenade_Infection, charsmax(g_W_Model_Grenade_Infection)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "W GRENADE INFECTION", g_W_Model_Grenade_Infection);
	}

	// If we couldn't load custom sounds from file, use and save default ones
	if (ArraySize(g_aSound_Grenade_Infect_Explode) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Grenade_Infect_Explode; i++)
		{
			ArrayPushString(g_aSound_Grenade_Infect_Explode, g_Sound_Grenade_Infect_Explode[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "GRENADE INFECTION EXPLODE", g_aSound_Grenade_Infect_Explode);
	}

	if (ArraySize(g_aSound_Grenade_Infect_Player) == 0)
	{
		for (new i = 0; i < sizeof g_Sound_Grenade_Infect_Player; i++)
		{
			ArrayPushString(g_aSound_Grenade_Infect_Player, g_Sound_Grenade_Infect_Player[i]);
		}

		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "GRENADE INFECTION PLAYER", g_aSound_Grenade_Infect_Player);
	}

	// Load from external file, save if not found
	if (!amx_load_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "GRENADE INFECTION", g_V_Model_Grenade_Infection, charsmax(g_V_Model_Grenade_Infection)))
	{
		amx_save_setting_string(ZP_SETTINGS_FILE, "Weapon Models", "GRENADE INFECTION", g_V_Model_Grenade_Infection);
	}

	// Precache sounds
	for (new i = 0; i < sizeof g_Sound_Grenade_Infect_Explode; i++)
	{
		precache_sound(g_Sound_Grenade_Infect_Explode[i]);
	}

	for (new i = 0; i < sizeof g_Sound_Grenade_Infect_Player; i++)
	{
		precache_sound(g_Sound_Grenade_Infect_Player[i]);
	}

	// Precache models
	precache_model(g_V_Model_Grenade_Infection);
	precache_model(g_P_Model_Grenade_Infection);
	precache_model(g_W_Model_Grenade_Infection);

	g_Trail_Sprite = precache_model(GRENADE_INFECTION_SPRITE_TRAIL);
	g_Explode_Sprite = precache_model(GRENADE_INFECTION_SPRITE_RING);
}

public plugin_cfg()
{
	g_Game_Mode_Infection_ID = zp_gamemodes_get_id("Infection Mode");
	g_Game_Mode_Multi_ID = zp_gamemodes_get_id("Multiple Infection Mode");
}

public Event_Round_Start()
{
	g_Infection_Bomb_Counter = 0;
}

public zp_fw_items_select_pre(iPlayer, iItem_ID)
{
	// This is not our item
	if (iItem_ID != g_Item_ID)
	{
		return ZP_ITEM_AVAILABLE;
	}

	// Infection bomb only available during infection modes
	new iCurrent_Mode = zp_gamemodes_get_current();

	if (iCurrent_Mode != g_Game_Mode_Infection_ID && iCurrent_Mode != g_Game_Mode_Multi_ID)
	{
		return ZP_ITEM_DONT_SHOW;
	}

	// Infection bomb only available to zombies
	if (!zp_core_is_zombie(iPlayer))
	{
		return ZP_ITEM_DONT_SHOW;
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

	// Give infection bomb
	rg_give_item(iPlayer, "weapon_hegrenade");

	g_Infection_Bomb_Counter++;
}

public zp_fw_core_cure(iPlayer, iAttacker)
{
	// Remove custom grenade model
	cs_reset_player_view_model(iPlayer, CSW_HEGRENADE);
}

public zp_fw_core_infect_post(iPlayer, iAttacker)
{
	// Set custom grenade model
	cs_set_player_view_model(iPlayer, CSW_HEGRENADE, g_V_Model_Grenade_Infection);
	cs_set_player_weap_model(iPlayer, CSW_HEGRENADE, g_P_Model_Grenade_Infection);
}

// Forward Set Model
public FM_SetModel_(iEntity, const szModel[])
{
	// We don't care
	if (strlen(szModel) < 8)
	{
		return;
	}

	// Narrow down our matches a bit
	if (szModel[7] != 'w' || szModel[8] != '_')
	{
		return;
	}

	// Get damage time of grenade
	static Float:fDamage_Time;

	get_entvar(iEntity, var_dmgtime, fDamage_Time);

	// Grenade not yet thrown
	if (fDamage_Time == 0.0)
	{
		return;
	}

	// Grenade's owner isn't zombie?
	if (!zp_core_is_zombie(get_entvar(iEntity, var_owner)))
	{
		return;
	}

	// HE Grenade
	if (szModel[9] == 'h' && szModel[10] == 'e')
	{
		// Give it a glow
		rh_set_user_rendering(iEntity, kRenderFxGlowShell, get_pcvar_num(g_pCvar_Grenade_Infection_Glow_Rendering_R), get_pcvar_num(g_pCvar_Grenade_Infection_Glow_Rendering_G), get_pcvar_num(g_pCvar_Grenade_Infection_Glow_Rendering_B), kRenderNormal, 16);

		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW); // TE player
		write_short(iEntity); // entity
		write_short(g_Trail_Sprite); // sprite
		write_byte(10); // life
		write_byte(10); // width
		write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Trail_Rendering_R)); // r
		write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Trail_Rendering_G)); // g
		write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Trail_Rendering_B)); // b
		write_byte(200); // brightness
		message_end();

		engfunc(EngFunc_SetModel, iEntity, g_W_Model_Grenade_Infection);

		// Set grenade type on the thrown grenade entity
		set_entvar(iEntity, PEV_NADE_TYPE, NADE_TYPE_INFECTION);
	}
}

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

	// Check if it's one of our custom nades
	switch (get_entvar(iEntity, PEV_NADE_TYPE))
	{
		case NADE_TYPE_INFECTION: // Infection Bomb
		{
			Infection_Explode(iEntity);

			return HAM_SUPERCEDE;
		}
	}

	return HAM_IGNORED;
}

// Infection Bomb Explosion
Infection_Explode(iEntity)
{
	// Round ended
	if (zp_gamemodes_get_current() == ZP_NO_GAME_MODE)
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, iEntity);

		return;
	}

	// Get origin
	static Float:fOrigin[3];

	get_entvar(iEntity, var_origin, fOrigin);

	// Make the explosion
	Create_Blast(fOrigin);

	// Infection nade explode sound
	emit_sound(iEntity, CHAN_WEAPON, g_Sound_Grenade_Infect_Explode[random(sizeof g_Sound_Grenade_Infect_Explode)], 1.0, ATTN_NORM, 0, PITCH_NORM);

	// Get attacker
	new iAttacker = get_entvar(iEntity, var_owner);

	// Infection bomb owner disconnected or not zombie anymore?
	if (BIT_NOT_VALID(g_iBit_Connected, iAttacker) || !zp_core_is_zombie(iAttacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, iEntity);

		return;
	}

	// Collisions
	new iVctim = -1;

	while ((iVctim = engfunc(EngFunc_FindEntityInSphere, iVctim, fOrigin, get_pcvar_num(g_pCvar_Grenade_Infection_Explosion_Radius))) != 0)
	{
		// Only effect alive humans
		if (BIT_NOT_VALID(g_iBit_Alive, iVctim) || zp_core_is_zombie(iVctim))
		{
			continue;
		}

		// Last human is killed
		if (zp_core_get_human_count() == 1)
		{
			ExecuteHamB(Ham_Killed, iVctim, iAttacker, 0);

			continue;
		}

		// Turn into zombie
		zp_core_infect(iVctim, iAttacker);

		// Victim's sound
		emit_sound(iVctim, CHAN_VOICE, g_Sound_Grenade_Infect_Player[random(sizeof g_Sound_Grenade_Infect_Player)], 1.0, ATTN_NORM, 0, PITCH_NORM);
	}

	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, iEntity);
}

// Infection Bomb: Green Blast
Create_Blast(const Float:fOrigin[3])
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
	write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Small_Ring_Rendering_R)); // red
	write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Small_Ring_Rendering_G)); // green
	write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Small_Ring_Rendering_B)); // blue
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
	write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Medium_Ring_Rendering_R)); // red
	write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Medium_Ring_Rendering_G)); // green
	write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Medium_Ring_Rendering_B)); // blue
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
	write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Largest_Ring_Rendering_R)); // red
	write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Largest_Ring_Rendering_G)); // green
	write_byte(get_pcvar_num(g_pCvar_Grenade_Infection_Largest_Ring_Rendering_B)); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);
}

public client_disconnected(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
	BIT_SUB(g_iBit_Connected, iPlayer);
}

public zpe_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zpe_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}