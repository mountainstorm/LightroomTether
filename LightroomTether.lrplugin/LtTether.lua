--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

LtTether.lua
defines the camera server parameters

------------------------------------------------------------------------------]]



-- Access the Lightroom SDK namespaces
local LrHttp = import 'LrHttp'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrProgressScope = import 'LrProgressScope'
local LrFunctionContext = import 'LrFunctionContext'
local LrApplication = import 'LrApplication'
local LrBinding = import 'LrBinding'
local LrView = import 'LrView'
local LrPrefs = import 'LrPrefs'


local LtOS = require 'LtOS'
local LtNative = require 'LtNative'


local LtTether = {
	kEventPoll = 0.1,
	kShutdownPoll = 0.1,

	kPort = 7986,
	kProcess = _PLUGIN.path..LtOS.pathSep.."StTetherSvr.lua",
	kGetEvents = "StTetherSvr:dequeue()",
	kSelectNextPhoto = "StTetherSvr:selectNextPhoto()",
	kExit = "StTetherSvr:quit()"
}


function LtTether:new()
	local o = {
		_cameras = {},
		_progress = nil,
		_lastImport = nil,
		_server = LtNative:new( "TetherSvr", 
								LtTether.kProcess,
								"http://localhost:"..LtTether.kPort, 
								LtTether.kExit )
	}
	
	setmetatable( o, self )
    self.__index = self
	return o
end


function LtTether:begin()
	local downloadPath = self:selectDownloadPath()
	if downloadPath ~= nil then
		local args = {
			LtTether.kPort,
			downloadPath
		}
		self._server:init( args, function( retVal, msg )
			self._progress:cancel()
		end )

		local runAsyncThread = true
		LrFunctionContext.postAsyncTaskWithContext( "LtTether.shutdown", function( context )
			context:addCleanupHandler( function( retVal, msg )
				runAsyncThread = false
				self._server:shutdown()
				self._progress:cancel()
			end)

			self._progress = LrProgressScope( { title = "Tether: ",
												functionContext = context } )
			self._progress:setIndeterminate()
			while self._progress:isCanceled() == false and self._progress:isDone() == false do
				LrTasks.sleep( LtTether.kShutdownPoll )
			end
		end )

		LrFunctionContext.postAsyncTaskWithContext( "LtTether.getEvents", function( context )
			LrDialogs.attachErrorDialogToFunctionContext( context )
			
			while runAsyncThread == true do
				local val = self._server:execute( LtTether.kGetEvents, nil )
				if val ~= nil then
					if val[ "added" ] ~= nil then
						self:updateProgress( context, val[ "added" ], val[ "added" ] )
						
					elseif val[ "removed" ] ~= nil then
						self:updateProgress( context, val[ "removed" ], nil )

					elseif val[ "import" ] ~= nil then
						local progress = LrProgressScope( { functionContext = context } )
						progress:done()
						
						self:importPhoto( val[ "import" ] )
					end
				end
				LrTasks.sleep( LtTether.kEventPoll )
			end
		end )
	end
end


function LtTether:updateProgress( context, cam, val )
	local progress = LrProgressScope( { functionContext = context } )
	progress:done()

	if cam ~= nil then
		self._cameras[ cam ] = val
		local caption = ""
		local sep = ""
		for k, v in pairs( self._cameras ) do
			caption = caption..sep..v
			if sep == "" then
				sep = " | "
			end
		end
		self._progress:setCaption( caption )
	end
end


function LtTether:importPhoto( path )
	local c = LrApplication.activeCatalog()
	local tp = false
	local tgt = nil
	
	-- add the photo to the catalog
	c:withWriteAccessDo( "Tethered", function() 
		local img = c:addPhoto( path )
		tgt = c.targetPhoto
		if tgt ~= nil and self._lastImport == tgt.path then
			-- We cant programatically select img, so do the next best thing
			tp = true
		end
	end ) 
	
	-- press right in Lightroom ... its the best we can do :)
	if tp == true then
		self._server:executeInTask( LtTether.kSelectNextPhoto )
	end
	self._lastImport = path
end


function LtTether:selectDownloadPath()
	local retVal = nil
	local result = nil
	local updateField = nil
	
	LrFunctionContext.callWithContext( "LtTether.dialog", function( context )
		local f = LrView.osFactory() 
		updateField = f:edit_field {
			value = "<img download folder>",
			enabled = false,
			width_in_chars = 30,
		} 
		
		if LrPrefs.prefsForPlugin().downloadPath ~= nil then
			updateField.value = LrPrefs.prefsForPlugin().downloadPath
		end
		
		local c = f:column {
			spacing = f:label_spacing(),
			f:row {
				updateField,
				f:push_button { 
					title = "Select", 
					action = function()
						local openPath = LrDialogs.runOpenPanel( { title = "Select Download Directory", 
														   		   prompt = "Select",
														   		   canChooseFiles = false,
														   		   canChooseDirectories = true,
														   		   canCreateDirectories = true,
														   		   allowsMultipleSelection = false,
														   		   fileTypes = nil,
														   		   accessoryView = nil } )
						if openPath ~= nil then
							updateField.value = openPath[ 1 ]..LtOS.pathSep
						end
					end 
				}, 
			},
		}
		result = LrDialogs.presentModalDialog( { 
			title = "LtTether", 
			contents = c,
		} ) 
	end )
	
	if result ~= "ok" or updateField.value == nil then
		retVal = nil
	else
		retVal = updateField.value
		LrPrefs.prefsForPlugin().downloadPath = retVal
	end	
	return retVal
end


return LtTether
