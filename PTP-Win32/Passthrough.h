/*
 *  Passthrough.h
 *  PTP-Win32
 *
 *  Created by drake on 04/11/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */

#include "PTP-Win32.h"

extern "C"
{
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}


int Passthrough_alloc( lua_State *L, PTP_VENDOR_DATA_IN **in, DWORD *inSize, PTP_VENDOR_DATA_OUT **out, DWORD *outSize );
void Passthrough_copyInboundData( lua_State *L, PTP_VENDOR_DATA_IN *in );
void Passthrough_copyOutboundData( PTP_VENDOR_DATA_OUT *out, DWORD outSize, lua_State *L );
