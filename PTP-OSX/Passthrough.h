/*
 *  Passthrough.h
 *  PTP-OSX
 *
 *  Created by drake on 08/03/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>
#include "PTP.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>


PTPPassThroughPB *Passthrough_allocPTPPassthroughPB( lua_State *L );
void Passthrough_copyInboundData( lua_State *L, PTPPassThroughPB *passPb );
void Passthrough_copyOutboundData( PTPPassThroughPB *passPb, lua_State *L );
