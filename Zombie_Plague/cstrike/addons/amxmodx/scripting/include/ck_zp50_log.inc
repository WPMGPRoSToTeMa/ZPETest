/*
* 	This is used to log ZP-specific information/errors into a
* 	location where it is separate from other messages.
*/

stock zp_log(const szMessage_Format[], any:...)
{
	static szMessage[256];
	static szFilename[32];
	static szDate[16];
	
	vformat(szMessage, charsmax(szMessage), szMessage_Format, 2);
	
	format_time(szDate, charsmax(szDate), "%Y%m%d");
	
	formatex(szFilename, charsmax(szFilename), "ZombiePlague_%s.log", szDate);
	
	log_to_file(szFilename, "%s", szMessage);
}

stock zp_error_log(const szMessage_Format[], any:...)
{
	static szMessage[256];
	static szFilename[32];
	static szDate[16];
	
	new szName[32];
	new szPluginName[32];
	new szVersion[32];
	new szAuthor[32];
	new szStatus[32]
	
	vformat(szMessage, charsmax(szMessage), szMessage_Format, 2);
	
	format_time(szDate, charsmax(szDate), "%Y%m%d");
	
	formatex(szFilename, charsmax(szFilename), "Error_ZombiePlague_%s.log", szDate);
	
	get_plugin(-1, szPluginName, 31, szName, 31, szVersion, 31, szAuthor, 31, szStatus, 31);
	
	log_to_file(szFilename, "^nPlugin: %s ^nPlugin version: %s ^nError info: %s ^n", szPluginName, szVersion, szMessage);
}