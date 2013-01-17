/*
 *  launch
 *
 *  Created by drake on 07/11/2009.
 *  Copyright 2009 Mountainstorm. All rights reserved.
 *
 */
var cmd = ""
for( i = 0; i < WScript.Arguments.length; i++ )
{
	var fix = ""; // fix the broken parsing of wlua5.1.exe
	if( WScript.Arguments( i ).charAt( WScript.Arguments( i ).length - 1 ) == "\\" )
	{
		fix = "\\";
	
	} // if
	cmd = cmd + "\"" + WScript.Arguments( i ) + fix + "\" "
   
} // for

//WScript.Echo( cmd )
var WshShell = new ActiveXObject( "WScript.Shell" );
WshShell.Run( cmd );

/*
var exe = WshShell.Exec( cmd );
var fso = new ActiveXObject("Scripting.FileSystemObject");
var a = fso.CreateTextFile("c:\\testfile.txt", true);
a.WriteLine( exe.StdOut.Read( 40960 ) );
a.WriteLine( exe.StdErr.Read( 40960 ) );
a.Close();
*/
WScript.Quit( 0 )
