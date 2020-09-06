#if defined _cs_util_const_included

  #endinput

#endif

#define _cs_util_const_included

#define MODEL_MAX_LENGTH 					64
#define SOUND_MAX_LENGTH 					64
#define PLAYER_MODEL_MAX_LENGTH 			32
#define PLAYER_MODEL_PATH_MAX_LENGTH 		64
#define AMMO_NAME_MAX_LENGTH 				16

#define is_player(%0) 						(0 < (%0) <= MaxClients)

#define BIT_ADD(%0,%1)						(%0 |= (1 << (%1)))
#define BIT_SUB(%0,%1)						(%0 &= ~(1 << (%1)))
#define BIT_VALID(%0,%1)					(%0 & (1 << (%1)))
#define BIT_NOT_VALID(%0,%1)				(~(%0) & (1 << (%1)))

#define CHANCE(%0) 							(random_num(0, 99) < (%0))
#define RANDOM(%0) 							random_num(0, (%0) - 1)

#define CS_GET_CURRENT_WEAPON_ENTITY(%0)	get_member(%0, m_pActiveItem) // fm_cs_get_current_weapon_ent
#define CS_GET_WEAPON_ID(%0)				get_member(get_member(%0, m_pActiveItem), m_iId) // cs_get_weapon_id
#define CS_GET_WEAPON_ENTITY_OWNER(%0)		get_member(%0, m_pPlayer) // fm_cs_get_weapon_ent_owner
#define CS_SET_USER_NEXT_ATTACK(%0,%1)		set_member(%0, m_flNextAttack, %1) // fm_cs_set_user_next_attack
#define GET_USER_NAME(%0,%1,%2)				get_entvar(%0, var_netname, %1, %2) // get_user_name
#define CS_GET_USER_TEAM(%0)				get_member(%0, m_iTeam) // cs_get_user_team
#define CS_SET_USER_TEAM(%0,%1)				set_member(%0, m_iTeam, %1) // cs_set_user_team
#define CS_GET_USER_MONEY(%0)				get_member(%0, m_iAccount) // cs_get_user_money
#define CS_SET_USER_MONEY(%0,%1)			set_member(%0, m_iAccount, %1) // cs_set_user_money
#define GET_USER_ARMOR(%0)					get_entvar(%0, var_armorvalue) // get_user_armor
#define SET_USER_ARMOR(%0,%1)				set_entvar(%0, var_armorvalue, %1) // set_user_armor

#define CS_SET_WEAPON_AMMO(%0,%1)			set_member(%0, m_Weapon_iClip, %1) // cs_set_weapon_ammo

// fun
#define SET_USER_HEALTH(%0,%1)				set_entvar(%0, var_health, %1) // set_user_health
#define GET_USER_HEALTH(%0)					get_entvar(%0, var_health) // get_user_health
#define GET_USER_GRAVITY(%0)				get_entvar(%0, var_gravity) // get_user_gravity
#define SET_USER_GRAVITY(%0,%1)				set_entvar(%0, var_gravity, %1) // set_user_gravity

#define IS_GUN(%0) 							((1 << (%0)) & CSW_ALL_GUNS)

#define CHECK_WEAPON(%0,%1,%2,%3) 												\
	if ((%0) < (%1) || (%0) > (%2)) 											\
	{																			\
		log_error(AMX_ERR_NATIVE, "Weapon id is not valid (%d)", %0);			\
																				\
		return %3; 																\
	}

#define CHECK_ITEM(%0,%1,%2) 													\
	if ((%0) < 0 || (%0) >= (%1)) 												\
	{																			\
		log_error(AMX_ERR_NATIVE, "Item id is not valid (%d)", %0);				\
																				\
		return %2; 																\
	}

#define CHECK_GAME_MODE(%0,%1,%2) 												\
	if ((%0) < 0 || (%0) >= (%1)) 												\
	{																			\
		log_error(AMX_ERR_NATIVE, "Game mode id is not valid (%d)", %0);		\
																				\
		return %2; 																\
	}

#define CHECK_CLASS_HUMAN(%0,%1,%2) 											\
	if ((%0) < 0 || (%0) >= (%1)) 												\
	{																			\
		log_error(AMX_ERR_NATIVE, "Class id of human is not valid (%d)", %0); 	\
																				\
		return %2; 																\
	}

#define CHECK_CLASS_ZOMBIE(%0,%1,%2) 											\
	if ((%0) < 0 || (%0) >= (%1)) 												\
	{																			\
		log_error(AMX_ERR_NATIVE, "Class id of zombie is not valid (%d)", %0); 	\
																				\
		return %2; 																\
	}

#define CHECK_IS_PLAYER(%0,%1) 													\
	if (!is_player(%0)) 														\
	{ 																			\
		log_error(AMX_ERR_NATIVE, "Player id is not valid (%d)", %0); 			\
																				\
		return %1; 																\
	}

#define CHECK_IS_CONNECTED(%0,%1) 												\
	if (!is_player_connected(%0)) 												\
	{ 																			\
		log_error(AMX_ERR_NATIVE, "Player is not connected (%d)", %0); 			\
																				\
		return %1; 																\
	}

#define CHECK_IS_ALIVE(%0,%1) 													\
	if (!is_player_alive(%0)) 													\
	{ 																			\
		log_error(AMX_ERR_NATIVE, "Player is not alive (%d)", %0); 				\
																				\
		return %1; 																\
	}

#define CHECK_IS_HUMAN(%0,%1) 													\
	if (zpe_core_is_zombie(%0)) 												\
	{                                											\
		log_error(AMX_ERR_NATIVE, "Player already infected (%d)", %0); 			\
                                    											\
		return %1; 																\
	}

#define CHECK_IS_ZOMBIE(%0,%1) 													\
	if (zpe_core_is_human(%0)) 													\
	{                                											\
		log_error(AMX_ERR_NATIVE, "Player already cured (%d)", %0); 			\
                                    											\
		return %1; 																\
	}

#define CHECK_IS_NOT_SNIPER(%0,%1) 												\
	if (zpe_class_sniper_get(%0)) 												\
	{                                											\
		log_error(AMX_ERR_NATIVE, "Player already a sniper (%d)", %0); 			\
                                    											\
		return %1; 																\
	}

#define CHECK_IS_NOT_NEMESIS(%0,%1) 											\
	if (zpe_class_nemesis_get(%0)) 												\
	{                                											\
		log_error(AMX_ERR_NATIVE, "Player already a nemesis (%d)", %0); 		\
                                    											\
		return %1; 																\
	}

#define CHECK_IS_NOT_SURVIVOR(%0,%1) 											\
	if (zpe_class_survivor_get(%0)) 											\
	{                                											\
		log_error(AMX_ERR_NATIVE, "Player already a survivor (%d)", %0); 		\
                                    											\
		return %1; 																\
	}

#define CHECK_IS_NOT_ASSASSIN(%0,%1) 											\
	if (zpe_class_assassin_get(%0)) 											\
	{                                											\
		log_error(AMX_ERR_NATIVE, "Player already a assassin (%d)", %0); 		\
                                    											\
		return %1; 																\
	}

#define CHECK_MAX_SPEED(%0,%1) 													\
	if ((%0) < 0.0) 															\
	{                                											\
		log_error(AMX_ERR_NATIVE, "Max speed value is not valid (%.2f)", %0); 	\
                                    											\
		return %1; 																\
	}

#if !defined CsTeams

	enum CsTeams
	{
		CS_TEAM_UNASSIGNED = 0,
		CS_TEAM_T = 1,
		CS_TEAM_CT = 2,
		CS_TEAM_SPECTATOR = 3
	};

#endif