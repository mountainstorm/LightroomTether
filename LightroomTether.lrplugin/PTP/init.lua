--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

init.lua
group together all PTP functions

------------------------------------------------------------------------------]]



PTP = {}
PTP._cameras = {}
PTP._callbacks = nil
PTP._noCallbacks = 0

PTP.kSocketReadCallback = 0
PTP.kSocketWriteCallback = 1
PTP.kSocketConnectCallback = 2

PTP.kEventTypeNone = 0
PTP.kEventTypeCustom = 1
PTP.kEventTypePTP = 2

PTP.kCustomEventAdded = 0
PTP.kCustomEventRemoved = 1


if arg[ 0 ]:sub( 2, 2 ) == ":" then
	require( 'PTP.PTP-Win32' )
else
	require( 'PTP.PTP-OSX' )
end

require( 'PTP.Dataset' )
require( 'PTP.Camera' )
require( 'PTP.DeviceProperties' )



function PTP:init( callbacks )
	self._callbacks = callbacks
	
	PTPNative.init( function( ev )
		self._noCallbacks = self._noCallbacks + 1
		
		local camera = self._cameras[ ev.object ]	
		if camera == nil and 
		   ev.eventType == PTP.kEventTypeCustom and
		   ev.event == PTP.kCustomEventAdded then
		   	print( "creating a new camera" )
			camera = PTP:_createCamera( ev.object )
			self._cameras[ ev.object ] = camera
		end
		
		if camera ~= nil then
			if ev.eventType == PTP.kEventTypeCustom then
				self._callbacks.customEvent( camera, ev )
			elseif ev.eventType == PTP.kEventTypePTP then
				if ev.params ~= nil then
					self._callbacks.ptpEvent( camera, ev )
				elseif ev.event == 0x4002 then
					-- no object handle provided, so lets check whats new & generate events
					local oldHandles = camera._objectHandles
					camera._objectHandles = camera:getObjectHandles( 0xFFFFFFFF )
												
					local newHandles = {}
					for _, v in ipairs( camera._objectHandles ) do
						local found = false
						for _, tv in ipairs( oldHandles ) do
							if tv == v then
								found = true
								break
							end
						end
						
						if found == false then
							-- new object
							ev.params = { v }
							self._callbacks.ptpEvent( camera, ev )
						end						
					end
				end
			end
		else
			print( "no camera object" )
			tblprint( ev )
		end
		
		if camera ~= nil and 
		   ev.eventType == PTP.kEventTypeCustom and
		   ev.event == PTP.kCustomEventRemoved then
		   	self._cameras[ ev.object ]:delete()
			self._cameras[ ev.object ] = nil
		end
	end )
end


function PTP:runRunLoop( timeout )
	PTPNative.runRunLoop( timeout )
	
	local noEvents = self._noCallbacks
	self._noCallbacks = 0 -- reset it so we catch any callbacks as a result of sys calls returning
	return noEvents
end


function PTP:quitRunLoop()
	PTPNative.quitRunLoop()
end


function PTP:shutdown()
	if self._cameras ~= nil then
		for k, v in pairs( self._cameras ) do
			self._callbacks.customEvent( self._cameras[ k ], { event = PTP.kCustomEventRemoved } )
			self._cameras[ k ]:delete()
		end
		self._cameras = {}
	end
	self._callbacks = nil
end


function PTP:updateCameraList()
	local cameras = PTPNative.listDevices()

	-- check all our cameras still exist 
	if self._cameras ~= nil then
		for k, v in pairs( self._cameras ) do
			if cameras[ k ] == nil then
				-- camera removed
				self._callbacks.customEvent( self._cameras[ k ], { event = PTP.kCustomEventRemoved } )
				self._cameras[ k ]:delete()
				self._cameras[ k ] = nil
			else
				-- camera still there
				cameras[ k ] = nil
			end
		end
	end
	
	-- anything left in cameras is new
	if cameras ~= nil then
		for k, v in pairs( cameras ) do
			self._cameras[ k ] = self:_createCamera( v )
			if self._cameras[ k ] ~= nil then
				self._callbacks.customEvent( self._cameras[ k ], { event = PTP.kCustomEventAdded } )
			end
		end
	end
end


function PTP:_createCamera( obj )
	local camera = PTP.Camera:new( obj )
	if camera ~= nil then
		devinfo = camera:getDeviceInfo()
		tblprint( devinfo )
		camera._objectHandles = camera:getObjectHandles( 0xFFFFFFFF )
		
		pcall( function()
			local camClass = require( 'PTP.Camera.'..devinfo[ "Manufacturer" ] )
			local camInst = camClass:new( camera )
			if camInst ~= nil then
				camera = camInst
			end
		end )
	end
	return camera
end
