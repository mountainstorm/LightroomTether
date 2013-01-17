/*
 *  debug.c
 *  StudioLightroom
 *
 *  Created by drake on 17/02/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "debug.h"



void luaInvalidParameters( lua_State *L )
{
	unsigned int i = 0;
	debug( "invalid parameters: %u\r\n", lua_gettop( L ) );
	for( i = 0; i < lua_gettop( L ); i++ )
	{
		debug( "  [%u] %s\r\n", i + 1, lua_typename( L, lua_type( L, i + 1 ) ) );
		
	} // for
} // luaInvalidParameters
