/*
 *  LightroomUtils-OSX.c
 *  LightroomUtils-OSX
 *
 *  Created by drake on 29/10/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */

#include "debug.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>



static int _selectNextPhoto( lua_State *L )
{
	int retVal = 0;
	if( lua_gettop( L ) == 0 )
	{
		ProcessSerialNumber psn = { kNoProcess, kNoProcess };
		CGEventRef down = CGEventCreateKeyboardEvent( NULL, ( CGKeyCode ) kVK_RightArrow, true );
		if( down != NULL )
		{
			CGEventRef up = CGEventCreateKeyboardEvent( NULL, ( CGKeyCode ) kVK_RightArrow, false );
			if( up != NULL )
			{
				if( GetFrontProcess( &psn ) == noErr )
				{
					CGEventPostToPSN( &psn, down );
					CGEventPostToPSN( &psn, up );

				} // if
				CFRelease( up );
				
			} // if
			CFRelease( down );
			
		} // if
	} // if
	return( 0 );
	
} // _selectNextPhoto



static const struct luaL_reg _funcs[] = 
{
	{ "selectNextPhoto", _selectNextPhoto },
	{ NULL, NULL }
};



extern int luaopen_OSX( lua_State *L ) 
{
	luaL_openlib( L, "LightroomUtils", _funcs, 0 );
	debug( "LightroomUtils-OSX: initialized\r\n" );
	return( 1 );
	
} // luaopen_OSX( func )
