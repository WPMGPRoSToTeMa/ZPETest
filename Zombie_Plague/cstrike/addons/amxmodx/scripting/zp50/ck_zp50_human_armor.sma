/* AMX Mod X
*	[ZPE] Human Armor.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
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

#define PLUGIN "human armor"
#define VERSION "6.0.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <amx_settings_api>
#include <ck_zp50_kernel>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_assassin>
#include <ck_zp50_class_survivor>
#include <ck_zp50_class_sniper>

#define ZPE_SETTINGS_FILE "ZPE/zpe_settings.ini"

// Some constants
#define DMG_HEGRENADE (1 << 24)

#define SOUND_MAX_LENGTH 64

new const g_Sound_Armor_Hit[][] =
{
	"player/bhit_helmet-1.wav"
};

new Array:g_aSound_Armor_Hit;

new g_pCvar_Human_Armor_Protect;
new g_pCvar_Human_Armor_Default;

new g_pCvar_Armor_Protect_Nemesis;
new g_pCvar_Armor_Protect_Assassin;
new g_pCvar_Armor_Protect_Survivor;
new g_pCvar_Armor_Protect_Sniper;

new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Human_Armor_Protect = register_cvar("zpe_human_armor_protect", "1");
	g_pCvar_Human_Armor_Default = register_cvar("zpe_human_armor_default", "0");

	g_pCvar_Armor_Protect_Nemesis = register_cvar("zpe_armor_protect_nemesis", "1");
	g_pCvar_Armor_Protect_Assassin = register_cvar("zpe_armor_protect_assassin", "1");
	g_pCvar_Armor_Protect_Survivor = register_cvar("zpe_armor_protect_survivor", "1");
	g_pCvar_Armor_Protect_Sniper = register_cvar("zpe_armor_protect_sniper", "1")

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_");
}

public plugin_precache()
{
	// Initialize arrays
	g_aSound_Armor_Hit = ArrayCreate(SOUND_MAX_LENGTH, 1);

	// Load from external file
	amx_load_setting_string_arr(ZPE_SETTINGS_FILE, "Sounds", "ADD ARMOR", g_aSound_Armor_Hit);

	for (new i = 0; i < sizeof g_Sound_Armor_Hit; i++)
	{
		precache_sound(g_Sound_Armor_Hit[i]);
	}
}

public zp_fw_core_cure_post(iPlayer)
{
	new Float:fArmor;

	fArmor = GET_USER_ARMOR(iPlayer);

	if (fArmor < get_pcvar_num(g_pCvar_Human_Armor_Default))
	{
		SET_USER_ARMOR(iPlayer, get_pcvar_num(g_pCvar_Human_Armor_Default));
	}
}

// ReAPI Take Damage Forward
public RG_CBasePlayer_TakeDamage_(iVictim, iInflictor, iAttacker, Float:fDamage, iDamage_Type)
{
	// Non-player damage or self damage
	if (iVictim == iAttacker || BIT_NOT_VALID(g_iBit_Alive, iAttacker))
	{
		return HC_CONTINUE;
	}

	// Zombie attacking human...
	if (zp_core_is_zombie(iAttacker) && !zp_core_is_zombie(iVictim))
	{
		// Ignore damage coming from a HE grenade (bugfix)
		if (iDamage_Type & DMG_HEGRENADE)
		{
			return HC_CONTINUE;
		}

		// Does human armor need to be reduced before infecting/damaging?
		if (!get_pcvar_num(g_pCvar_Human_Armor_Protect))
		{
			return HC_CONTINUE;
		}

		// Should armor protect against nemesis attacks?
		if (!get_pcvar_num(g_pCvar_Armor_Protect_Nemesis) && zp_class_nemesis_get(iAttacker))
		{
			return HC_CONTINUE;
		}

		// Should armor protect against assassin attacks?
		if (!get_pcvar_num(g_pCvar_Armor_Protect_Assassin) && zp_class_assassin_get(iAttacker))
		{
			return HC_CONTINUE;
		}

		// Should armor protect survivor too?
		if (!get_pcvar_num(g_pCvar_Armor_Protect_Survivor) && zp_class_survivor_get(iVictim))
		{
			return HC_CONTINUE;
		}

		// Should armor protect sniper too?
		if (!get_pcvar_num(g_pCvar_Armor_Protect_Sniper) && zp_class_sniper_get(iVictim))
		{
			return HC_CONTINUE;
		}

		// Get victim armor
		static Float:fArmor;

		fArmor = GET_USER_ARMOR(iVictim);

		// If he has some, block damage and reduce armor instead
		if (fArmor > 0.0)
		{
			emit_sound(iVictim, CHAN_BODY, g_Sound_Armor_Hit[random(sizeof g_Sound_Armor_Hit)], 1.0, ATTN_NORM, 0, PITCH_NORM);

			if (fArmor - fDamage > 0.0)
			{
				SET_USER_ARMOR(iVictim, fArmor - fDamage);
			}

			else
			{
				rg_set_user_armor(iVictim, 0, ARMOR_NONE);
			}

			// Block damage, but still set the pain shock offset
			set_member(iVictim, m_flVelocityModifier, 0.5); // OFFSET_PAINSHOCK

			return HC_SUPERCEDE;
		}
	}

	return HC_CONTINUE;
}

public client_disconnected(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zpe_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zpe_fw_spawn_post_bit_add(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}