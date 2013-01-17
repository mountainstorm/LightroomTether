PTP.DevicePropertyCode = {}
PTP.DevicePropertyCode.kUndefined = 0x5000 
PTP.DevicePropertyCode.kBatteryLevel = 0x5001 
PTP.DevicePropertyCode.kFunctionalMode = 0x5002 
PTP.DevicePropertyCode.kImageSize = 0x5003 
PTP.DevicePropertyCode.kCompressionSetting = 0x5004 
PTP.DevicePropertyCode.kWhiteBalance = 0x5005 
PTP.DevicePropertyCode.kRGBGain = 0x5006 
PTP.DevicePropertyCode.kFNumber = 0x5007 
PTP.DevicePropertyCode.kFocalLength = 0x5008 
PTP.DevicePropertyCode.kFocusDistance = 0x5009 
PTP.DevicePropertyCode.kFocusMode = 0x500A 
PTP.DevicePropertyCode.kExposureMeteringMode = 0x500B 
PTP.DevicePropertyCode.kFlashMode = 0x500C 
PTP.DevicePropertyCode.kExposureTime = 0x500D 
PTP.DevicePropertyCode.kExposureProgramMode = 0x500E 
PTP.DevicePropertyCode.kExposureIndex = 0x500F 
PTP.DevicePropertyCode.kExposureBiasCompensation = 0x5010 
PTP.DevicePropertyCode.kDateTime = 0x5011 
PTP.DevicePropertyCode.kCaptureDelay = 0x5012 
PTP.DevicePropertyCode.kStillCaptureMode = 0x5013 
PTP.DevicePropertyCode.kContrast = 0x5014 
PTP.DevicePropertyCode.kSharpness = 0x5015 
PTP.DevicePropertyCode.kDigitalZoom = 0x5016 
PTP.DevicePropertyCode.kEffectMode = 0x5017 
PTP.DevicePropertyCode.kBurstNumber = 0x5018 
PTP.DevicePropertyCode.kBurstInterval = 0x5019 
PTP.DevicePropertyCode.kTimelapseNumber = 0x501A 
PTP.DevicePropertyCode.kTimelapseInterval = 0x501B 
PTP.DevicePropertyCode.kFocusMeteringMode = 0x501C 
PTP.DevicePropertyCode.kUploadURL = 0x501D 
PTP.DevicePropertyCode.kArtist = 0x501E 
PTP.DevicePropertyCode.kCopyrightInfo = 0x501F 
PTP.DevicePropertyCode.kSynchronizationPartner = 0xD401 
PTP.DevicePropertyCode.kDeviceFriendlyName = 0xD402 
PTP.DevicePropertyCode.kVolume = 0xD403 
PTP.DevicePropertyCode.kSupportedFormatsOrdered = 0xD404 
PTP.DevicePropertyCode.kDeviceIcon = 0xD405 
PTP.DevicePropertyCode.kPlaybackRate = 0xD410 
PTP.DevicePropertyCode.kPlaybackObject = 0xD411 
PTP.DevicePropertyCode.kPlaybackContainerIndex = 0xD412 
PTP.DevicePropertyCode.kSessionInitiatorVersionInfo = 0xD406


PTP.DeviceProperties = { 
	[ 0x5001 ] = { 
		displayName = "Battery Level", 
		displayNameForValue = function( prop, val )
			max = 100
			rge = 100
			if prop.FormFlag == 0x01 then
				-- range
				rge = prop.Form.Maximum - prop.Form.Minimum
			elseif prop.FormFlag == 0x02 then
				-- enum
				rge = prop.Form[ #( prop.Form ) ] - prop.Form[ 1 ]
			end
			
			retVal = ( ( rge / 100 ) * tonumber( val ) ).."%"
			if tonumber( val ) == 0 then
				retVal = "Aux"
			end
			return retVal
		end 
	},

	[ 0x5002 ] = { 
		displayName = "Functional Mode",
	},

	[ 0x5003 ] = { 
		displayName = "Image Size",
		increment = function( prop, val )
		end,
		decrement = function( prop, val )
		end
	},
	
	[ 0x5004 ] = { 
		displayName = "Quality (Compression)",
		displayNameForValue = function( prop, val )
			retVal = val
			vals = {}
			if prop.FormFlag == 0x01 then
				-- range
				vals[ prop.Form.Maximum ] = "(Max)"
				vals[ prop.Form.Minimum ] = "(Min)"
			elseif prop.FormFlag == 0x02 then
				-- enum
--TODO:				vals[ prop.Form[ #( prop.Form ) ] ] = "(Max)"
				vals[ prop.Form[ 1 ] ] = "(Min)"
			end
			
			if vals[ val ] ~= nil then
				retVal = retVal.." "..vals[ val ]
			end
			return retVal
		end
	},

	[ 0x5005 ] = { 
		displayName = "White Balance",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Manual",
					 [0x0002] = "Auto",
					 [0x0003] = "One Press",
					 [0x0004] = "Daylight",
					 [0x0005] = "Florescent",
					 [0x0006] = "Tungsten",
					 [0x0007] = "Flash" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[ 0x5006 ] = { 
		displayName = "RGB Gain",
		increment = function( prop, val )
		end,
		decrement = function( prop, val )
		end
	},

	[ 0x5007 ] = { 
		displayName = "F-Number ",
		displayNameForValue = function( prop, val )
			return string.format( "f/%0.1f", ( tonumber( val ) / 100 ) )
		end 
	},
	
	[ 0x5008 ] = { 
		displayName = "Focal Length",
		displayNameForValue = function( prop, val )
			return string.format( "%s mm", tonumber( val ) / 100 )
		end 
	},
	
	[ 0x5009 ] = { 
		displayName = "Focal Distance",
		displayNameForValue = function( prop, val )
			retVal = string.format( "%0.2f m", tonumber( val ) / 1000 )
			if val == 0xFFFF then
				retVal = "Infinity"
			end
			return retVal
		end 
	},

	[ 0x500A ] = { 
		displayName = "Focus Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Manual",
					 [0x0002] = "Automatic",
					 [0x0003] = "Macro" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[ 0x500B ] = { 
		displayName = "Metering Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Average",
					 [0x0002] = "Center-Weight",
					 [0x0003] = "Multi-Spot",
					 [0x0004] = "Center-Spot" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[ 0x500C ] = { 
		displayName = "Flash Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Auto",
					 [0x0002] = "Off",
					 [0x0003] = "Fill",
					 [0x0004] = "Red-eye Auto",
					 [0x0005] = "Red-eye Fill",
					 [0x0006] = "Ext Sync" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[ 0x500D ] = { 
		displayName = "Exposure Time",
		displayNameForValue = function( prop, val )
			retVal = string.format( "1/%d sec", 10000 / tonumber( val ) )
			if val >= 10000 then
				retVal = string.format( "%0.1f sec", tonumber( val ) / 10000 )
			end
			return retVal
		end 
	},

	[ 0x500E ] = { 
		displayName = "Program Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Manual",
					 [0x0002] = "Auto",
					 [0x0003] = "Aperture",
					 [0x0004] = "Shutter",
					 [0x0005] = "Creative",
					 [0x0006] = "Action",
					 [0x0007] = "Portrait" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[ 0x500F ] = { 
		displayName = "Exposure Index",
		displayNameForValue = function( prop, val )
			retVal = "ISO "..val
			if val == 0xFFFF then
				val = "AutoISO"
			end
			return retVal
		end 
	},
	
	[ 0x5010 ] = { 
		displayName = "Exposure Compensation",
		displayNameForValue = function( prop, val )
			sign = " "
			if val > 0 then	
				sign = "+"
			end
			return string.format( "%s%0.1f ev", sign, tonumber( val ) / 1000 )
		end 
	},
	
	[ 0x5011 ] = { 
		displayName = "Date/Time",
		displayNameForValue = function( prop, val )
			year   = val:sub( 1, 4 )
			month  = val:sub( 5, 6 )
			day    = val:sub( 7, 8 )
			hour   = val:sub( 10, 11 )
			min    = val:sub( 12, 13 )
			second = val:sub( 14, 15 )
			rest   = val:sub( 16 )
			return string.format( "%s:%s:%s %s:%s:%s%s", year, month, day, hour, min, second, rest )
		end 
	},
	
	[ 0x5013 ] = { 
		displayName = "Capture Delay",
		displayNameForValue = function( prop, val )
			return string.format( "%0.1f secs", tonumber( val ) / 1000 )
		end 
	},
	
	[ 0x5013 ] = { 
		displayName = "Capture Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Normal",
					 [0x0002] = "Burst",
					 [0x0003] = "Timelapse" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	
	
	[ 0x5014 ] = { 
		displayName = "Contrast",
		displayNameForValue = function( prop, val )
			retVal = val
			vals = {}
			if prop.FormFlag == 0x01 then
				-- range
				vals[ prop.Form.Maximum ] = "(Low)"
				vals[ prop.Form.Minimum ] = "(High)"
			elseif prop.FormFlag == 0x02 then
				-- enum
--TODO:				vals[ prop.Form[ #( prop.Form ) ] ] = "(Low)"
				vals[ prop.Form[ 1 ] ] = "(High)"
			end
			
			if vals[ val ] ~= nil then
				retVal = retVal.." "..vals[ val ]
			end
			return retVal
		end 
	},	

	[ 0x5015 ] = { 
		displayName = "Sharpness",
		displayNameForValue = function( prop, val )
			retVal = val
			vals = {}
			if prop.FormFlag == 0x01 then
				-- range
				vals[ prop.Form.Maximum ] = "(Low)"
				vals[ prop.Form.Minimum ] = "(High)"
			elseif prop.FormFlag == 0x02 then
				-- enum
--TODO:				vals[ prop.Form[ #( prop.Form ) ] ] = "(Low)"
				vals[ prop.Form[ 1 ] ] = "(High)"
			end
			
			if vals[ val ] ~= nil then
				retVal = retVal.." "..vals[ val ]
			end
			return retVal
		end 
	},	

	[ 0x5016 ] = { 
		displayName = "Digital Zoom",
		displayNameForValue = function( prop, val )
			retVal = "x"..( val / 10 )
			if val == 10 then
				retVal = "None"
			end
			return retVal
		end 
	},	

	[ 0x5017 ] = { 
		displayName = "Effect Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Colour",
					 [0x0002] = "B&W",
					 [0x0003] = "Sepia" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	

	[ 0x5018 ] = { 
		displayName = "Burst Length",
	},	

	[ 0x5019 ] = { 
		displayName = "Burst Speed",
		displayNameForValue = function( prop, val )
			return string.format( "%0.1f ms", retVal / 1000 )
		end 
	},	

	[ 0x501A ] = { 
		displayName = "Timelapse Length",
	},	

	[ 0x501B ] = { 
		displayName = "Timelapse Speed",
		displayNameForValue = function( prop, val )
			return string.format( "%0.1f ms", retVal / 1000 )
		end 
	},	

	[ 0x501C ] = { 
		displayName = "Focus Metering Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Center-Spot",
					 [0x0002] = "Multi-Spot" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[ 0x501D ] = { 
		displayName = "Upload URL"
	},
	
	[ 0x501E ] = { 
		displayName = "Artist"
	},

	[ 0x501F ] = { 
		displayName = "Copyright"
	},

	[ 0xD401 ] = { 
		displayName = "Synchronization Partner"
	},
	
	[ 0xD402 ] = { 
		displayName = "Device Name"
	},

	[ 0xD403 ] = { 
		displayName = "Volume",
		displayNameForValue = function( prop, val )
			retVal = val
			if val == 0 then
				retVal = "Mute"
			end
			return retVal
		end
	},

	[ 0xD404 ] = { 
		displayName = "Formats Ordered",
		displayNameForValue = function( prop, val )
			retVal = "Unordered"
			vals = { [0x0001] = "Ordered" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end
	},
	
	-- 0xD405 Device Icon
	-- 0xD406 Session Initiator Version Info 
	-- 0xD407 Perceived Device Type 
	
	-- 0xD410 Playback Rate
	-- 0xD411 Playboack Object
	-- 0xD412 Playboack Container Info
	-- 0xD413 Playboack Position
	
}
			
