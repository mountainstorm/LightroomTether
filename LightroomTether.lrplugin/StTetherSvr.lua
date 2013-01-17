--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

StTetherSvr.lua
the main entrypoint for the camera server

------------------------------------------------------------------------------]]



-- this requires a fullpath, else the ':' check and the gsub(basename) wont work 
local isLightroomRunning = nil

if arg[ 0 ]:sub( 2, 2 ) == ":" then
	local libRoot, _ = string.gsub( arg[ 0 ], "(.*)\\(.*)", "%1" )
	package.path = package.path..";"..libRoot.."\\?\\init.lua;"..libRoot.."\\?.lua"
	package.cpath = package.cpath..";"..libRoot.."\\?.dll"

	require( 'LightroomUtils-Win32' )		
	
	isLightroomRunning = function()
		return LightroomUtils.isRunning( "lightroom.exe" )
	end
else
	local libRoot, _ = string.gsub( arg[ 0 ], "(.*)/(.*)", "%1" )
	package.path = package.path..";"..libRoot.."/?/init.lua;"..libRoot.."/?.lua"
	package.cpath = package.cpath..";"..libRoot.."/?.so"

	require( 'LightroomUtils-OSX' )	

	isLightroomRunning = function()
		return os.execute( "\""..libRoot.."/OSX/isRunning\" \"Adobe Lightroom\"" ) == 0
	end
end



local StNativeSvr = require 'StNativeSvr'
local Pickle = require 'Pickle'
require( 'PTP' )



function tblprint(tt, indent, done)
  print( "table_print: ", tt )
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => table\n", tostring (key)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        tblprint (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n",
            tostring (key), tostring(value)))
      end
    end
  else
	if tt ~= nil then
		io.write(tt .. "\n")
	end
  end
end



-- StTetherSvr has global scope as its accessed by remove code
StTetherSvr = {
	kNoActivityPoll = 0.2,
	kCheckLightroomPoll = 3,

	_queue = {},
	_downloadPath = nil,
	_yieldedThreads = {},
	_running = true
}


function StTetherSvr:queue( val )
	table.insert( self._queue, val )

	if table.maxn( self._queue ) == 1 then
		local thread = table.remove( self._yieldedThreads, 1 )
		if thread ~= nil then
			coroutine.resume( thread )
		end
	end	
end


function StTetherSvr:dequeue()
	local retVal = nil
	if table.maxn( self._queue ) == 0 then
		table.insert( self._yieldedThreads, coroutine.running() )
		coroutine.yield()
	end

	local val = table.remove( self._queue, 1 )
	if val ~= nil then
		retVal = Pickle:pickle( val )
		print( retVal )
	end
	return retVal, function()
		StTetherSvr:queue( val )
	end
end


function StTetherSvr:setDownloadPath( path )
	self._downloadPath = path
end


function StTetherSvr:getDownloadPath( img )
	return self._downloadPath
end


function StTetherSvr:quit()
	self._running = false
end


function StTetherSvr:isRunning()
	return self._running
end


function StTetherSvr:selectNextPhoto()
	LightroomUtils.selectNextPhoto()
end


function StTetherSvr:main()
	local ptpTimeout = StTetherSvr.kNoActivityPoll
	local sockTimeout = StTetherSvr.kNoActivityPoll
	
	
	PTP:init( { customEvent = function( camera, ev ) 
					local devinfo = camera:getDeviceInfo()
					if ev.event == PTP.kCustomEventAdded then
						print( "camera added, manufacturer: '"..devinfo[ "Manufacturer" ].."', model: '"..devinfo[ "Model" ].."'" )
						StTetherSvr:queue( { [ "added" ] = devinfo[ "Model" ] } )

					elseif ev.event == PTP.kCustomEventRemoved then
						print( "camera removed, manufacturer: '"..devinfo[ "Manufacturer" ].."', model: '"..devinfo[ "Model" ].."'" )
						StTetherSvr:queue( { [ "removed" ] = devinfo[ "Model" ] } )
					end
				end,
				ptpEvent = function( camera, ev )
					print( "ptpEvent: "..ev.event )
					if ev.event == 0x4002 then
						if StTetherSvr:getDownloadPath() then
							print( "downloading: "..ev.params[ 1 ] )
							local objInfo = camera:getObjectInfo( ev.params[ 1 ] )
							tblprint( objInfo )

							
							local data = camera:getPartialObject( ev.params[ 1 ], 
																  0, 
																  objInfo[ "ObjectCompressedSize" ] )
							if data ~= nil then
								print( "Download Path: "..StTetherSvr:getDownloadPath()..objInfo[ "Filename" ] )
								local handle = io.open( StTetherSvr:getDownloadPath()..objInfo[ "Filename" ], "wb" )
								handle:write( data )
								handle:close()
								StTetherSvr:queue( { [ "import" ] = StTetherSvr:getDownloadPath()..objInfo[ "Filename" ] } )
							else
								print( "data returned nil" )
							end
						else
							print( "no download path set" )
						end
					end
				end } )
			
	
	local svr = StNativeSvr:new()
	if svr:init( arg[ 1 ], function() 
			print( "shutdown func called" )
			running = false 
		end ) then
		
		print( "setting download path: "..arg[ 2 ] )
		StTetherSvr:setDownloadPath( arg[ 2 ] )
		PTP:updateCameraList()
		
		local startTime = os.time()
		while StTetherSvr:isRunning() do
			if PTP:runRunLoop( ptpTimeout ) > 0 then
				-- we have PTP events so nip through the socket callbacks asap
				sockTimeout = 0
			else
				sockTimeout = StTetherSvr.kNoActivityPoll
			end	
			
			if svr:dispatchEvents( sockTimeout ) > 0 then
				-- we have socket events so nip through the PTP callbacks asap
				ptpTimeout = 0
			else
				ptpTimeout = StTetherSvr.kNoActivityPoll
			end
			
			-- every few seconds check Lightroom is still running
			local endTime = os.time()
			if os.difftime( endTime, startTime ) >= StTetherSvr.kCheckLightroomPoll then
				startTime = os.time()
				if isLightroomRunning() == false then
					StTetherSvr:quit()
				end
			end
		end
		svr:shutdown()
	end
	PTP:shutdown()
end


-- call main
StTetherSvr:main()
