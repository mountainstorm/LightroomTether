/*
 *  PTP-OSX.c
 *  PTP-OSX
 *
 *  Created by drake on 06/03/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */

#include "PTP-OSX.h"
#include "Passthrough.h"
#include "PTP.h"

#include "debug.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <Carbon/Carbon.h>


#define kEventTypeNone		0
#define kEventTypeCustom	1
#define kEventTypePTP		2

#define kCustomEventAdded 	0
#define kCustomEventRemoved 1



static void _handleNotification( CFStringRef notificationType, CFDictionaryRef notificationDictionary );
static pascal OSStatus _handlePendingEvents( EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData );

static void _runloopTimerExpired( EventLoopTimerRef inTimer, void *inUserData );



static int _init( lua_State *L )
{
	int retVal = 0;
	if(    ( lua_gettop( L ) == 1 ) 
	    && (    lua_isfunction( L, -1 )
			 || lua_isnil( L, -1 ) ) )
	{
		OSErr err = noErr;
		ICARegisterForEventNotificationPB pb = {};
	
		debug( "$$$$$$$$$$$$$: _init\r\n" );
	
		pb.objectOfInterest = 0;
		if( lua_isfunction( L, -1 ) )
		{
			// all the notifications we can register for
			CFStringRef notifications[] = { kICANotificationTypeTransactionCanceled,
											kICANotificationTypeObjectAdded,
											kICANotificationTypeObjectRemoved, 
											kICANotificationTypeStoreAdded, 
											kICANotificationTypeStoreRemoved,
											kICANotificationTypeDevicePropertyChanged,
											kICANotificationTypeObjectInfoChanged, 										
											kICANotificationTypeDeviceInfoChanged,
											kICANotificationTypeRequestObjectTransfer,
											kICANotificationTypeStoreFull,
											kICANotificationTypeDeviceWasReset,
											kICANotificationTypeStoreInfoChanged,
											kICANotificationTypeCaptureComplete,
											kICANotificationTypeUnreportedStatus,
											
											kICANotificationTypeDeviceAdded,
											kICANotificationTypeDeviceRemoved,
											kICANotificationTypeProprietary,
											kICANotificationTypeDeviceConnectionProgress,
											kICANotificationTypeDownloadProgressStatus };

			lua_State *callThread = lua_newthread( L );
			if( callThread != NULL )
			{
				lua_setglobal( L, "_PTPNativeCallbackThread" ); // store it so the GC doesn't discard it
				lua_xmove( L, callThread, 1 ); // copy the function call onto the stack
				
				pb.header.refcon    = ( unsigned long ) callThread;
				pb.eventsOfInterest = CFArrayCreate( NULL,
													 ( const void ** ) notifications,
													 sizeof( notifications ) / sizeof( notifications[ 0 ] ),
													 NULL );
				
			} // if
		}
		else
		{
			pb.header.refcon    = ( unsigned long ) NULL;
			pb.eventsOfInterest = CFArrayCreate( NULL, 
												 NULL,
												 0,
												 NULL );
			
		} // if
		pb.notificationProc = _handleNotification;
		pb.options          = NULL;
		err = ICARegisterForEventNotification( &pb, NULL );
		if( err == noErr )
		{
			debug( "registered for all notifications\r\n" );		
		}
		else
		{
			debug( "Unable to register for device insertion/removal notifications: %d\r\n", err );

		} // if
		retVal = ( err == noErr );
		
	} // if
	
	lua_pushboolean( L, retVal );
	return( 1 );
	
} // _init



static int _shutdown( lua_State *L )
{
	lua_pushnil( L );
	lua_setglobal( L, "_PTPNativeCallbackThread" ); // free the reference
	
	lua_pushnil( L );
	return( _init( L ) );
	
} // _shutdown



static int _listDevices( lua_State *L )
{
	int retVal = 0;
	ICAGetDeviceListPB pb = {0};
	OSErr err = noErr;
	
	err = ICAGetDeviceList( &pb, NULL );
	if( err == noErr )
	{
		CFDictionaryRef theDict = NULL;
		ICACopyObjectPropertyDictionaryPB pbd = {0};
		
		pbd.object = pb.object;
		pbd.theDict = &theDict;
		err = ICACopyObjectPropertyDictionary( &pbd, NULL );
		if( err == noErr )
		{
			CFArrayRef devices = CFDictionaryGetValue( theDict, kICADevicesArrayKey );
			if( devices != NULL )
			{
				CFIndex i = 0;
				//CFShow( devices );
				lua_newtable( L );
				for( i = 0; i < CFArrayGetCount( devices ); i++ )
				{
					SInt64 icao = 0;
					CFNumberGetValue( CFDictionaryGetValue( CFArrayGetValueAtIndex( devices, i ), 
															CFSTR( "icao" ) ), 
									  kCFNumberSInt64Type, 
									  &icao );
					lua_pushnumber( L, icao ); // use it as both the key and value
					lua_pushnumber( L, icao );
					lua_settable( L, -3 );
			
				} // for	
				retVal = 1;
				
			} // if
			CFRelease( theDict );

		}
		else
		{
			debug( "unable to get dictionary of device list\r\n" );

		} // if	
	}
	else
	{
		debug( "unable to get devicelist: %d\r\n", err );
		
	} // if	
	return( retVal );
	
} // _listDevices



static int _passthrough( lua_State *L )
{
	int retVal = 0;
	debug( "$$$$$$$$$$$$$ _passthrough\r\n" );	
	if(    ( lua_gettop( L ) == 2 )
	    && lua_isnumber( L, 1 )
	    && lua_istable( L, 2 ) )
	{		
		PTPPassThroughPB *passPb = Passthrough_allocPTPPassthroughPB( L );
		if( passPb != NULL )
		{
			OSErr err = noErr;
			ICAObjectSendMessagePB pb = {0};
			
			lua_pushstring( L, "operation" );
			lua_gettable( L, -2 );			
			passPb->commandCode = lua_tonumber( L, -1 );
			lua_pop( L, 1 );
			
			Passthrough_copyInboundData( L, passPb );
				
			pb.object = ( ICAObject ) lua_tonumber( L, 1 );
			debug( "object: %x\r\n", pb.object );
			
			pb.message.messageType = kICAMessageCameraPassThrough;
			pb.message.startByte = 0;
			pb.message.dataPtr = passPb;
			pb.message.dataSize = sizeof( PTPPassThroughPB ) - 1 + passPb->dataSize;
			pb.message.dataType	= 0;
			
			debug( "sending, command: %x, noIn: %u, noOut, %u, dataSize: %u\r\n", 
				   passPb->commandCode,
				   passPb->numOfInputParams,
				   passPb->numOfOutputParams,
				   passPb->dataSize );
			
			err = ICAObjectSendMessage( &pb, NULL );
			if( err == noErr )
			{
				debug( "usage: %x, size: %u, ret: %x, res: %u\r\n", 
					   passPb->dataUsageMode, 
					   passPb->dataSize, 
					   passPb->resultCode, 
					   pb.result );
				
				Passthrough_copyOutboundData( passPb, L );
				retVal = passPb->resultCode;
				
			}
			else
			{
				debug( "error, attempting to send PTP message: %d\r\n", err );
				
			} // if		
			free( passPb );

		} // if 
	} // if
	lua_pushnumber( L, retVal );
	return( 1 );
	
} // _passthrough



static void _handleNotification( CFStringRef type, CFDictionaryRef dict )
{
	SInt64 devObjNum = 0;
	debug( "$$$$$$$$$$$$$ _handleNotification: %s\r\n", CFStringGetCStringPtr( type, kCFStringEncodingMacRoman ) );
	if(		CFNumberGetValue( ( CFNumberRef ) CFDictionaryGetValue( dict, kICANotificationDeviceICAObjectKey ),
							  kCFNumberSInt64Type,
							  &devObjNum ) 
		&& ( devObjNum != 0 ) )
	{
		SInt64 LNum = 0;
		ICAObject devObj = devObjNum;
		
		//CFShow( dict );
		if(	CFNumberGetValue( ( CFNumberRef ) CFDictionaryGetValue( dict, kICARefconKey ),
							  kCFNumberSInt64Type,
							  &LNum )
		    && ( LNum != 0 ) )
		{						
			lua_State *L = ( lua_State * ) LNum;
			unsigned int eventType = kEventTypeNone;
	
			lua_pushvalue( L, -1 ); // copy the function object so we can be called multiple times
			lua_createtable( L, 0, 3 );
			lua_pushstring( L, "object" );
			lua_pushnumber( L, devObj );
			lua_settable( L, -3 );
	
			if( CFStringCompare( type, kICANotificationTypeDeviceAdded, 0 ) == kCFCompareEqualTo )
			{
				lua_pushstring( L, "event" );
				lua_pushnumber( L, kCustomEventAdded );
				lua_settable( L, -3 );
				eventType = kEventTypeCustom;
			
			}
			else if( CFStringCompare( type, kICANotificationTypeDeviceRemoved, 0 ) == kCFCompareEqualTo )
			{
				lua_pushstring( L, "event" );
				lua_pushnumber( L, kCustomEventRemoved );
				lua_settable( L, -3 );	
				eventType = kEventTypeCustom;
			
			}
			else
			{
				CFDataRef rawData = CFDictionaryGetValue( dict, kICANotificationDataKey );
				if( rawData != NULL )
				{
					ICAPTPEventDataset *ev = ( ICAPTPEventDataset * ) CFDataGetBytePtr( rawData );
					UInt32 noParams = 0;
					UInt32 i = 0;
			
					lua_pushstring( L, "event" );
					lua_pushnumber( L, ev->eventCode );
					lua_settable( L, -3 );	
	
					lua_pushstring( L, "params" );
					lua_newtable( L );
	
					noParams = ( CFDataGetLength( rawData ) - 12 ) / sizeof( SInt32 );
					for( i = 0; i < noParams; i++ )
					{
						lua_pushnumber( L, i + 1 );
						lua_pushnumber( L, ev->params[ i ] );
						lua_settable( L, -3 );
					
					} // for
					lua_settable( L, -3 );
					eventType = kEventTypePTP;
	
				}
				else
				{
					debug( "event did not have raw event code\r\n" );
				
				} // if
			} // if
			
			lua_pushstring( L, "eventType" );
			lua_pushnumber( L, eventType );
			lua_settable( L, -3 );	
			
			// call the callback function with the table
			lua_call( L, 1, 0 );	
			lua_pop( L, lua_gettop( L ) - 1 ); // dump everything else on the stack except the function call
	
		}
		else
		{
			debug( "unable to get lua 'invoke' thread\r\n" );
			
		} // if
	}
	else
	{
		debug( "unable to get ica device object\r\n" );
		
	} // if
} // _handleNotification



static void _runloopTimerExpired( EventLoopTimerRef inTimer, void *inUserData )
{
	QuitApplicationEventLoop();

} // _runloopTimerExpired



static int _runRunLoop( lua_State *L )
{
	int retVal = 0;
	if(    ( lua_gettop( L ) == 1 )
	    && lua_isnumber( L, 1 ) )
	{		
		EventLoopTimerRef timer = NULL;
		EventLoopTimerUPP timerUPP = NewEventLoopTimerUPP( _runloopTimerExpired );
		if( timerUPP != NULL )
		{
			OSErr err = InstallEventLoopTimer( GetMainEventLoop(),
											   lua_tonumber( L, 1 ),
											   0,
											   timerUPP,
											   NULL,
											   &timer );
			if( err == noErr )
			{
				RunApplicationEventLoop();
				RemoveEventLoopTimer( timer );
				
			}
			else
			{
				debug( "unable to install event lopp timer\r\n" );
			
			} // if
			DisposeEventLoopTimerUPP( timerUPP );
				
		}
		else
		{
			debug( "unable to create the timer UPP\r\n" );
		
		} // if		
	}
	else
	{
		luaInvalidParameters( L );
	
	} // if
	return( 0 );
	
} // _runRunLoop



static int _quitRunLoop( lua_State *L )
{
	QuitApplicationEventLoop();
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



extern int luaopen_OSX( lua_State *L ) 
{
	luaL_openlib( L, "PTPNative", _funcs, 0 );
	debug( "luaopen_PTP-OSX: initialized\r\n" );
	return( 1 );
	
} // luaopen_OSX( func )
