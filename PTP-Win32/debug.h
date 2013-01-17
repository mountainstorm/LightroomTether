/*
 *  debug.h
 *  StudioLightroom
 *
 *  Created by drake on 17/02/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "stdio.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>



// this will do until I can botherd to write a proper one
#define debug	printf

void luaInvalidParameters( lua_State *L );
