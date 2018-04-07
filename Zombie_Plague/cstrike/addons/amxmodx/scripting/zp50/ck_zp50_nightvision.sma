/* AMX Mod X
*	[ZP] Night_Vision.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*	This enterprise software. Please, buy plugin: https://news.ckcorp.ru/zp/75-zombie-plague-next.html / http://news.ckcorp.ru/24-contacts.html
*
*	http://ckcorp.ru/ - support from the C&K Corporation.
*
*	Support is provided only on the site.
*/

#define PLUGIN "nightvision"
#define VERSION "5.2.8.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <cs_util>
#include <cstrike>
#include <ck_zp50_kernel>

#define LIBRARY_NEMESIS "ck_zp50_class_nemesis"
#include <ck_zp50_class_nemesis>

#define LIBRARY_ASSASSIN "ck_zp50_class_assassin"
#include <ck_zp50_class_assassin>

#define LIBRARY_SURVIVOR "ck_zp50_class_survivor"
#include <ck_zp50_class_survivor>

#define LIBRARY_SNIPER "ck_zp50_class_sniper"
#include <ck_zp50_class_sniper>

#define TASK_NIGHTVISION 100
#define ID_NIGHTVISION (iTask_ID - TASK_NIGHTVISION)

new g_Night_Vision_Active;

new g_Message_NVG_Toggle;

new g_pCvar_Night_Vision_Custom;

new g_pCvar_Night_Vision_Zombie;
new g_pCvar_Night_Vision_Zombie_Radius;
new g_pCvar_Night_Vision_Zombie_Color_R;
new g_pCvar_Night_Vision_Zombie_Color_G;
new g_pCvar_Night_Vision_Zombie_Color_B;

new g_pCvar_Night_Vision_Human;
new g_pCvar_Night_Vision_Human_Radius;
new g_pCvar_Night_Vision_Human_Color_R;
new g_pCvar_Night_Vision_Human_Color_G;
new g_pCvar_Night_Vision_Human_Color_B;

new g_pCvar_Night_Vision_Spectator;
new g_pCvar_Night_Vision_Spectator_Radius;
new g_pCvar_Night_Vision_Spectator_Color_R;
new g_pCvar_Night_Vision_Spectator_Color_G;
new g_pCvar_Night_Vision_Spectator_Color_B;

new g_pCvar_Night_Vision_Nemesis;
new g_pCvar_Night_Vision_Nemesis_Radius;
new g_pCvar_Night_Vision_Nemesis_Color_R;
new g_pCvar_Night_Vision_Nemesis_Color_G;
new g_pCvar_Night_Vision_Nemesis_Color_B;

new g_pCvar_Night_Vision_Assassin;
new g_pCvar_Night_Vision_Assassin_Radius;
new g_pCvar_Night_Vision_Assassin_Color_R;
new g_pCvar_Night_Vision_Assassin_Color_G;
new g_pCvar_Night_Vision_Assassin_Color_B;

new g_pCvar_Night_Vision_Survivor;
new g_pCvar_Night_Vision_Survivor_Radius;
new g_pCvar_Night_Vision_Survivor_Color_R;
new g_pCvar_Night_Vision_Survivor_Color_G;
new g_pCvar_Night_Vision_Survivor_Color_B;

new g_pCvar_Night_Vision_Sniper;
new g_pCvar_Night_Vision_Sniper_Radius;
new g_pCvar_Night_Vision_Sniper_Color_R;
new g_pCvar_Night_Vision_Sniper_Color_G;
new g_pCvar_Night_Vision_Sniper_Color_B;

new g_iBit_Alive;
new g_iBit_Connected;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvar_Night_Vision_Custom = register_cvar("zm_night_vision_custom", "0");

	g_pCvar_Night_Vision_Zombie = register_cvar("zm_night_vision_zombie", "2"); // 1-give only // 2-give and enable
	g_pCvar_Night_Vision_Zombie_Radius = register_cvar("zm_night_vision_radius_zombie", "80");
	g_pCvar_Night_Vision_Zombie_Color_R = register_cvar("zm_night_vision_zombie_color_R", "0");
	g_pCvar_Night_Vision_Zombie_Color_G = register_cvar("zm_night_vision_zombie_color_G", "150");
	g_pCvar_Night_Vision_Zombie_Color_B = register_cvar("zm_night_vision_zombie_color_B", "0");

	g_pCvar_Night_Vision_Human = register_cvar("zm_night_vision_human", "0"); // 1-give only // 2-give and enable
	g_pCvar_Night_Vision_Human_Radius = register_cvar("zm_night_vision_radius_human", "80");
	g_pCvar_Night_Vision_Human_Color_R = register_cvar("zm_night_vision_human_color_R", "0");
	g_pCvar_Night_Vision_Human_Color_G = register_cvar("zm_night_vision_human_color_G", "150");
	g_pCvar_Night_Vision_Human_Color_B = register_cvar("zm_night_vision_human_color_B", "0");

	g_pCvar_Night_Vision_Spectator = register_cvar("zm_night_vision_spectator", "2"); // 1-give only // 2-give and enable
	g_pCvar_Night_Vision_Spectator_Radius = register_cvar("zm_night_vision_radius_spectator", "80");
	g_pCvar_Night_Vision_Spectator_Color_R = register_cvar("zm_night_vision_spec_color_R", "0");
	g_pCvar_Night_Vision_Spectator_Color_G = register_cvar("zm_night_vision_spec_color_G", "150");
	g_pCvar_Night_Vision_Spectator_Color_B = register_cvar("zm_night_vision_spec_color_B", "0");

	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library))
	{
		g_pCvar_Night_Vision_Nemesis = register_cvar("zm_night_vision_nemesis", "2");
		g_pCvar_Night_Vision_Nemesis_Radius = register_cvar("zm_night_vision_radius_nemesis", "80");
		g_pCvar_Night_Vision_Nemesis_Color_R = register_cvar("zm_night_vision_nemesis_color_R", "150");
		g_pCvar_Night_Vision_Nemesis_Color_G = register_cvar("zm_night_vision_nemesis_color_G", "0");
		g_pCvar_Night_Vision_Nemesis_Color_B = register_cvar("zm_night_vision_nemesis_color_B", "0");
	}

	// Assassin Class loaded?
	if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library))
	{
		g_pCvar_Night_Vision_Assassin = register_cvar("zm_night_vision_assassin", "2");
		g_pCvar_Night_Vision_Assassin_Radius = register_cvar("zm_night_vision_radius_assassin", "80");
		g_pCvar_Night_Vision_Assassin_Color_R = register_cvar("zm_night_vision_assassin_color_R", "150");
		g_pCvar_Night_Vision_Assassin_Color_G = register_cvar("zm_night_vision_assassin_color_G", "0");
		g_pCvar_Night_Vision_Assassin_Color_B = register_cvar("zm_night_vision_assassin_color_B", "0");
	}

	// Survivor Class loaded?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library))
	{
		g_pCvar_Night_Vision_Survivor = register_cvar("zm_night_vision_survivor", "0");
		g_pCvar_Night_Vision_Survivor_Radius = register_cvar("zm_night_vision_radius_survivor", "80");
		g_pCvar_Night_Vision_Survivor_Color_R = register_cvar("zm_night_vision_survivor_color_R", "0");
		g_pCvar_Night_Vision_Survivor_Color_G = register_cvar("zm_night_vision_survivor_color_G", "0");
		g_pCvar_Night_Vision_Survivor_Color_B = register_cvar("zm_night_vision_survivor_color_B", "150");
	}

	// Sniper Class loaded?
	if (LibraryExists(LIBRARY_SNIPER, LibType_Library))
	{
		g_pCvar_Night_Vision_Sniper = register_cvar("zm_night_vision_sniper", "0");
		g_pCvar_Night_Vision_Sniper_Radius = register_cvar("zm_night_vision_radius_sniper", "80");
		g_pCvar_Night_Vision_Sniper_Color_R = register_cvar("zm_night_vision_sniper_color_R", "0");
		g_pCvar_Night_Vision_Sniper_Color_G = register_cvar("zm_night_vision_sniper_color_G", "0");
		g_pCvar_Night_Vision_Sniper_Color_B = register_cvar("zm_night_vision_sniper_color_B", "150");
	}

	g_Message_NVG_Toggle = get_user_msgid("NVGToggle");

	register_message(g_Message_NVG_Toggle, "Message_NVG_Toggle");

	register_clcmd("nightvision", "Client_Command_NVG_Toggle");

	register_event("ResetHUD", "Event_Reset_Hud", "b");

	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_Post", 1);
}

public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");
}

public module_filter(const module[])
{
	if (equal(module, LIBRARY_NEMESIS) || equal(module, LIBRARY_ASSASSIN) || equal(module, LIBRARY_SURVIVOR) || equal(module, LIBRARY_SNIPER))
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

public RG_CSGameRules_PlayerKilled_Post(iPlayer)
{
	Spectator_Night_Vision(iPlayer);
}

public client_putinserver(iPlayer)
{
	BIT_ADD(g_iBit_Connected, iPlayer);

	set_task(0.1, "Spectator_Night_Vision", iPlayer);
}

public zp_fw_core_infect_post(iPlayer)
{
	// Nemesis Class loaded?
	if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(iPlayer))
	{
		if (get_pcvar_num(g_pCvar_Night_Vision_Nemesis))
		{
			if (!cs_get_user_nvg(iPlayer))
			{
				cs_set_user_nvg(iPlayer, 1);
			}

			if (get_pcvar_num(g_pCvar_Night_Vision_Nemesis) == 2)
			{
				if (BIT_NOT_VALID(g_Night_Vision_Active, iPlayer))
				{
					Client_Command_NVG_Toggle(iPlayer);
				}
			}

			else if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Client_Command_NVG_Toggle(iPlayer);
			}
		}

		else
		{
			cs_set_user_nvg(iPlayer, 0);

			if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Disable_Night_Vision(iPlayer);
			}
		}
	}

	// Assassin Class loaded?
	else if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(iPlayer))
	{
		if (get_pcvar_num(g_pCvar_Night_Vision_Assassin))
		{
			if (!cs_get_user_nvg(iPlayer))
			{
				cs_set_user_nvg(iPlayer, 1);
			}

			if (get_pcvar_num(g_pCvar_Night_Vision_Assassin) == 2)
			{
				if (BIT_NOT_VALID(g_Night_Vision_Active, iPlayer))
				{
					Client_Command_NVG_Toggle(iPlayer);
				}
			}

			else if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Client_Command_NVG_Toggle(iPlayer);
			}
		}

		else
		{
			cs_set_user_nvg(iPlayer, 0);

			if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Disable_Night_Vision(iPlayer);
			}
		}
	}

	else
	{
		if (get_pcvar_num(g_pCvar_Night_Vision_Zombie))
		{
			if (!cs_get_user_nvg(iPlayer))
			{
				cs_set_user_nvg(iPlayer, 1);
			}

			if (get_pcvar_num(g_pCvar_Night_Vision_Zombie) == 2)
			{
				if (BIT_NOT_VALID(g_Night_Vision_Active, iPlayer))
				{
					Client_Command_NVG_Toggle(iPlayer);
				}
			}

			else if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Client_Command_NVG_Toggle(iPlayer);
			}
		}

		else
		{
			cs_set_user_nvg(iPlayer, 0);

			if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Disable_Night_Vision(iPlayer);
			}
		}
	}
}

public zp_fw_core_cure_post(iPlayer)
{
	// Survivor Class loaded?
	if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(iPlayer))
	{
		if (get_pcvar_num(g_pCvar_Night_Vision_Survivor))
		{
			if (!cs_get_user_nvg(iPlayer))
			{
				cs_set_user_nvg(iPlayer, 1);
			}

			if (get_pcvar_num(g_pCvar_Night_Vision_Survivor) == 2)
			{
				if (BIT_NOT_VALID(g_Night_Vision_Active, iPlayer))
				{
					Client_Command_NVG_Toggle(iPlayer);
				}

				else if (BIT_VALID(g_Night_Vision_Active, iPlayer))
				{
					Client_Command_NVG_Toggle(iPlayer);
				}
			}

			else
			{
				cs_set_user_nvg(iPlayer, 0);

				if (BIT_VALID(g_Night_Vision_Active, iPlayer))
				{
					Disable_Night_Vision(iPlayer);
				}
			}
		}
	}

	// Sniper Class loaded?
	else if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(iPlayer))
	{
		if (get_pcvar_num(g_pCvar_Night_Vision_Sniper))
		{
			if (!cs_get_user_nvg(iPlayer))
			{
				cs_set_user_nvg(iPlayer, 1);
			}

			if (get_pcvar_num(g_pCvar_Night_Vision_Sniper) == 2)
			{
				if (BIT_NOT_VALID(g_Night_Vision_Active, iPlayer))
				{
					Client_Command_NVG_Toggle(iPlayer);
				}
			}

			else if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Client_Command_NVG_Toggle(iPlayer);
			}
		}

		else
		{
			cs_set_user_nvg(iPlayer, 0);

			if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Disable_Night_Vision(iPlayer);
			}
		}
	}

	else
	{
		if (get_pcvar_num(g_pCvar_Night_Vision_Human))
		{
			if (!cs_get_user_nvg(iPlayer))
			{
				cs_set_user_nvg(iPlayer, 1);
			}

			if (get_pcvar_num(g_pCvar_Night_Vision_Human) == 2)
			{
				if (BIT_NOT_VALID(g_Night_Vision_Active, iPlayer))
				{
					Client_Command_NVG_Toggle(iPlayer);
				}
			}

			else if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Client_Command_NVG_Toggle(iPlayer);
			}
		}

		else
		{
			cs_set_user_nvg(iPlayer, 0);

			if (BIT_VALID(g_Night_Vision_Active, iPlayer))
			{
				Disable_Night_Vision(iPlayer);
			}
		}
	}
}

public Client_Command_NVG_Toggle(iPlayer)
{
	if (BIT_VALID(g_iBit_Alive, iPlayer))
	{
		// Player owns nightvision?
		if (!cs_get_user_nvg(iPlayer))
		{
			return PLUGIN_CONTINUE;
		}
	}

	else
	{
		// Spectator nightvision disabled?
		if (!get_pcvar_num(g_pCvar_Night_Vision_Spectator))
		{
			return PLUGIN_CONTINUE;
		}
	}

	if (BIT_VALID(g_Night_Vision_Active, iPlayer))
	{
		Disable_Night_Vision(iPlayer);
	}

	else
	{
		Enable_Night_Vision(iPlayer);
	}

	return PLUGIN_HANDLED;
}

// ResetHUD Removes CS Night_Vision (bugfix)
public Event_Reset_Hud(iPlayer)
{
	if (!get_pcvar_num(g_pCvar_Night_Vision_Custom) && BIT_VALID(g_Night_Vision_Active, iPlayer))
	{
		cs_set_user_nvg_active(iPlayer, 1);
	}
}

public Spectator_Night_Vision(iEntity)
{
	if (BIT_NOT_VALID(g_iBit_Connected, iEntity))
	{
		return;
	}

	if (BIT_VALID(g_iBit_Alive, iEntity))
	{
		return;
	}

	if (get_pcvar_num(g_pCvar_Night_Vision_Spectator) == 2)
	{
		if (BIT_NOT_VALID(g_Night_Vision_Active, iEntity))
		{
			Client_Command_NVG_Toggle(iEntity);
		}
	}

	else if (BIT_VALID(g_Night_Vision_Active, iEntity))
	{
		Disable_Night_Vision(iEntity);
	}
}

// Prevent spectators' nightvision from being turned off when switching targets, etc.
public Message_NVG_Toggle()
{
	return PLUGIN_HANDLED;
}

// Custom Night Vision Task
public Custom_Night_Vision_Task(iTask_ID)
{
	// Get player's origin
	static iOrigin[3];

	get_user_origin(ID_NIGHTVISION, iOrigin);

	// Night_Vision message
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_NIGHTVISION);
	write_byte(TE_DLIGHT); // TE player
	write_coord(iOrigin[0]); // x
	write_coord(iOrigin[1]); // y
	write_coord(iOrigin[2]); // z

	// Spectator
	if (BIT_NOT_VALID(g_iBit_Alive, ID_NIGHTVISION))
	{
		write_byte(get_pcvar_num(g_pCvar_Night_Vision_Spectator_Radius)); // radius

		write_byte(get_pcvar_num(g_pCvar_Night_Vision_Spectator_Color_R)); // r
		write_byte(get_pcvar_num(g_pCvar_Night_Vision_Spectator_Color_G)); // g
		write_byte(get_pcvar_num(g_pCvar_Night_Vision_Spectator_Color_B)); // b
	}

	// Zombie
	else if (zp_core_is_zombie(ID_NIGHTVISION))
	{
		// Nemesis Class loaded?
		if (LibraryExists(LIBRARY_NEMESIS, LibType_Library) && zp_class_nemesis_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Nemesis_Radius)); // radius

			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Nemesis_Color_R)); // r
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Nemesis_Color_G)); // g
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Nemesis_Color_B)); // b
		}

		else if (LibraryExists(LIBRARY_ASSASSIN, LibType_Library) && zp_class_assassin_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Assassin_Radius)); // radius

			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Assassin_Color_R)); // r
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Assassin_Color_G)); // g
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Assassin_Color_B)); // b
		}

		else
		{
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Zombie_Radius)); // radius

			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Zombie_Color_R)); // r
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Zombie_Color_G)); // g
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Zombie_Color_B)); // b
		}
	}

	// Human
	else
	{
		// Survivor Class loaded?
		if (LibraryExists(LIBRARY_SURVIVOR, LibType_Library) && zp_class_survivor_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Survivor_Radius)); // radius

			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Survivor_Color_R)); // r
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Survivor_Color_G)); // g
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Survivor_Color_B)); // b
		}

		else if (LibraryExists(LIBRARY_SNIPER, LibType_Library) && zp_class_sniper_get(ID_NIGHTVISION))
		{
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Sniper_Radius)); // radius

			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Sniper_Color_R)); // r
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Sniper_Color_G)); // g
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Sniper_Color_B)); // b
		}

		else
		{
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Human_Radius)); // radius

			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Human_Color_R)); // r
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Human_Color_G)); // g
			write_byte(get_pcvar_num(g_pCvar_Night_Vision_Human_Color_B)); // b
		}
	}

	write_byte(2); // life
	write_byte(0); // decay rate
	message_end();
}

public client_disconnected(iPlayer)
{
	// Reset nightvision flags
	BIT_SUB(g_Night_Vision_Active, iPlayer);

	BIT_SUB(g_iBit_Alive, iPlayer);
	BIT_SUB(g_iBit_Connected, iPlayer);
	
	remove_task(iPlayer + TASK_NIGHTVISION);
}

public zp_fw_kill_pre_bit_sub(iPlayer)
{
	BIT_SUB(g_iBit_Alive, iPlayer);
}

public zp_fw_spawn_post_add_bit(iPlayer)
{
	BIT_ADD(g_iBit_Alive, iPlayer);
}

Enable_Night_Vision(iPlayer)
{
	BIT_ADD(g_Night_Vision_Active, iPlayer);

	if (!get_pcvar_num(g_pCvar_Night_Vision_Custom))
	{
		cs_set_user_nvg_active(iPlayer, 1);
	}

	else
	{
		set_task(0.1, "Custom_Night_Vision_Task", iPlayer + TASK_NIGHTVISION, _, _, "b");
	}
}

Disable_Night_Vision(iPlayer)
{
	BIT_SUB(g_Night_Vision_Active, iPlayer);

	if (!get_pcvar_num(g_pCvar_Night_Vision_Custom))
	{
		cs_set_user_nvg_active(iPlayer, 0);
	}

	else
	{
		remove_task(iPlayer + TASK_NIGHTVISION);
	}
}

stock cs_set_user_nvg_active(iPlayer, iActive)
{
	// Toggle NVG message
	message_begin(MSG_ONE, g_Message_NVG_Toggle, _, iPlayer);
	write_byte(iActive); // toggle
	message_end();
}