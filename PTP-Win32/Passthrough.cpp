/*
 *  Passthrough.c
 *  PTP-Win32
 *
 *  Created by drake on 04/11/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */

#include "Passthrough.h"
#include "debug.h"


int Passthrough_alloc( lua_State *L, PTP_VENDOR_DATA_IN **in, DWORD *inSize, PTP_VENDOR_DATA_OUT **out, DWORD *outSize )
{
	int retVal = 0;
	DWORD dataInSize = 0;
	DWORD dataOutSize = 0;

	lua_pushstring( L, "dataIn" );
	lua_gettable( L, -2 );
	dataInSize = lua_objlen( L, -1 );
	lua_pop( L, 1 );
	
	lua_pushstring( L, "dataOut" );
	lua_gettable( L, -2 );
	dataOutSize = (DWORD ) lua_tonumber( L, -1 );
	lua_pop( L, 1 );

	*inSize = sizeof( PTP_VENDOR_DATA_IN ) - 1 + dataInSize;
	*outSize = sizeof( PTP_VENDOR_DATA_OUT ) - 1 + dataOutSize;
	debug( "inSize: %u, outSize: %u\r\n", *inSize, *outSize );

	*in = ( PTP_VENDOR_DATA_IN * ) malloc( *inSize );
	*out = ( PTP_VENDOR_DATA_OUT * ) malloc( *outSize );
	if( ( *in != NULL ) && ( *out != NULL ) )
	{
		memset( *in, 0, *inSize );
		memset( *out, 0, *outSize );
		
		if(    ( dataInSize == 0 )
		    && ( dataOutSize == 0 ) )
		{
			( *in )->NextPhase = PTP_NEXTPHASE_NO_DATA;
			debug( "PTP_NEXTPHASE_NO_DATA\r\n" );
			retVal = 1;
			
		}
		else if(    ( dataInSize != 0 )
				 && ( dataOutSize == 0 ) )
		{
			( *in )->NextPhase = PTP_NEXTPHASE_WRITE_DATA;
			debug( "PTP_NEXTPHASE_WRITE_DATA\r\n" );
			retVal = 1;

		}
		else if(    ( dataInSize == 0 ) 
				 && ( dataOutSize != 0 ) )
		{
			( *in )->NextPhase = PTP_NEXTPHASE_READ_DATA;
			debug( "PTP_NEXTPHASE_READ_DATA\r\n" );
			retVal = 1;

		}
		else
		{
			debug( "unknown data mode\r\n" );
			
		} // if
	}
	else
	{
		debug( "unable to allocate space for command data\r\n" );

	} // if

	if( retVal == 0 )
	{
		if( *in != NULL ) 
		{
			free( *in );

		} // if

		if( *out != NULL ) 
		{
			free( *out );

		} // if
	} // if
	return( retVal );
	
} // Passthrough_alloc



void Passthrough_copyInboundData( lua_State *L, PTP_VENDOR_DATA_IN *in )
{
	size_t i = 0;	
	lua_pushstring( L, "paramsIn" );
	lua_gettable( L, -2 );
	in->NumParams = lua_objlen( L, -1 );
	for( i = 0; i < in->NumParams; i++ )
	{
		lua_pushnumber( L, i + 1 );
		lua_gettable( L, -2 );
		in->Params[ i ] = ( DWORD ) lua_tonumber( L, -1 );
		debug( "param-in: %x\r\n", in->Params[ i ] );
		lua_pop( L, 1 );
		
	} // for
	lua_pop( L, 1 );
	
	lua_pushstring( L, "dataIn" );
	lua_gettable( L, -2 );	
	if( in->NextPhase == PTP_NEXTPHASE_WRITE_DATA )
	{
		memcpy( in->VendorWriteData, lua_tostring( L, -1 ), lua_objlen( L, -1 ) );
		
	} // if	
	lua_pop( L, 1 );
	
} // Passthrough_copyInboundData



void Passthrough_copyOutboundData( PTP_VENDOR_DATA_OUT *out, DWORD outSize, lua_State *L )
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
					( const char * ) out->VendorReadData, 
					( outSize > ( sizeof( PTP_VENDOR_DATA_OUT ) - 1 ) ) ?
						outSize - ( ( sizeof( PTP_VENDOR_DATA_OUT ) - 1 ) ): 
						0 );
	lua_settable( L, -3 );	
	lua_pushstring( L, "paramsOut" );
	lua_newtable( L );
	for( i = 0; i < PTP_MAX_PARAMS; i++ )
	{
		debug( "param-out: %x\r\n", out->Params[ i ] );
		lua_pushnumber( L, i + 1 );
		lua_pushnumber( L, out->Params[ i ] );
		lua_settable( L, -3 );
		
	} // for
	lua_settable( L, -3 );
	
} // Passthrough_copyOutboundData