/*
 *  Passthrough.c
 *  PTP-OSX
 *
 *  Created by drake on 08/03/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */

#include "Passthrough.h"
#include "debug.h"


#define MAX( x, y )   ( ( x ) > ( y ) ? ( x ): ( y ) )


PTPPassThroughPB *Passthrough_allocPTPPassthroughPB( lua_State *L )
{
	PTPPassThroughPB *retVal = NULL;
	UInt32 dataInSize = 0;
	UInt32 dataOutSize = 0;
	unsigned long passPbLen = 0;
	
	lua_pushstring( L, "dataIn" );
	lua_gettable( L, -2 );
	dataInSize = lua_objlen( L, -1 );
	lua_pop( L, 1 );
	
	lua_pushstring( L, "dataOut" );
	lua_gettable( L, -2 );
	dataOutSize = lua_tonumber( L, -1 );
	lua_pop( L, 1 );

	passPbLen = sizeof( PTPPassThroughPB ) - 1 + MAX( dataInSize, dataOutSize );
	retVal = ( PTPPassThroughPB * ) malloc( passPbLen );
	if( retVal != NULL )
	{
		memset( retVal, 0, passPbLen );
		
		retVal->dataSize = MAX( dataInSize, dataOutSize );
		if(    ( dataInSize == 0 )
		    && ( dataOutSize == 0 ) )
		{
			retVal->dataUsageMode = kPTPPassThruNotUsed;
			
		}
		else if(    ( dataInSize != 0 )
				 && ( dataOutSize == 0 ) )
		{
			retVal->dataUsageMode = kPTPPassThruSend;
			
		}
		else if(    ( dataInSize == 0 ) 
				 && ( dataOutSize != 0 ) )
		{
			retVal->dataUsageMode = kPTPPassThruReceive;
			
		}
		else
		{
			debug( "unknown data mode\r\n" );
			free( retVal );
			retVal = NULL;
			
		} // if
	}
	else
	{
		debug( "unable to allocate space: %lu, for command data\r\n", passPbLen );
		
	} // if
	return( retVal );
	
} // Passthrough_allocPTPPassthroughPB



void Passthrough_copyInboundData( lua_State *L, PTPPassThroughPB *passPb )
{
	size_t i = 0;	
	lua_pushstring( L, "paramsIn" );
	lua_gettable( L, -2 );
	passPb->numOfInputParams = lua_objlen( L, -1 );
	for( i = 0; i < passPb->numOfInputParams; i++ )
	{
		lua_pushnumber( L, i + 1 );
		lua_gettable( L, -2 );
		passPb->params[ i ] = lua_tonumber( L, -1 );
		lua_pop( L, 1 );
		
	} // for
	lua_pop( L, 1 );
	
	lua_pushstring( L, "paramsOut" );
	lua_gettable( L, -2 );
	passPb->numOfOutputParams = lua_tonumber( L, -1 );
	lua_pop( L, 1 );
	
	lua_pushstring( L, "dataIn" );
	lua_gettable( L, -2 );	
	if( passPb->dataUsageMode == kPTPPassThruSend )
	{
		memcpy( passPb->data, lua_tostring( L, -1 ), lua_objlen( L, -1 ) );
		
	} // if	
	lua_pop( L, 1 );
	
} // Passthrough_copyInboundData



void Passthrough_copyOutboundData( PTPPassThroughPB *passPb, lua_State *L )
{
	size_t i = 0;
	// debug dump
/*	debug( "--dump--\r\n" );
	for( i = 0; i < passPb->dataSize; i++ )
	{
		if( passPb->data[ i ] != 0 )
		{
			debug( "%c", passPb->data[ i ] );
			
		} // if
	} // for
	debug( "\r\n--end--\r\n" );
*/	
	lua_checkstack( L, 6 );
	lua_pushstring( L, "dataOut" );
	lua_pushlstring( L,	
					( const char * ) passPb->data, 
					( passPb->dataUsageMode == kPTPPassThruReceive ) ?
						passPb->dataSize: 
						0 );
	lua_settable( L, -3 );	
	lua_pushstring( L, "paramsOut" );
	lua_newtable( L );
	for( i = 0; i < passPb->numOfOutputParams; i++ )
	{
		debug( "paramout: %x\r\n", passPb->params[ i ] );
		lua_pushnumber( L, i + 1 );
		lua_pushnumber( L, passPb->params[ i ] );
		lua_settable( L, -3 );
		
	} // for
	lua_settable( L, -3 );
	
} // Passthrough_copyOutboundData