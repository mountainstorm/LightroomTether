--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

LtBeginTether.lua
creates a new tether object and begin the session

------------------------------------------------------------------------------]]


-- Access the Lightroom SDK namespaces
local LrFunctionContext = import 'LrFunctionContext'


local LtOS = require 'LtOS'
local LtTether = require 'LtTether'


LrFunctionContext.postAsyncTaskWithContext( "LtBeginTether.launch", function( context )
	-- trigger a start (if its not already running) when run by the user
	if LtOS.isRunning( LtTether.kProcess ) == false then
		LtTether:new():begin()
	end
end )
