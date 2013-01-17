PTP.OperationCode = {}
PTP.ResultCode = {}


PTP.OperationCode.kGetDeviceInfo 		= 0x1001
PTP.OperationCode.kGetObjectHandles		= 0x1007
PTP.OperationCode.kGetObjectInfo		= 0x1008
PTP.OperationCode.kGetDevicePropDesc 	= 0x1014
PTP.OperationCode.kGetDevicePropValue 	= 0x1015
PTP.OperationCode.kSetDevicePropValue	= 0x1016
PTP.OperationCode.kGetPartialObject		= 0x101B

PTP.ResultCode.kOK = 0x2001


PTP.kPassthroughBufferSize = 65535



PTP.Camera = {}


function PTP.Camera:new( obj )
	local o = { 
		_object = obj,
		_devInfoCache = nil
	}
	setmetatable( o, self )
	self.__index = self
	return o
end


function PTP.Camera:delete()
end


function PTP.Camera:getDeviceInfo()
	local cmd = {}
	if self._devInfoCache == nil then
		cmd.operation = PTP.OperationCode.kGetDeviceInfo
		cmd.paramsIn = nil
		cmd.paramsOut = nil
		cmd.dataIn = nil
		cmd.dataOut = PTP.kPassthroughBufferSize
		if PTPNative.passthrough( self._object, cmd ) == PTP.ResultCode.kOK then
			self._devInfoCache = PTP.Dataset.DeviceInfo.unpack( vstruct.cursor( cmd.dataOut ) )
		end
	end
	return self._devInfoCache
end


function PTP.Camera:getObjectHandles( storageID, objFormatCode, objHandle )
	local retVal = nil
	local cmd = {}
	cmd.operation = PTP.OperationCode.kGetObjectHandles
	cmd.paramsIn = { storageID, objFormatCode, objHandle }
	cmd.paramsOut = nil
	cmd.dataIn = nil
	cmd.dataOut = PTP.kPassthroughBufferSize
	if PTPNative.passthrough( self._object, cmd ) == PTP.ResultCode.kOK then
		retVal = PTP.Dataset.Array.unpack( vstruct.cursor( cmd.dataOut ), PTP.Dataset.UINT32 )
	end
	return retVal
end

		
function PTP.Camera:getDevicePropDesc( v )
	local retVal = nil
	local cmd = {}
	cmd.operation = PTP.OperationCode.kGetDevicePropDesc
	cmd.paramsIn = { v }
	cmd.paramsOut = nil
	cmd.dataIn = nil
	cmd.dataOut = PTP.kPassthroughBufferSize
	if PTPNative.passthrough( self._object, cmd ) == PTP.ResultCode.kOK then
		retVal = PTP.Dataset.DevicePropDesc.unpack( vstruct.cursor( cmd.dataOut ) )
	end
	return retVal	
end
		
		
function PTP.Camera:getDevicePropValue( v, typeParser )
	local retVal = nil
	local cmd = {}
	cmd.operation = PTP.OperationCode.kGetDevicePropValue
	cmd.paramsIn = { v }
	cmd.paramsOut = nil
	cmd.dataIn = nil
	cmd.dataOut = PTP.kPassthroughBufferSize
	if PTPNative.passthrough( self._object, cmd ) == PTP.ResultCode.kOK then
		retVal = typeParser.unpack( vstruct.cursor( cmd.dataOut ) )
	end
	return retVal	
end
		
		
function PTP.Camera:setDevicePropValue( v, typeParser, data )
	local retVal = false
	local cmd = {}
	cmd.operation = PTP.OperationCode.kSetDevicePropValue
	cmd.paramsIn = { v }
	cmd.paramsOut = nil
	cmd.dataIn = typeParser.pack( data )
	cmd.dataOut = nil
	if PTPNative.passthrough( self._object, cmd ) == PTP.ResultCode.kOK then
		retVal = true
	end
	return retVal	
end


function PTP.Camera:getObjectInfo( obj )
	local retVal = nil
	local cmd = {}
	cmd.operation = PTP.OperationCode.kGetObjectInfo
	cmd.paramsIn = { obj }
	cmd.paramsOut = nil
	cmd.dataIn = nil
	cmd.dataOut = PTP.kPassthroughBufferSize
	if PTPNative.passthrough( self._object, cmd ) == PTP.ResultCode.kOK then
		retVal = PTP.Dataset.ObjectInfo.unpack( vstruct.cursor( cmd.dataOut ) )
	end
	return retVal
end


function PTP.Camera:getPartialObject( obj, offset, bufferSize )
	local retVal = nil
	local cmd = {}
	cmd.operation = PTP.OperationCode.kGetPartialObject
	cmd.paramsIn = { obj, offset, bufferSize }
	cmd.paramsOut = nil
	cmd.dataIn = nil
	cmd.dataOut = bufferSize
	if PTPNative.passthrough( self._object, cmd ) == PTP.ResultCode.kOK then
		retVal = cmd.dataOut
	end
	return retVal
end


-- processing actions
function PTP.Camera:getPropertyDisplayName( prop )
	local retVal = nil
	if PTP.DeviceProperties[ prop.DevicePropertyCode ] ~= nil then
		retVal = PTP.DeviceProperties[ prop.DevicePropertyCode ].displayName
	end
	return retVal
end

	
function PTP.Camera:getPropertyDisplayNameForValue( prop, val )
	local retVal = nil
	if PTP.DeviceProperties[ prop.DevicePropertyCode ] ~= nil then
		retVal = val
		if PTP.DeviceProperties[ prop.DevicePropertyCode ].displayNameForValue ~= nil then
			retVal = PTP.DeviceProperties[ prop.DevicePropertyCode ].displayNameForValue( prop, val )
		end
	end
	return retVal
end
