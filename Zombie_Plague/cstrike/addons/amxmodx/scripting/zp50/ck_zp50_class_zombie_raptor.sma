/* AMX Mod X
*	[ZP] Class Zombie Raptor.
*	Author: MeRcyLeZZ. Edition: C&K Corporation.
*
*	https://ckcorp.ru/ - support from the C&K Corporation.
*	https://forum.ckcorp.ru/ - forum support from the C&K Corporation.
*	https://wiki.ckcorp.ru - documentation and other useful information.
*	https://news.ckcorp.ru/ - other info.
*
*	Support is provided only on the site.
*/

#define PLUGIN "class zombie raptor"
#define VERSION "5.1.3.0"
#define AUTHOR "C&K Corporation"

#include <amxmodx>
#include <amx_settings_api>
#include <ck_zp50_class_zombie>

#define CLASS_ZOMBIE_RAPTOR_NAME "Raptor Zombie"
#define CLASS_ZOMBIE_RAPTOR_INFO "HP-- Speed++ Knockback++"
#define CLASS_ZOMBIE_RAPTOR_HEALTH 900
#define CLASS_ZOMBIE_RAPTOR_SPEED 0.90
#define CLASS_ZOMBIE_RAPTOR_GRAVITY 1.0
#define CLASS_ZOMBIE_RAPTOR_KNOCKBACK 1.5

new const g_Class_Zombie_Raptor_Models[][] =
{
	"zombie_source"
};

new const g_Class_Zombie_Raptor_Clawmodels[][] =
{
	"models/zombie_plague/v_knife_zombie.mdl"
};

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	new iClass_Zombie_ID = zp_class_zombie_register(CLASS_ZOMBIE_RAPTOR_NAME, CLASS_ZOMBIE_RAPTOR_INFO, CLASS_ZOMBIE_RAPTOR_HEALTH, CLASS_ZOMBIE_RAPTOR_SPEED, CLASS_ZOMBIE_RAPTOR_GRAVITY);

	zp_class_zombie_register_kb(iClass_Zombie_ID, CLASS_ZOMBIE_RAPTOR_KNOCKBACK);

	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Models; i++)
	{
		zp_class_zombie_register_model(iClass_Zombie_ID, g_Class_Zombie_Raptor_Models[i]);
	}

	for (new i = 0; i < sizeof g_Class_Zombie_Raptor_Clawmodels; i++)
	{
		zp_class_zombie_register_claw(iClass_Zombie_ID, g_Class_Zombie_Raptor_Clawmodels[i]);
	}
}