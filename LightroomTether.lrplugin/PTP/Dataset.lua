require( 'vstruct' )



PTP.Dataset = {}


PTP.Dataset.UINT8 = {}
PTP.Dataset.UINT8.unpack = function( cur )
	return vstruct.unpack( "<u1", cur )[ 1 ]
end


PTP.Dataset.UINT8.pack = function( data )
	return vstruct.pack( "<u1", { data } )
end


PTP.Dataset.UINT16 = {}
PTP.Dataset.UINT16.unpack = function( cur )
	return vstruct.unpack( "<u2", cur )[ 1 ]
end


PTP.Dataset.UINT16.pack = function( data )
	return vstruct.pack( "<u2", { data } )
end


PTP.Dataset.UINT32 = {}
PTP.Dataset.UINT32.unpack = function( cur )
	return vstruct.unpack( "<u4", cur )[ 1 ]
end


PTP.Dataset.UINT32.pack = function( data )
	return vstruct.pack( "<u4", { data } )
end


PTP.Dataset.INT8 = {}
PTP.Dataset.INT8.unpack = function( cur )
	return vstruct.unpack( "<i1", cur )[ 1 ]
end


PTP.Dataset.INT8.pack = function( data )
	return vstruct.pack( "<i1", { data } )
end


PTP.Dataset.INT16 = {}
PTP.Dataset.INT16.unpack = function( cur )
	return vstruct.unpack( "<i2", cur )[ 1 ]
end


PTP.Dataset.INT16.pack = function( data )
	return vstruct.pack( "<i2", { data } )
end


PTP.Dataset.INT32 = {}
PTP.Dataset.INT32.unpack = function( cur )
	return vstruct.unpack( "<i4", cur )[ 1 ]
end


PTP.Dataset.INT32.pack = function( data )
	return vstruct.pack( "<i4", { data } )
end


PTP.Dataset.String = {}
PTP.Dataset.String.unpack = function( cur )
	local characters = ""
	
	local strLen = PTP.Dataset.UINT8.unpack( cur )
	if strLen ~= nil and strLen ~= 0 then
		local uniStr = vstruct.unpack( "s"..( strLen * 2 ), cur )[ 1 ]
		characters = string.gsub( uniStr, "([^%w%p%s])", "" )
	end
	return characters
end


PTP.Dataset.String.pack = function( data )
	local buf = PTP.Dataset.UINT8.pack( ( string.len( data ) + 1 ) * 2 )
	--TODO: one to many bytes in buffer?
	return buf..vstruct.pack( "ss2", { string.gsub( data, "([%w%p%s])", "%1\0" ), "\0\0" } )
end


PTP.Dataset.Array = {}
PTP.Dataset.Array.unpack = function( cur, typeParser )
	local self = {}

	local noElements = PTP.Dataset.UINT32.unpack( cur )
	if noElements ~= nil then
		for i = 1, noElements do
			local val = typeParser.unpack( cur )
			if val ~= nil then
				table.insert( self, val )
			end
		end
	end
	return self
end


PTP.Dataset.Range = {}
PTP.Dataset.Range.unpack = function( cur, typeParser )
	local self = {}
	
	self.Minimum 	= typeParser.unpack( cur )
	self.Maximum 	= typeParser.unpack( cur )
	self.Step 		= typeParser.unpack( cur )
	return self
end


PTP.Dataset.Enum = {}
PTP.Dataset.Enum.unpack = function( cur, typeParser )
	local self = {}
	
	local noEntries = PTP.Dataset.UINT16.unpack( cur )
	for i = 1, noEntries do
		table.insert( self, typeParser.unpack( cur ) )
	end
	return self
end


PTP.Dataset.DeviceInfo = {}
PTP.Dataset.DeviceInfo.unpack = function( cur )
	local self = {}
	
	self.PTPVersion 			= PTP.Dataset.UINT16.unpack( cur )
	self.MTPVendorExtensionID 	= PTP.Dataset.UINT32.unpack( cur )
	self.MTPVersion 			= PTP.Dataset.UINT16.unpack( cur )
	self.MTPExtensions 			= PTP.Dataset.String.unpack( cur )
	self.FunctionalMode 		= PTP.Dataset.UINT16.unpack( cur )
	self.OperationsSupported	= PTP.Dataset.Array.unpack( cur, PTP.Dataset.UINT16 )
	self.EventsSupported		= PTP.Dataset.Array.unpack( cur, PTP.Dataset.UINT16 )
	self.DeviceProperties		= PTP.Dataset.Array.unpack( cur, PTP.Dataset.UINT16 )
	self.CaptureFormats			= PTP.Dataset.Array.unpack( cur, PTP.Dataset.UINT16 )
	self.PlaybackFormats		= PTP.Dataset.Array.unpack( cur, PTP.Dataset.UINT16 )
	self.Manufacturer 			= PTP.Dataset.String.unpack( cur )
	self.Model		 			= PTP.Dataset.String.unpack( cur )
	self.DeviceVersion 			= PTP.Dataset.String.unpack( cur )
	self.SerialNumber 			= PTP.Dataset.String.unpack( cur )
	return self
end


PTP.Dataset.DevicePropDesc = {}
PTP.Dataset.DevicePropDesc.unpack = function( cur )
	local self = {}
	
	self.DevicePropertyCode = PTP.Dataset.UINT16.unpack( cur )
	self.Datatype			= PTP.Dataset.UINT16.unpack( cur )
	self.GetSet				= PTP.Dataset.UINT8.unpack( cur )	

	local datatype			= PTP.Dataset[ self.Datatype ]	
	self.FactoryDefault		= datatype.unpack( cur )
	self.Current			= datatype.unpack( cur )	

	self.Form				= nil
	self.FormFlag			= PTP.Dataset.UINT8.unpack( cur )	
	if self.FormFlag == 0x00 then
		-- none
	elseif self.FormFlag == 0x01 then
		-- Range
		self.Form				= PTP.Dataset.Range.unpack( cur, datatype )	
	elseif self.FormFlag == 0x02 then
		-- Enum
		self.Form				= PTP.Dataset.Enum.unpack( cur, datatype )
	else
		assert( nil, string.format( "invalid 'form' value: %x", self.FormFlag ) )
	end
	return self
end


PTP.Dataset.ObjectInfo = {}
PTP.Dataset.ObjectInfo.unpack = function( cur )
	local self = {}
	
	self.StorageID	 			= PTP.Dataset.UINT32.unpack( cur )
	self.ObjectFormat		 	= PTP.Dataset.UINT16.unpack( cur )
	self.ProtectionStatus		= PTP.Dataset.UINT16.unpack( cur )
	self.ObjectCompressedSize	= PTP.Dataset.UINT32.unpack( cur )
	self.ThumbFormat	 		= PTP.Dataset.UINT16.unpack( cur )
	self.ThumbCompressedSize	= PTP.Dataset.UINT32.unpack( cur )
	self.ThumbPixWidth			= PTP.Dataset.UINT32.unpack( cur )
	self.ThumbPixHeight			= PTP.Dataset.UINT32.unpack( cur )
	self.ImagePixWidth			= PTP.Dataset.UINT32.unpack( cur )
	self.ImagePixHeight			= PTP.Dataset.UINT32.unpack( cur )
	self.ImageBitDepth			= PTP.Dataset.UINT32.unpack( cur )
	self.ParentObject			= PTP.Dataset.UINT32.unpack( cur )
	self.AssociationType		= PTP.Dataset.UINT16.unpack( cur )
	self.AssociationDescription	= PTP.Dataset.UINT32.unpack( cur )
	self.SequenceNumber			= PTP.Dataset.UINT32.unpack( cur )	
	
	self.Filename	 			= PTP.Dataset.String.unpack( cur )
	self.DateCreated 			= PTP.Dataset.String.unpack( cur )
	self.DateModified 			= PTP.Dataset.String.unpack( cur )
	self.Keywords	 			= PTP.Dataset.String.unpack( cur )
	return self
end


PTP.Dataset[ 0x0000 ] = nil
PTP.Dataset[ 0x0001 ] = PTP.Dataset.INT8
PTP.Dataset[ 0x0002 ] = PTP.Dataset.UINT8
PTP.Dataset[ 0x0003 ] = PTP.Dataset.INT16
PTP.Dataset[ 0x0004 ] = PTP.Dataset.UINT16
PTP.Dataset[ 0x0005 ] = PTP.Dataset.INT32
PTP.Dataset[ 0x0006 ] = PTP.Dataset.UINT32
PTP.Dataset[ 0x0007 ] = PTP.Dataset.INT64
PTP.Dataset[ 0x0008 ] = PTP.Dataset.UINT64
PTP.Dataset[ 0x0009 ] = PTP.Dataset.INT128
PTP.Dataset[ 0x000A ] = PTP.Dataset.UINT128

PTP.Dataset[ 0x4001 ] = PTP.Dataset.AINT8
PTP.Dataset[ 0x4002 ] = PTP.Dataset.AUINT8
PTP.Dataset[ 0x4003 ] = PTP.Dataset.AINT16
PTP.Dataset[ 0x4004 ] = PTP.Dataset.AUINT16
PTP.Dataset[ 0x4005 ] = PTP.Dataset.AINT32
PTP.Dataset[ 0x4006 ] = PTP.Dataset.AUINT32
PTP.Dataset[ 0x4007 ] = PTP.Dataset.AINT64
PTP.Dataset[ 0x4008 ] = PTP.Dataset.AUINT64
PTP.Dataset[ 0x4009 ] = PTP.Dataset.AINT128
PTP.Dataset[ 0x400A ] = PTP.Dataset.AUINT128

PTP.Dataset[ 0xFFFF ] = PTP.Dataset.String
