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