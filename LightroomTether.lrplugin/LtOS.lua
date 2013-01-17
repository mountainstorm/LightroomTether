--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

LtOS.lua
provides functions and variables which are OS specific

------------------------------------------------------------------------------]]



-- Access the Lightroom SDK namespaces
local LrTasks = import 'LrTasks'
local LrDialogs = import 'LrDialogs'


LtOS = {
	pathSep = "/",
	isRunning = function( script )
		return LrTasks.execute( "\"".._PLUGIN.path.."/OSX/isRunning\" \""..script.."\"" ) == 0
	end,
	spawnProcess = function( cmd )
		return "\"".._PLUGIN.path.."/OSX/lua5.1\" "..cmd.." &"
	end
}


if _PLUGIN.path:sub( 2, 2 ) == ":" then
	LtOS = {
		pathSep = "\\",
		isRunning = function( script )
			return LrTasks.execute( "wscript \"".._PLUGIN.path.."\\Win32\\isRunning.js\" "..script ) == 0 -- "\"LightroomTether.lrplugin\\Win32\\wlua5.1.exe\"" ) == 0
		end,
		spawnProcess = function( cmd )
			return "wscript \"".._PLUGIN.path.."\\Win32\\launch.js\" \"".._PLUGIN.path.."\\Win32\\wlua5.1.exe\" "..cmd
		end
	}
end


return LtOS

