/* AMX Mod X
*	[ZP] Hud Information.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "hud information"
#define VERSION "5.2.6.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <fakemeta>
#include <cs_util>
#include <ck_zp50_kernel>
#include <ck_zp50_class_human>
#include <ck_zp50_class_zombie>
#include <ck_zp50_class_nemesis>
#include <ck_zp50_class_assassin>
#include <ck_zp50_class_survivor>
#include <ck_zp50_class_sniper>

#define LIBRARY_AMMOPACKS "ck_zp50_ammopacks"
#include <ck_zp50_ammopacks>

#define TASK_SHOWHUD 100
#define ID_SHOWHUD (iTask_ID - TASK_SHOWHUD)

#define PEV_SPEC_TARGET var_iuser2

new g_pCvar_Global_Hud_Informer;

new g_pCvar_Message_Stats_X;
new g_pCvar_Message_Stats_Y;
new g_pCvar_Message_Stats_Effects;
new g_pCvar_Message_Stats_Fxtime;
new g_pCvar_Message_Stats_Holdtime;
new g_pCvar_Message_Stats_Fadeintime;
new g_pCvar_Message_Stats_Fadeouttime;
new g_pCvar_Message_Stats_Channel;

new g_pCvar_Message_Stats_Spectator_R;
new g_pCvar_Message_Stats_Spectator_G;
new g_pCvar_Message_Stats_Spectator_B;
new g_pCvar_Message_Stats_Spectator_X;
new g_pCvar_Message_Stats_Spectator_Y;
new g_pCvar_Message_Stats_Spectator_Effects;
new g_pCvar_Message_Stats_Spectator_Fxtime;
new g_pCvar_Message_Stats_Spectator_Holdtime;
new g_pCvar_Message_Stats_Spectator_Fadeintime;
new g_pCvar_Message_Stats_Spectator_Fadeouttime;
new g_pCvar_Message_Stats_Spectator_Channel;

new g_pCvar_Message_Stats_Zombie_R;
new g_pCvar_Message_Stats_Zombie_G;
new g_pCvar_Message_Stats_Zombie_B;

new g_pCvar_Message_Stats_Human_R;
new g_pCvar_Message_Stats_Human_G;
new g_pCvar_Message_Stats_Human_B;

new g_pCvar_All_Messages_Converted;

new g_Message_Sync;

new g_iBit_Connected;
new g_iBit_Alive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Global_Hud_Informer = register_cvar("zm_global_hud_informer", "1");

	g_pCvar_Message_Stats_X = register_cvar("zm_stats_message_x", "0.02");
	g_pCvar_Message_Stats_Y = register_cvar("zm_stats_message_y", "0.9");
	g_pCvar_Message_Stats_Effects = register_cvar("zm_stats_message_effects", "0");
	g_pCvar_Message_Stats_Fxtime = register_cvar("zm_stats_message_fxtime", "6.0");
	g_pCvar_Message_Stats_Holdtime = register_cvar("zm_stats_message_holdtime", "1.1");
	g_pCvar_Message_Stats_Fadeintime = register_cvar("zm_stats_message_fadeintime", "0.0");
	g_pCvar_Message_Stats_Fadeouttime = register_cvar("zm_stats_message_fadeouttime", "0.0");
	g_pCvar_Message_Stats_Channel = register_cvar("zm_stats_message_channel", "-1");

	g_pCvar_Message_Stats_Spectator_R = register_cvar("zm_stats_spectator_message_r", "255");
	g_pCvar_Message_Stats_Spectator_G = register_cvar("zm_stats_spectator_message_g", "255");
	g_pCvar_Message_Stats_Spectator_B = register_cvar("zm_stats_spectator_message_b", "255");
	g_pCvar_Message_Stats_Spectator_X = register_cvar("zm_stats_spectator_message_x", "0.6");
	g_pCvar_Message_Stats_Spectator_Y = register_cvar("zm_stats_spectator_message_y", "0.8");
	g_pCvar_Message_Stats_Spectator_Effects = register_cvar("zm_stats_spectator_message_effects", "0");
	g_pCvar_Message_Stats_Spectator_Fxtime = register_cvar("zm_stats_spectator_message_fxtime", "6.0");
	g_pCvar_Message_Stats_Spectator_Holdtime = register_cvar("zm_stats_spectator_message_holdtime", "1.1");
	g_pCvar_Message_Stats_Spectator_Fadeintime = register_cvar("zm_stats_spectator_message_fadeintime", "0.0");
	g_pCvar_Message_Stats_Spectator_Fadeouttime = register_cvar("zm_stats_spectator_message_fadeouttime", "0.0");
	g_pCvar_Message_Stats_Spectator_Channel = register_cvar("zm_stats_spectator_message_channel", "-1");

	g_pCvar_Message_Stats_Zombie_R = register_cvar("zm_stats_zombie_message_r", "200");
	g_pCvar_Message_Stats_Zombie_G = register_cvar("zm_stats_zombie_message_g", "250");
	g_pCvar_Message_Stats_Zombie_B = register_cvar("zm_stats_zombie_message_b", "0");

	g_pCvar_Message_Stats_Human_R = register_cvar("zm_stats_human_message_r", "0");
	g_pCvar_Message_Stats_Human_G = register_cvar("zm_stats_human_message_g", "200");
	g_pCvar_Message_Stats_Human_B = register_cvar("zm_stats_human_message_b", "250");

	g_pCvar_All_Messages_Converted = register_cvar("zm_all_messages_are_converted_to_hud", "0");

	g_Message_Sync = CreateHudSyncObj();
}

public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const szModule[])
{
	if (equal(szModule, LIBRARY_AMMOPACKS))
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

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);

	// Set the custom HUD display task
	set_task(1.0, "Show_HUD", iPlayer + TASK_SHOWHUD, _, _, "b");
}

// Show HUD Task
public Show_HUD(iTask_ID)
{
	new iPlayer = ID_SHOWHUD;

	// Player dead?
	if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
	{
		// Get spectating target
		iPlayer = get_entvar(iPlayer, PEV_SPEC_TARGET);

		// Target not alive
		if (BIT_NOT_VALID(g_iBit_Alive, iPlayer))
		{
			return;
		}
	}

	// Format classname
	static szClass_Name[64];
	static szTranskey[128];

	new iRed;
	new iGreen;
	new iBlue;

	if (zp_core_is_zombie(iPlayer)) // zombies
	{
		iRed = get_pcvar_num(g_pCvar_Message_Stats_Zombie_R);
		iGreen = get_pcvar_num(g_pCvar_Message_Stats_Zombie_G);
		iBlue = get_pcvar_num(g_pCvar_Message_Stats_Zombie_B);

		// Nemesis Class loaded?
		if (zp_class_nemesis_get(iPlayer))
		{
			formatex(szClass_Name, charsmax(szClass_Name), "%L", ID_SHOWHUD, "CLASS_NEMESIS");
		}

		// Assassin Class loaded?
		else if (zp_class_assassin_get(iPlayer))
		{
			formatex(szClass_Name, charsmax(szClass_Name), "%L", ID_SHOWHUD, "CLASS_ASSASSIN");
		}

		else
		{
			zp_class_zombie_get_name(zp_class_zombie_get_current(iPlayer), szClass_Name, charsmax(szClass_Name));

			// ML support for class name
			formatex(szTranskey, charsmax(szTranskey), "ZOMBIENAME %s", szClass_Name);

			if (GetLangTransKey(szTranskey) != TransKey_Bad)
			{
				formatex(szClass_Name, charsmax(szClass_Name), "%L", ID_SHOWHUD, szTranskey);
			}
		}
	}

	else // humans
	{
		iRed = get_pcvar_num(g_pCvar_Message_Stats_Human_R);
		iGreen = get_pcvar_num(g_pCvar_Message_Stats_Human_G);
		iBlue = get_pcvar_num(g_pCvar_Message_Stats_Human_B);

		// Survivor Class loaded?
		if (zp_class_survivor_get(iPlayer))
		{
			formatex(szClass_Name, charsmax(szClass_Name), "%L", ID_SHOWHUD, "CLASS_SURVIVOR");
		}

		// Sniper Class loaded?
		else if (zp_class_sniper_get(iPlayer))
		{
			formatex(szClass_Name, charsmax(szClass_Name), "%L", ID_SHOWHUD, "CLASS_SNIPER");
		}

		else
		{
			zp_class_human_get_name(zp_class_human_get_current(iPlayer), szClass_Name, charsmax(szClass_Name));

			// ML support for class name
			formatex(szTranskey, charsmax(szTranskey), "HUMANNAME %s", szClass_Name);

			if (GetLangTransKey(szTranskey) != TransKey_Bad)
			{
				formatex(szClass_Name, charsmax(szClass_Name), "%L", ID_SHOWHUD, szTranskey);
			}
		}
	}

	// Spectating someone else?
	if (iPlayer != ID_SHOWHUD)
	{
		new szPlayer_Name[32];

		GET_USER_NAME(iPlayer, szPlayer_Name, charsmax(szPlayer_Name));

		// Show szName, health, class, and money
		if (get_pcvar_num(g_pCvar_Global_Hud_Informer) || get_pcvar_num(g_pCvar_All_Messages_Converted))
		{
			set_hudmessage
			(
				get_pcvar_num(g_pCvar_Message_Stats_Spectator_R),
				get_pcvar_num(g_pCvar_Message_Stats_Spectator_G),
				get_pcvar_num(g_pCvar_Message_Stats_Spectator_B),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_X),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Y),
				get_pcvar_num(g_pCvar_Message_Stats_Spectator_Effects),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Fxtime),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Holdtime),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Fadeouttime),
				get_pcvar_num(g_pCvar_Message_Stats_Spectator_Channel)
			);
		}

		else
		{
			set_dhudmessage
			(
				get_pcvar_num(g_pCvar_Message_Stats_Spectator_R),
				get_pcvar_num(g_pCvar_Message_Stats_Spectator_G),
				get_pcvar_num(g_pCvar_Message_Stats_Spectator_B),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_X),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Y),
				get_pcvar_num(g_pCvar_Message_Stats_Spectator_Effects),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Fxtime),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Holdtime),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Stats_Spectator_Fadeouttime)
			);
		}

		if (LibraryExists(LIBRARY_AMMOPACKS, LibType_Library))
		{
			if (get_pcvar_num(g_pCvar_Global_Hud_Informer) || get_pcvar_num(g_pCvar_All_Messages_Converted))
			{
				ShowSyncHudMsg(ID_SHOWHUD, g_Message_Sync, "%L: %s ^n HP: %d Armor: %d - %L %s - %L %d", ID_SHOWHUD, "SPECTATING", szPlayer_Name, floatround(GET_USER_HEALTH(iPlayer)), floatround(GET_USER_ARMOR(iPlayer)), ID_SHOWHUD, "CLASS_CLASS", szClass_Name, ID_SHOWHUD, "AMMO_PACKS1", zp_ammopacks_get(iPlayer));
			}

			else
			{
				show_dhudmessage(ID_SHOWHUD, "%L: %s ^n HP: %d Armor: %d - %L %s - %L %d", ID_SHOWHUD, "SPECTATING", szPlayer_Name, floatround(GET_USER_HEALTH(iPlayer)), floatround(GET_USER_ARMOR(iPlayer)), ID_SHOWHUD, "CLASS_CLASS", szClass_Name, ID_SHOWHUD, "AMMO_PACKS1", zp_ammopacks_get(iPlayer));
			}
		}

		else
		{
			if (get_pcvar_num(g_pCvar_Global_Hud_Informer) || get_pcvar_num(g_pCvar_All_Messages_Converted))
			{
				ShowSyncHudMsg(ID_SHOWHUD, g_Message_Sync, "%L: %s ^n HP: %d Armor: %d - %L %s - %L $ %d", ID_SHOWHUD, "SPECTATING", szPlayer_Name, floatround(GET_USER_HEALTH(iPlayer)), floatround(GET_USER_ARMOR(iPlayer)), ID_SHOWHUD, "CLASS_CLASS", szClass_Name, ID_SHOWHUD, "MONEY1", CS_GET_USER_MONEY(iPlayer));
			}

			else
			{
				show_dhudmessage(ID_SHOWHUD, "%L: %s ^n HP: %d Armor: %d - %L %s - %L $ %d", ID_SHOWHUD, "SPECTATING", szPlayer_Name, floatround(GET_USER_HEALTH(iPlayer)), floatround(GET_USER_ARMOR(iPlayer)), ID_SHOWHUD, "CLASS_CLASS", szClass_Name, ID_SHOWHUD, "MONEY1", CS_GET_USER_MONEY(iPlayer));
			}
		}
	}

	else
	{
		// Show health, class
		if (get_pcvar_num(g_pCvar_Global_Hud_Informer) || get_pcvar_num(g_pCvar_All_Messages_Converted))
		{
			set_hudmessage
			(
				iRed,
				iGreen,
				iBlue,
				get_pcvar_float(g_pCvar_Message_Stats_X),
				get_pcvar_float(g_pCvar_Message_Stats_Y),
				get_pcvar_num(g_pCvar_Message_Stats_Effects),
				get_pcvar_float(g_pCvar_Message_Stats_Fxtime),
				get_pcvar_float(g_pCvar_Message_Stats_Holdtime),
				get_pcvar_float(g_pCvar_Message_Stats_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Stats_Fadeouttime),
				get_pcvar_num(g_pCvar_Message_Stats_Channel)
			);
		}

		else
		{
			set_dhudmessage
			(
				iRed,
				iGreen,
				iBlue,
				get_pcvar_float(g_pCvar_Message_Stats_X),
				get_pcvar_float(g_pCvar_Message_Stats_Y),
				get_pcvar_num(g_pCvar_Message_Stats_Effects),
				get_pcvar_float(g_pCvar_Message_Stats_Fxtime),
				get_pcvar_float(g_pCvar_Message_Stats_Holdtime),
				get_pcvar_float(g_pCvar_Message_Stats_Fadeintime),
				get_pcvar_float(g_pCvar_Message_Stats_Fadeouttime)
			);
		}

		if (LibraryExists(LIBRARY_AMMOPACKS, LibType_Library))
		{
			if (get_pcvar_num(g_pCvar_Global_Hud_Informer) || get_pcvar_num(g_pCvar_All_Messages_Converted))
			{
				ShowSyncHudMsg(ID_SHOWHUD, g_Message_Sync, "HP: %d Armor: %d - %L %s - %L %d", floatround(GET_USER_HEALTH(ID_SHOWHUD)), floatround(GET_USER_ARMOR(ID_SHOWHUD)), ID_SHOWHUD, "CLASS_CLASS", szClass_Name, ID_SHOWHUD, "AMMO_PACKS1", zp_ammopacks_get(ID_SHOWHUD));
			}

			else
			{
				show_dhudmessage(ID_SHOWHUD, "HP: %d Armor: %d - %L %s - %L %d", floatround(GET_USER_HEALTH(ID_SHOWHUD)), floatround(GET_USER_ARMOR(ID_SHOWHUD)), ID_SHOWHUD, "CLASS_CLASS", szClass_Name, ID_SHOWHUD, "AMMO_PACKS1", zp_ammopacks_get(ID_SHOWHUD));
			}
		}

		else
		{
			if (get_pcvar_num(g_pCvar_Global_Hud_Informer) || get_pcvar_num(g_pCvar_All_Messages_Converted))
			{
				ShowSyncHudMsg(ID_SHOWHUD, g_Message_Sync, "HP: %d Armor: %d - %L %s", floatround(GET_USER_HEALTH(ID_SHOWHUD)), floatround(GET_USER_ARMOR(ID_SHOWHUD)), ID_SHOWHUD, "CLASS_CLASS", szClass_Name);
			}

			else
			{
				show_dhudmessage(ID_SHOWHUD, "HP: %d Armor: %d - %L %s", floatround(GET_USER_HEALTH(ID_SHOWHUD)), floatround(GET_USER_ARMOR(ID_SHOWHUD)), ID_SHOWHUD, "CLASS_CLASS", szClass_Name);
			}
		}
	}
}

public zpe_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zpe_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}

public client_disconnected(iPlayer)
{
	remove_task(iPlayer + TASK_SHOWHUD);

	BIT_SUB(g_iBit_Alive, iPlayer);
	BIT_SUB(g_iBit_Connected, iPlayer);
}