--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

StNativeSvr.lua
the HTTP lua server helper functions

------------------------------------------------------------------------------]]


local socket = require( "socket" )


local StNativeSvr = {}


function StNativeSvr:new()
	local o = {
		_l = nil,
		_conn = {},
		
		_readFuncs = {},
		_writeFuncs = {}
	}
	
	setmetatable( o, self )
    self.__index = self
	return o
end


function StNativeSvr:init( port )
	local retVal = false
	
	self._l = socket.tcp()
	if self._l ~= nil then
		self._l:setoption( "linger", { ["on"] = false, ["timeout"] = 0 } )
		self._l:setoption( "reuseaddr", true )
		if self._l:bind( "127.0.0.1", port ) == 1 then
			print( "bound to 127.0.0.1:"..port )
			self._l:settimeout( 0, "t" )
			self._l:listen( 5 )
	
			self:waitForRead( self._l, function( s )
				self:_acceptConnection( s )
			end )
			retVal = true
		else
			print( "bind failed" )
		end
	end
	return retVal
end


function StNativeSvr:waitForRead( s, func )
	self._readFuncs[ s ] = func
end


function StNativeSvr:waitForWrite( s, func )
	self._writeFuncs[ s ] = func
end


function StNativeSvr:dispatchEvents( timeout )
	local read = {}
	for s, _ in pairs( self._readFuncs ) do
		table.insert( read, s )
	end

	local write = {}
	for s, _ in pairs( self._writeFuncs ) do
		table.insert( write, s )
	end
	
	local readable = nil
	local writable = nil
	local err = nil
	readable, writable, err = socket.select( read, write, timeout )
	
	-- we utilize a tmp variable here just in case the func adds/removes anything
	for _, s in ipairs( readable ) do
		local func = self._readFuncs[ s ]
		self._readFuncs[ s ] = nil
		func( s )
	end

	for _, s in ipairs( writable ) do
		local func = self._writeFuncs[ s ]
		self._writeFuncs[ s ] = nil
		func( s )
	end
	return table.maxn( readable ) + table.maxn( writable )
end


function StNativeSvr:_acceptConnection( sock )
	print( "connection accepted" )
	local sock = self._l:accept()
	if sock ~= nil then
		self._conn[ sock ] = sock
		sock:settimeout( 0, "t" )
		sock:setoption( "linger", { ["on"] = false, ["timeout"] = 0 } )
		local connectionRoutine = coroutine.create( function( con )
			self:_processRequest( con )
		end )

		local connection = { _s = sock,
							 _routine = connectionRoutine }
		coroutine.resume( connection._routine, connection )
	end		
		
	-- requeue a read to collect further read requests
	self:waitForRead( self._l, function( s )
		self:_acceptConnection( s )
	end )
end


function StNativeSvr:_processRequest( con )
	local line = self:_recv( con, "*l" )
	if string.len( line ) ~= 0 then
		local method = nil
		local path = nil
		local major = nil
		local minor = nil
		local headers = {}
		local body = nil
		_, _, method, path, major, minor = string.find( line, "([A-Z]+) (.+) HTTP/(%d).(%d)" )
		print( "request: "..line )
		
		line = self:_recv( con, "*l" )
		while string.len( line ) ~= 0 do
			-- parse out the headers
			_, _, key, value = string.find( line, "(.+): (.*)" )

			print( line )
			headers[ key ] = value
			line = self:_recv( con, "*l" )
		end
		
		if method == "POST" then
			body = self:_recv( con, tonumber( headers[ "Content-Length" ] ) )
			print( body )
			
			local errFunc = nil
			body, errFunc = loadstring( "return "..body )()
			if body == nil then
				body = ""
			end
			print( body )

			if self:_send( con, "HTTP/1.0 200 OK\r\n" ) == nil or
			   self:_send( con, "Content-Type: text/plain\r\n" ) == nil or
			   self:_send( con, "Content-Length: "..string.len( body ).."\r\n" ) == nil or
			   self:_send( con, "\r\n" ) == nil or
			   self:_send( con, body ) == nil then
				errFunc()
			end
		end
	end	
	con._s:shutdown( "both" )
	con._s:close()	
	self._conn[ con._s ] = nil
end


function StNativeSvr:_recv( con, pattern )
	local data = ""
	local err = "timeout"
	local partial = nil
		
	while err == "timeout" do
		local bytes
		bytes, err, partial = con._s:receive( pattern )
		if bytes ~= nil then
			data = data..bytes
			if type( pattern ) == "number" then
				pattern = pattern - string.len( bytes )
			end
		end
		
		if err == "timeout" then
			self:waitForRead( con._s, function( s ) 
				coroutine.resume( con._routine )
			end )
			coroutine.yield()
		end	
	end
	return data, err, partial
end


function StNativeSvr:_send( con, data )
	return con._s:send( data ) -- TODO stop the blocking stuff
end


function StNativeSvr:shutdown()
	self._l:close()
	
	for k, v in pairs( self._conn ) do
		v:shutdown( "both" )
		v:close()	
	end
	self._conn = {}
end


return StNativeSvr
