#if defined _ck_cs_using_buttons_api_included

  #endinput

#endif

#define _ck_cs_using_buttons_api_included

/**
 * Called when player press or unpress button
 *
 *
 * @param player					Player index.
 * @param pressed					pressed button bitsum.
 * @param unpressed					unpressed button bitsum.
 */

forward fw_button_changed(player, pressed, unpressed)