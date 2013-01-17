/*
 *  PTP-Win32.cpp
 *  StudioLightroom
 *
 *  Created by drake on 04/11/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */

#include "PTP-Win32.h"
#include "Passthrough.h"

#include <windows.h>
#include <wia.h>


extern "C"
{
#include "debug.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}


#define kEventTypeNone		0
#define kEventTypeCustom	1
#define kEventTypePTP		2

#define kCustomEventAdded 	0
#define kCustomEventRemoved 1


static int _shutdown( lua_State *L );


IWiaDevMgr *g_WiaDevMgr = NULL;

IUnknown *g_deviceAdded = NULL;
IUnknown *g_deviceRemoved = NULL;
IUnknown *g_itemAdded = NULL;

lua_State *g_callbackThread = NULL;



class EventCallbacks : public IWiaEventCallback
{
	// IUnknown methods
	STDMETHOD( QueryInterface( REFIID riid, void **ppvObject ) )
	{
		if( riid == IID_IWiaEventCallback )
		{
			*ppvObject = ( void * ) this;
			return( S_OK );

		} // if

		if( riid == IID_IUnknown )
		{
			*ppvObject = ( void * ) this;
			return( S_OK );

		} // if
		return( E_NOINTERFACE );

	} // QueryInterface

	STDMETHOD_( ULONG, AddRef( void ) )
	{
		return( 1 );

	} // AddRef

	STDMETHOD_( ULONG, Release( void ) )
	{
		return( 1 );

	} // Release

	// IWiaEventCallback methods
	STDMETHOD( ImageEventCallback( const GUID *pEventGUID,
								   BSTR bstrEventDescription,
								   BSTR bstrDeviceID,
								   BSTR bstrDeviceDescription,
								   DWORD dwDeviceType,
								   BSTR bstrFullItemName,
								   ULONG *pulEventType,
								   ULONG ulReserved ) )
	{
		HRESULT retVal = S_FALSE;
		lua_State *L = g_callbackThread;
		unsigned int eventType = kEventTypeNone;

		lua_pushvalue( L, -1 ); // copy the function object so we can be called multiple times
		lua_createtable( L, 0, 3 );
		lua_pushstring( L, "object" );
		lua_pushlstring( L, ( char * ) bstrDeviceID, ( lstrlen( bstrDeviceID ) + 1 ) * sizeof( WCHAR ) );
		lua_settable( L, -3 );
		if( memcmp( pEventGUID, &WIA_EVENT_DEVICE_CONNECTED, sizeof( GUID ) ) == 0 )
		{
            debug( "WIA_DIP_DEV_ID: %ws\n", bstrDeviceID );
			lua_pushstring( L, "event" );
			lua_pushnumber( L, kCustomEventAdded );
			lua_settable( L, -3 );
			eventType = kEventTypeCustom;
			retVal = S_OK;
		}
		else
		if( memcmp( pEventGUID, &WIA_EVENT_DEVICE_DISCONNECTED, sizeof( GUID ) ) == 0 )
		{
            debug( "WIA_DIP_DEV_ID: %ws\n", bstrDeviceID );
			lua_pushstring( L, "event" );
			lua_pushnumber( L, kCustomEventRemoved );
			lua_settable( L, -3 );	
			eventType = kEventTypeCustom;
			retVal = S_OK;
		}
		else
		if( memcmp( pEventGUID, &WIA_EVENT_ITEM_CREATED, sizeof( GUID ) ) == 0 )
		{
			debug( "bstrEventDescription:  %ws\r\n", bstrEventDescription );
			debug( "bstrDeviceID:          %ws\r\n", bstrDeviceID );
			debug( "bstrDeviceDescription: %ws\r\n", bstrDeviceDescription );
			debug( "dwDeviceType:          %ws\r\n", dwDeviceType );
			debug( "bstrFullItemName:      %ws\r\n", bstrFullItemName ); // the item added
			// we can't easily get the objects ObjectHandle - so we'll return an event but with the object set to nil
			// we can then do the clever stuff in Lua.  We'll store a constant list of ObjectHandles and generate 
			// and event for any new ObjectHandles
			lua_pushstring( L, "event" );
			lua_pushnumber( L, 0x4002 );
			lua_settable( L, -3 );	
			eventType = kEventTypePTP;

		} // if
		lua_pushstring( L, "eventType" );
		lua_pushnumber( L, eventType );
		lua_settable( L, -3 );	
		
		// call the callback function with the table
		lua_call( L, 1, 0 );	
		lua_pop( L, lua_gettop( L ) - 1 ); // dump everything else on the stack except the function call
		return( retVal );

	} // ImageEventCallback

}; // EventCallbacks( class )


EventCallbacks g_event;


static int _init( lua_State *L )
{
	int retVal = 0;
	if(    ( lua_gettop( L ) == 1 ) 
	    && lua_isfunction( L, -1 ) )
	{
		debug( "$$$$$$$$$$$$$: _init\r\n" );
	
		CoInitialize( NULL );
		HRESULT hr = CoCreateInstance( CLSID_WiaDevMgr, NULL, CLSCTX_LOCAL_SERVER, IID_IWiaDevMgr, ( void ** ) &g_WiaDevMgr );
		if( SUCCEEDED( hr ) )
		{
			// all the notifications we can register for
			debug( "mgrHandle: %x\r\n", g_WiaDevMgr );

			g_callbackThread = lua_newthread( L );
			if( g_callbackThread != NULL )
			{
				lua_setglobal( L, "_PTPNativeCallbackThread" ); // store it so the GC doesn't discard it
				lua_xmove( L, g_callbackThread, 1 ); // copy the function call onto the stack
			
				if(    SUCCEEDED( g_WiaDevMgr->RegisterEventCallbackInterface( 0, 
																			   NULL, 
																			   &WIA_EVENT_DEVICE_CONNECTED, 
																			   &g_event, 
																			   &g_deviceAdded ) ) 
					&& SUCCEEDED( g_WiaDevMgr->RegisterEventCallbackInterface( 0, 
																			   NULL, 
																			   &WIA_EVENT_DEVICE_DISCONNECTED, 
																			   &g_event, 
																			   &g_deviceRemoved ) )
					&& SUCCEEDED( g_WiaDevMgr->RegisterEventCallbackInterface( 0, 
																			   NULL, 
																			   &WIA_EVENT_ITEM_CREATED, 
																			   &g_event, 
																			   &g_itemAdded ) ) )
				{
					retVal = 1;
				
				} // if
			} // if
		}
		else
		{
			debug( "unable to create manager instance: %x\r\n", GetLastError() );

		} // if	
	} // if

	if( retVal == 0 )
	{
		//_shutdown( L );

	} // if
	lua_pushboolean( L, retVal );
	return( 1 );
	
} // _init



static int _shutdown( lua_State *L )
{
	debug( "_shutdown\r\n" );
	if( g_deviceAdded != NULL )
	{
		g_deviceAdded->Release();
		g_deviceAdded = NULL;

	} // if
	if( g_deviceRemoved != NULL )
	{
		g_deviceRemoved->Release();
		g_deviceRemoved = NULL;

	} // if
	if( g_itemAdded != NULL )
	{
		g_itemAdded->Release();
		g_itemAdded = NULL;

	} // if
	if( g_WiaDevMgr != NULL )
	{
		g_WiaDevMgr->Release();
		g_WiaDevMgr = NULL;

	} // if
	lua_pushnil( L );
	lua_setglobal( L, "_PTPNativeCallbackThread" ); // free the reference	
	lua_pushnil( L );
	return( 1 );
	
} // _shutdown



static int _listDevices( lua_State *L )
{
	int retVal = 0;
	IEnumWIA_DEV_INFO *enumInfo = NULL;
    HRESULT hr = g_WiaDevMgr->EnumDeviceInfo( WIA_DEVINFO_ENUM_LOCAL, &enumInfo );
    if( SUCCEEDED( hr ) )
    {
        while( hr == S_OK )
        {
            IWiaPropertyStorage *propertyStorage = NULL;
            hr = enumInfo->Next( 1, &propertyStorage, NULL );
            if( hr == S_OK )
            {
				lua_newtable( L );

				PROPSPEC propSpec[ 2 ] = {0};
				PROPVARIANT propVar[ 2 ] = {0};
				const ULONG nProps = sizeof( propSpec ) / sizeof( propSpec[ 0 ] );

				propSpec[0].ulKind = PRSPEC_PROPID;
				propSpec[0].propid = WIA_DIP_DEV_ID;

				propSpec[1].ulKind = PRSPEC_PROPID;
				propSpec[1].propid = WIA_DIP_DEV_NAME;

				hr = propertyStorage->ReadMultiple( nProps, propSpec, propVar );
		        if( SUCCEEDED( hr ) )
		        {
		            if( propVar[ 0 ].vt == VT_BSTR )
		            {
		                debug( "WIA_DIP_DEV_ID: %ws\n", propVar[ 0 ].bstrVal );
						lua_pushlstring( L, ( char * ) propVar[ 0 ].bstrVal, ( lstrlen( propVar[ 0 ].bstrVal ) + 1 ) * sizeof( WCHAR ) );
						lua_pushlstring( L, ( char * ) propVar[ 0 ].bstrVal, ( lstrlen( propVar[ 0 ].bstrVal ) + 1 ) * sizeof( WCHAR ) );
						lua_settable( L, -3 );

					} // if

		            if( propVar[ 1 ].vt == VT_BSTR )
		            {
		                debug( "WIA_DIP_DEV_NAME: %ws\n", propVar[ 1 ].bstrVal );

					} // if
					FreePropVariantArray( nProps, propVar );

				} // if
                propertyStorage->Release();
				retVal = 1;

            } // if
        } // while
        enumInfo->Release();

    } // if
	debug( "_listDevices: end\r\n" );
	return( retVal );
	
} // _listDevices



static int _passthrough( lua_State *L )
{
	int retVal = 0;
	debug( "$$$$$$$$$$$$$ _passthrough\r\n" );	
	if(    ( lua_gettop( L ) == 2 )
	    && lua_isstring( L, 1 )
	    && lua_istable( L, 2 ) )
	{		
		DWORD tries = 0;
		IWiaItem *item = NULL;
		HRESULT hr = 0;
		while( ( hr = g_WiaDevMgr->CreateDevice( ( BSTR ) lua_tostring( L, 1 ), &item ) ) == 0x80210006 )
		{
			// device busy
			Sleep( 100 );
			tries++;
			if( tries == 10 )
			{
				break;

			} // if
		} // while
		if( SUCCEEDED( hr ) )
		{
			IWiaItemExtras *extras = NULL;
			hr = item->QueryInterface( IID_IWiaItemExtras, ( void ** ) &extras );
			if( SUCCEEDED( hr ) ) 
			{
				DWORD inSize = 0;
				DWORD outSize = 0;
				PTP_VENDOR_DATA_IN *in = NULL;
				PTP_VENDOR_DATA_OUT *out = NULL;
				if( Passthrough_alloc( L, &in, &inSize, &out, &outSize ) )
				{
					lua_pushstring( L, "operation" );
					lua_gettable( L, -2 );
					in->OpCode = ( WORD ) lua_tonumber( L, -1 );
					lua_pop( L, 1 );

					Passthrough_copyInboundData( L, in );
					DWORD resSize = 0;
					hr = extras->Escape( ESCAPE_PTP_VENDOR_COMMAND,
										 ( BYTE * ) in, inSize,
										 ( BYTE * ) out, outSize,
										 &resSize );
					debug( "Escape called, hr: %x, resSize: %x\r\n", hr, resSize );
					if( SUCCEEDED( hr ) )
					{
						Passthrough_copyOutboundData( out, resSize, L );
						retVal = out->ResponseCode;
						debug( "resultCode: %x\r\n", retVal );

					} // if
					free( in );
					free( out );

				} // if
				extras->Release();

			}
			else
			{
				debug( "unable to get the extras interface, device: %ws, error: %x\r\n", lua_tostring( L, 1 ), hr );

			} // if
			// TODO: we need to keep a device open to get item added notifications
			// item->Release();

		} 
		else
		{
			debug( "unable to create device: %ws, error: %x\r\n", lua_tostring( L, 1 ), hr );

		} // if
	} // if
	lua_pushnumber( L, retVal );
	return( 1 );
	
} // _passthrough


static void CALLBACK _runloopTimerExpired( HWND hwnd, UINT uMsg, UINT_PTR idEvent, DWORD dwTime )
{
	PostQuitMessage( 0 );

} // _runloopTimerExpired



static int _runRunLoop( lua_State *L )
{
	int retVal = 0;
	if(    ( lua_gettop( L ) == 1 )
	    && lua_isnumber( L, 1 ) )
	{		
		MSG msg;
		UINT_PTR timer = SetTimer( NULL, 0, ( lua_tonumber( L, 2 ) * 1000 ), _runloopTimerExpired );
		while( GetMessage( &msg, NULL, 0, 0 ) > 0 ) 
		{
			TranslateMessage( &msg );
			DispatchMessage( &msg );

		} // while
		KillTimer( NULL, timer );
	}
	else
	{
		luaInvalidParameters( L );
	
	} // if
	return( 0 );
	
} // _runRunLoop



static int _quitRunLoop( lua_State *L )
{
	PostQuitMessage( 0 );
	return( 0 );
	
} // _quitRunLoop



static const struct luaL_reg _funcs[] = 
{
	{ "init", _init },
	{ "shutdown", _shutdown },
	{ "listDevices", _listDevices },
	{ "runRunLoop", _runRunLoop },
	{ "quitRunLoop", _quitRunLoop },
	{ "passthrough", _passthrough },
	{ NULL, NULL }
};



extern "C" __declspec(dllexport) int luaopen_Win32( lua_State *L ) 
{
	luaL_openlib( L, "PTPNative", _funcs, 0 );
	debug( "luaopen_PTP-Win32: initialized\r\n" );
	return( 1 );
	
} // luaopen_Win32( func )