--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

LtNative.lua
manages an instance of a Lua out of process server

------------------------------------------------------------------------------]]



-- Access the Lightroom SDK namespaces
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrProgressScope = import 'LrProgressScope'
local LrFunctionContext = import 'LrFunctionContext'
local LrHttp = import 'LrHttp'


local LtOS = require 'LtOS'


local LtNative = {
	kShutdownPoll = 1.0,
	kDefaultTimeout = 15
}


function LtNative:new( name, process, url, quit )
	local o = { 
		_name = name,
		_serverProcess = process,
		_serverURL = url,
		_quit = quit
	}
	
	setmetatable( o, self )
    self.__index = self
	return o
end


function LtNative:init( args, completion )
	-- start the server
	if self._serverProcess ~= nil then
		LrFunctionContext.postAsyncTaskWithContext( "LtNative("..self._name..").server", function( context )
			LrDialogs.attachErrorDialogToFunctionContext( context )
			
			local cmdline = "\""..self._serverProcess.."\""
			for _, arg in ipairs( args ) do
				cmdline = cmdline.." \""..arg.."\""
			end

			if LrTasks.execute( LtOS.spawnProcess( cmdline ) ) == 0 then
				-- wait until the process exits, then call completion
				while LtOS.isRunning( self._serverProcess ) do
					LrTasks.sleep( LtNative.kShutdownPoll )
				end
			else
				LrDialogs.message( self._serverProcess.." crashed" )
			end
			completion()
		end )
		LrTasks.yield() -- give the task a chance to start
	end
end

		
function LtNative:shutdown( completion )
	-- stop the thread which is running
	if self._serverProcess ~= nil then
		self:executeInTask( self._quit, completion )
	end
end


function LtNative:executeInTask( str, completion, timeout )
	LrFunctionContext.postAsyncTaskWithContext( "LtNative("..self._name..").executeInTask", function( context )
		LrDialogs.attachErrorDialogToFunctionContext( context )
		if completion ~= nil then
			context:addCleanupHandler( completion )
		end

		self:execute( str, timeout )
	end )
end


function LtNative:execute( str, timeout )
	local retVal = nil
	local body = nil
	
	if timeout == nil then
		timeout = LtNative.kDefaultTimeout -- not that it seems to work
	end
	body, t = LrHttp.post( self._serverURL, str, nil, "POST", timeout )
	if body ~= nil then
		retVal = assert( loadstring( "return "..body ) )()
	end
	return retVal
end


return LtNative
