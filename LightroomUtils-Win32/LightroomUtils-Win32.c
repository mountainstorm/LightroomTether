#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <windows.h>
#include <psapi.h>

#include "Debug.h"



static int _selectNextPhoto( lua_State *L )
{
	int retVal = 0;
	if( lua_gettop( L ) == 0 )
	{
/*		INPUT input[ 2 ] = {0};
		input[ 0 ].type = INPUT_KEYBOARD;
		input[ 0 ].ki.wVk = VK_RIGHT;
		input[ 0 ].ki.dwFlags = 0;

		input[ 1 ].type = INPUT_KEYBOARD;
		input[ 1 ].ki.wVk = VK_RIGHT;
		input[ 1 ].ki.dwFlags = KEYEVENTF_KEYUP;
		SendInput( sizeof( input ) / sizeof( input[ 0 ] ), 
				   input,
				   sizeof( INPUT ) );
*/
		keybd_event( VK_RIGHT, MapVirtualKey( LOBYTE( VkKeyScan( VK_RIGHT ) ), 0 ), 0, 0 );
		Sleep( 50 );
		keybd_event( VK_RIGHT, MapVirtualKey( LOBYTE( VkKeyScan( VK_RIGHT ) ), 0 ), 0, KEYEVENTF_KEYUP );

	} // if
	return( 0 );

} // _selectNextPhoto



static int _isRunning( lua_State *L )
{
	int retVal = 0;
	if(    ( lua_gettop( L ) == 1 )
		&& lua_isstring( L, 1 ) )
	{
		DWORD process[ 1024 ] = {0};
		DWORD noProcess = 0;

		//debug( "search for: %s\r\n", lua_tostring( L, 1 ) ); 
		if( EnumProcesses( process, sizeof( process ), &noProcess ) )
		{
			unsigned int i = 0;
			for( i = 0; i < ( noProcess / sizeof( DWORD ) ); i++ )
			{
				if( process[ i ] != 0 )
				{
					TCHAR processName[ MAX_PATH ] = TEXT( "" );
					HANDLE procHandle = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
													 FALSE, 
													 process[ i ] );
					if( procHandle != NULL )
					{
						HMODULE mod = NULL;
						DWORD needed = 0;
						if( EnumProcessModules( procHandle, &mod, sizeof( mod ), &needed ) )
						{
							GetModuleBaseName( procHandle, mod, processName, sizeof( processName )/ sizeof( TCHAR ) );

						} // if
					} // if
					CloseHandle( procHandle );
					//debug( "against: %s\r\n", processName ); 
					if( strstr( processName, lua_tostring( L, 1 ) ) != NULL )
					{
						retVal = 1;

					} // if
				} // if
			} // for

			if( i == ( noProcess / sizeof( DWORD ) ) )
			{
				retVal = 1;

			} // if
		} // if
	}
	else
	{
		debug( "invalidParameter: %u\r\n", lua_gettop( L ) );

	} // if
	lua_pushboolean( L, retVal );  
	return( 1 );

} // _isRunning



static const struct luaL_reg _funcs[] = 
{
	{ "selectNextPhoto", _selectNextPhoto },
	{ "isRunning", _isRunning },
	{ NULL, NULL }
};



__declspec( dllexport ) int luaopen_Win32( lua_State *L ) 
{
	luaL_openlib( L, "LightroomUtils", _funcs, 0 );
	debug( "LightroomUtils-Win32: initialized\r\n" );
	return( 1 );
	
} // luaopen_Win32( func )
