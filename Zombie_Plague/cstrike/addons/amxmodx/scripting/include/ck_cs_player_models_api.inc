#if defined _ck_cs_player_models_api_included

  #endinput

#endif

#define _ck_cs_player_models_api_included

/**
 * Sets a custom player model.
 *
 * @param id			Player index.
 * @param model			Custom model's short name.
 */
native cs_set_player_model(id, const model[])

/**
 * Restores CS default model for player.
 *
 * @param id		Player index.
 */
native cs_reset_player_model(id)