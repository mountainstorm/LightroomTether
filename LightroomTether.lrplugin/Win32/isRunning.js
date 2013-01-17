/*
 *  isRunning
 *
 *  Created by drake on 07/11/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */
var loc = new ActiveXObject( "WbemScripting.SWbemLocator" );
var svc = loc.ConnectServer( ".", "root\\cimv2" );						   
processes = svc.ExecQuery( "Select * from Win32_Process" );

//WScript.Echo( "looking for: " + WScript.Arguments( 0 ) );
retVal = -1;
var items = new Enumerator( processes );
while( !items.atEnd() )
{
	var cmd = items.item().CommandLine
	// ignore ourself
	if( cmd != null )
	{
		if( cmd.indexOf( "Win32\\isRunning.js" ) == -1 )
		{
			//WScript.Echo( cmd );
			// check if this is the process we're looking for
			if( cmd.indexOf( WScript.Arguments( 0 ) ) != -1 )
			{
				//WScript.Echo( "found: " + WScript.Arguments( 0 ) );
				retVal = 0;
				break;
		
			} // if
		} // if
	}
	items.moveNext();
	
} // while
WScript.Quit( retVal );
