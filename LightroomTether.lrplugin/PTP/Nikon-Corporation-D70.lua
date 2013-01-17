PTP.NikonCorporation = {}


PTP.NikonCorporation.DevicePropertyCode = {}
--PTP.NikonCorporation.DevicePropertyCode.


PTP.NikonCorporation.DeviceProperties = {
	[0x5004] =  { 
		groupName = "Controls",
		displayName = "Quality", 
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = {
				[0x00] = "JPEG (Basic)",
				[0x01] = "JPEG (Normal)",
				[0x02] = "JPEG (Fine)",
				[0x03] = "RAW",
				[0x04] = "RAW + JPEG (Basic)",
				[0x05] = "RAW + JPEG (Normal)",
				[0x06] = "RAW + JPEG (Fine)" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[ 0x5005 ] = { 
		groupName = "Controls",
		displayName = "White Balance",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0002] = "Auto",
					 [0x0004] = "Sunny",
					 [0x0005] = "Florescent",
					 [0x0006] = "Incandescent",
					 [0x0007] = "Flash",
					 [0x8010] = "Cloudy",
					 [0x8011] = "Shade",
					 [0x8012] = "Color Temp",
					 [0x8013] = "Preset" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	

	[ 0x500A ] = { 
		groupName = "Controls",
		displayName = "Focus Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "MF",
					 [0x8010] = "AF-S",
					 [0x8011] = "AF-C",
					 [0x8012] = "AF-A" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[ 0x500C ] = { 
		groupName = "Controls",
		displayName = "Flash Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0002] = "Off",
					 [0x0004] = "Red-eye Auto",
					 [0x8010] = "Normal Sync",
					 [0x8011] = "Slow Sync",
					 [0x8012] = "Rear Sync",
					 [0x8013] = "Red-eye Slow Sync" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[ 0x500E ] = { 
		groupName = "Controls",
		displayName = "Program Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Manual",
					 [0x0002] = "Auto",
					 [0x0003] = "Aperture",
					 [0x0004] = "Shutter",
					 [0x8010] = "Auto mode",
					 [0x8011] = "Portrait",
					 [0x8012] = "Landscape",
					 [0x8013] = "Close-up",
					 [0x8014] = "Sports",
					 [0x8015] = "Night Portrait",
					 [0x8016] = "Night Landscape" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[ 0x5010 ] = { 
		groupName = "Controls",
		displayName = "Exposure Compensation",
		displayNameForValue = function( prop, val )
-- TODO: scale by exposure step 0xD056
			sign = " "
			if val > 0 then	
				sign = "+"
			end
			return string.format( "%s%0.1f ev", sign, tonumber( val ) / 1000 )
		end 
	},	
	
	[ 0x5013 ] = { 
		groupName = "Controls",
		displayName = "Capture Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0001] = "Single Short",
					 [0x0002] = "Continuous",
					 [0x8011] = "Self Timer",
					 [0x8013] = "Remote",
					 [0x8014] = "Delay Remote" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	

	[ 0x5018 ] = { 
		groupName = "?"
		displayName = "Burst Number",
		displayNameForValue = function( prop, val )
			--TODO: complex calculation on the max number of images
			return retVal
		end 
	},	
	
	[ 0x501C ] = { 
		groupName = "Controls",	
		displayName = "Focus Metering Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0x0002] = "Dynamic",
					 [0x8010] = "Single Area", 
					 [0x8011] = "Auto Area" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD140] = {
		groupName = "Shooting",
		displayName = "Image Setting",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Normal",
					 [1] = "Softer", 
					 [2] = "Vivid",
					 [3] = "More Vivid",
					 [4] = "Portrait",
					 [5] = "Custom",
					 [6] = "B&W" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD02A] = {
		groupName = "Shooting",
		displayName = "Sharpness",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Auto",
					 [1] = "Normal", 
					 [2] = "Low",
					 [3] = "Medium Low",
					 [4] = "Medium High",
					 [5] = "High",
					 [6] = "None" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD02B] = {
		groupName = "Shooting",
		displayName = "Contrast",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Auto",
					 [1] = "Normal", 
					 [2] = "Low",
					 [3] = "Medium Low",
					 [4] = "Medium High",
					 [5] = "High",
					 [6] = "Custom" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD02C] = {
		groupName = "Shooting",
		displayName = "Colour Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Mode Ia",
					 [1] = "Mode II", 
					 [2] = "Mode IIIa" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD142] = {
		groupName = "Shooting",
		displayName = "Saturation",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Auto",
					 [1] = "Normal", 
					 [2] = "Moderate",
					 [2] = "Enhanced" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD02D] = {
		groupName = "Shooting",
		displayName = "Colur Adjust",
		displayNameForValue = function( prop, val )
			return val.." deg"
		end 
	},

	[0xD146] = {
		groupName = "Shooting",
		displayName = "Monochrome Setting Type",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Standard",
					 [1] = "Custom" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD144] = {
		groupName = "Shooting",
		displayName = "Monochrome Sharpness",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Auto",
					 [1] = "Normal", 
					 [2] = "Low", 
					 [3] = "Medium Low", 
					 [4] = "Medium High", 
					 [5] = "High", 
					 [6] = "None" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD145] = {
		groupName = "Shooting",
		displayName = "Monochrome Contrast",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Auto",
					 [1] = "Normal", 
					 [2] = "Low", 
					 [3] = "Medium Low", 
					 [4] = "Medium High", 
					 [5] = "High", 
					 [6] = "Custom" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD143] = {
		groupName = "Shooting",
		displayName = "Filter Effect",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "Yellow", 
					 [2] = "Orange", 
					 [3] = "Red", 
					 [4] = "Green" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD1017] = {
		groupName = "Shooting",	
		displayName = "WB Tune Auto",
	},

	[0xD1018] = {
		groupName = "Shooting",
		displayName = "WB Tune Incandescent",
	},

	[0xD1019] = {
		groupName = "Shooting",
		displayName = "WB Tune Fluorescent",
	},

	[0xD101A] = {
		groupName = "Shooting",
		displayName = "WB Tune Sunny",
	},

	[0xD101B] = {
		groupName = "Shooting",
		displayName = "WB Tune Flash",
	},
	
	[0xD101C] = {
		groupName = "Shooting",
		displayName = "WB Tune Cloudy",
	},

	[0xD101D] = {
		groupName = "Shooting",
		displayName = "WB Tune Shade",
	},
	
	[0xD101E] = {
		groupName = "Shooting",
		displayName = "WB Colour Temp",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "2500K",
					 [1] = "2550K", 
					 [2] = "2650K", 
					 [3] = "2700K", 
					 [4] = "2800K", 
					 [5] = "2850K", 
					 [6] = "2950K", 
					 [7] = "3000K", 
					 [8] = "3100K", 
					 [9] = "3200K", 
					 [10] = "3300K", 
					 [11] = "3400K", 
					 [12] = "3600K", 
					 [13] = "3700K", 
					 [14] = "3800K", 
					 [15] = "4000K", 
					 [16] = "4200K", 
					 [17] = "4300K", 
					 [18] = "4500K", 
					 [19] = "4800K", 
					 [20] = "5000K", 
					 [21] = "5300K", 
					 [22] = "5600K",
					 [23] = "5900K", 
					 [24] = "6300K", 
					 [25] = "6700K", 
					 [26] = "7100K", 
					 [27] = "7700K", 
					 [28] = "8300K", 
					 [29] = "9100K",
					 [30] = "9900K" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD101F] = {
		groupName = "Shooting",
		displayName = "WB Preset",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "D0",
					 [1] = "D1" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	
	
	-- TODO hide 0xD025 WbPresetDataValue0
	-- TODO hide 0xD026 WbPresetDataValue1

	[0xD16A] = {
		groupName = "Shooting",
		displayName = "ISO Auto",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "On",
					 [1] = "Off" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	
	
	[0xD06B] = {
		groupName = "Shooting",
		displayName = "Noise Reduction",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "On",
					 [1] = "Off" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	
	
	[0xD070] = {
		groupName = "Shooting",
		displayName = "Noise Reduction Hi ISO",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "Low",
					 [2] = "Medium",
					 [3] = "High" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	
	
	-- TODO: reset cusom menu
	
	[0xD160] = {
		groupName = "Custom Menu",
		displayName = "Beep",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "On",
					 [1] = "Off" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	

	[0xD052] = {
		groupName = "Custom Menu",
		displayName = "Focus Area",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "11 Point",
					 [1] = "7 Point" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	

	[0xD163] = {
		groupName = "Custom Menu",
		displayName = "AF Light",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "On",
					 [1] = "Off" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	

	[0xD08A] = {
		groupName = "Custom Menu",
		displayName = "No Card - Shutter",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Enabled",
					 [1] = "Locked" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},	
	
	[0xD165] = {
		groupName = "Custom Menu",
		displayName = "Image Review",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "On",
					 [1] = "Off" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD054] = {
		groupName = "Custom Menu",
		displayName = "Auto ISO",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "On" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD183] = {
		groupName = "Custom Menu",
		displayName = "Auto ISO High Limit",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "ISO 200",
					 [1] = "ISO 400",
					 [2] = "ISO 800",
					 [3] = "ISO 1600" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD184] = {
		groupName = "Custom Menu",
		displayName = "Auto ISO Shutter Time",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1/125 sec",
					 [1] = "1/100 sec",
					 [2] = "1/80 sec",
					 [3] = "1/60 sec",
					 [4] = "1/40 sec",
					 [5] = "1/30 sec",
					 [6] = "1/15 sec",
					 [7] = "1/8 sec",
					 [8] = "1/4 sec",
					 [9] = "1/2 sec",
					 [10] = "1 sec" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD16C] = {
		groupName = "Custom Menu",
		displayName = "Grid Display",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "On" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD181] = {
		groupName = "Custom Menu",
		displayName = "Finder Warning",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "On",
					 [1] = "Off" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD056] = {
		groupName = "Custom Menu",
		displayName = "Exposure EV Step",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1/3 ev",
					 [1] = "1/2 ev",
					 [2] = "1 ev" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD058] = {
		groupName = "Custom Menu",
		displayName = "Exposure Compensation",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "On" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD059] = {
		groupName = "Custom Menu",
		displayName = "Center Weight Range",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "6mm",
					 [1] = "8mm",
					 [2] = "10mm" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD078] = {
		groupName = "Custom Menu",
		displayName = "Bracketing",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "AE/SB",
					 [1] = "AE",
					 [2] = "SB",
					 [2] = "WB" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD07A] = {
		groupName = "Custom Menu",
		displayName = "Bracketing Order",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Default",
					 [1] = ">MTR>" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD086] = {
		groupName = "Custom Menu",
		displayName = "Command Dial Change",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Default",
					 [1] = "Reversed" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD084] = {
		groupName = "Custom Menu",
		displayName = "Function Button",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "ISO Display",
					 [1] = "Framing Grid",
					 [2] = "AF Area",
					 [3] = "Center AF",
					 [4] = "FV Lock",
					 [5] = "Flash Off",
					 [6] = "Matrix Meter",
					 [7] = "Center Weight Meter",
					 [8] = "Spot Meter" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD06F] = {
		groupName = "Custom Menu",	
		displayName = "LCD Illumination",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "On" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD05F] = {
		groupName = "Custom Menu",
		displayName = "AE/AF/FLock",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "AE/AF Lock",
					 [1] = "AE Lock",
					 [2] = "AF Lock",
					 [3] = "AE Lock Hold",
					 [4] = "AF-On",
					 [5] = "FV Lock",
					 [6] = "Focus Area",
					 [7] = "AE-L/AF-L/Focus Area",
					 [8] = "AE-L/Focus Area",
					 [9] = "AF-L/Focus Area",
					 [10] = "AF-ON/Focus Area" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD05E] = {
		groupName = "Custom Menu",
		displayName = "AE Lock Release",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "On" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD04F] = {
		groupName = "Custom Menu",
		displayName = "Focus Area",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Wrap",
					 [1] = "No Wrap" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD166] = {
		groupName = "Custom Menu",
		displayName = "Focus Area LED",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Auto",
					 [1] = "Off",
					 [2] = "On" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD167] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "TTL",
					 [1] = "Manual",
					 [2] = "Repeating",
					 [3] = "Commander" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD16D] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Manual",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Full",
					 [1] = "1/2",
					 [2] = "1/4",
					 [3] = "1/8",
					 [4] = "1/16",
					 [5] = "1/32",
					 [6] = "1/64",
					 [7] = "1/128" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD1D0] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Manual Repeat Intensity",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1/4",
					 [1] = "1/8",
					 [2] = "1/16",
					 [3] = "1/32",
					 [4] = "1/64",
					 [5] = "1/128" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD1D1] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Manual Repeat Count",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "2",
					 [1] = "3",
					 [2] = "4",
					 [3] = "5",
					 [4] = "6",
					 [5] = "7",
					 [6] = "8",
					 [7] = "9",
					 [8] = "10",
					 [9] = "15",
					 [10] = "20",
					 [11] = "25",
					 [12] = "30",
					 [13] = "35" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD1D2] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Manual Repeat Interval",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1",
					 [1] = "2",
					 [2] = "3",
					 [3] = "4",
					 [4] = "5",
					 [5] = "6",
					 [6] = "7",
					 [7] = "8",
					 [8] = "9",
					 [9] = "10",
					 [10] = "20",
					 [11] = "30",
					 [12] = "40",
					 [13] = "50" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD1D3] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Ch",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1",
					 [1] = "2",
					 [2] = "3",
					 [3] = "4" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD1D4] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "TTL",
					 [1] = "M",
					 [2] = "Non-Flash" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD1D5] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Compensation",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "-3.0 ev",
					 [1] = "-2.7 ev",
					 [2] = "-2.3 ev",
					 [3] = "-2.0 ev",
					 [4] = "-1.7 ev",
					 [5] = "-1.3 ev",
					 [6] = "-1.0 ev",
					 [7] = "-0.7 ev",
					 [8] = "-0.3 ev",
					 [9] = "0 ev",
					 [10] = "+0.3 ev",
					 [11] = "+0.7 ev",
					 [12] = "+1.0 ev",
					 [13] = "+1.3 ev",
					 [14] = "+1.7 ev",
					 [15] = "+2.0 ev",
					 [16] = "+2.3 ev",
					 [17] = "+2.7 ev",
					 [18] = "+3.0 ev" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD1D6] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Intensity",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1/1",
					 [1] = "1/2",
					 [2] = "1/4",
					 [3] = "1/8",
					 [4] = "1/16",
					 [5] = "1/32",
					 [6] = "1/64",
					 [7] = "1/128" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD1D7] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Group A Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "TTL",
					 [1] = "AA",
					 [2] = "M",
					 [3] = "Non-Flash" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD1D8] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Group A Compensation",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "-3.0 ev",
					 [1] = "-2.7 ev",
					 [2] = "-2.3 ev",
					 [3] = "-2.0 ev",
					 [4] = "-1.7 ev",
					 [5] = "-1.3 ev",
					 [6] = "-1.0 ev",
					 [7] = "-0.7 ev",
					 [8] = "-0.3 ev",
					 [9] = "0 ev",
					 [10] = "+0.3 ev",
					 [11] = "+0.7 ev",
					 [12] = "+1.0 ev",
					 [13] = "+1.3 ev",
					 [14] = "+1.7 ev",
					 [15] = "+2.0 ev",
					 [16] = "+2.3 ev",
					 [17] = "+2.7 ev",
					 [18] = "+3.0 ev" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD1D9] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Group A Intensity",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1/1",
					 [1] = "1/2",
					 [2] = "1/4",
					 [3] = "1/8",
					 [4] = "1/16",
					 [5] = "1/32",
					 [6] = "1/64",
					 [7] = "1/128" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD1DA] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Group B Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "TTL",
					 [1] = "AA",
					 [2] = "M",
					 [3] = "Non-Flash" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD1DB] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Group B Compensation",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "-3.0 ev",
					 [1] = "-2.7 ev",
					 [2] = "-2.3 ev",
					 [3] = "-2.0 ev",
					 [4] = "-1.7 ev",
					 [5] = "-1.3 ev",
					 [6] = "-1.0 ev",
					 [7] = "-0.7 ev",
					 [8] = "-0.3 ev",
					 [9] = "0 ev",
					 [10] = "+0.3 ev",
					 [11] = "+0.7 ev",
					 [12] = "+1.0 ev",
					 [13] = "+1.3 ev",
					 [14] = "+1.7 ev",
					 [15] = "+2.0 ev",
					 [16] = "+2.3 ev",
					 [17] = "+2.7 ev",
					 [18] = "+3.0 ev" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD1DC] = {
		groupName = "Custom Menu",
		displayName = "Internal Flash Commander Group B Intensity",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1/1",
					 [1] = "1/2",
					 [2] = "1/4",
					 [3] = "1/8",
					 [4] = "1/16",
					 [5] = "1/32",
					 [6] = "1/64",
					 [7] = "1/128" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD169] = {
		groupName = "Custom Menu",
		displayName = "Flash Display",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "On",
					 [1] = "Off" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD075] = {
		groupName = "Custom Menu",
		displayName = "Flash Speed Limit",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1/60 sec",
					 [1] = "1/30 sec",
					 [2] = "1/15 sec",
					 [3] = "1/8 sec",
					 [4] = "1/4 sec",
					 [5] = "1/2 sec",
					 [6] = "1 sec",
					 [7] = "2 sec",
					 [8] = "4 sec",
					 [9] = "8 sec",
					 [10] = "15 sec",
					 [11] = "30 sec" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD16F] = {
		groupName = "Custom Menu",
		displayName = "Auto FP Shoot",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "On" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD077] = {
		groupName = "Custom Menu",
		displayName = "Modeling Preview",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "On",
					 [1] = "Off" } 
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD064] = {
		groupName = "Custom Menu",
		displayName = "LCD Power Off",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "5 sec",
					 [1] = "10 sec",
					 [2] = "20 sec",
					 [3] = "1 min",
					 [4] = "5 min",
					 [5] = "10 min" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD062] = {
		groupName = "Custom Menu",
		displayName = "Auto Meter Off",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "4 sec",
					 [1] = "6 sec",
					 [2] = "8 sec",
					 [3] = "16 sec",
					 [4] = "30 sec",
					 [5] = "30 min" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD063] = {
		groupName = "Custom Menu",
		displayName = "Self Timer Delay",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "2 sec",
					 [1] = "5 sec",
					 [2] = "10 sec",
					 [3] = "20 sec" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD16B] = {
		groupName = "Custom Menu",
		displayName = "Remote Control Delay",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1 min",
					 [1] = "1.5 min",
					 [2] = "10 min",
					 [3] = "15 min" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD06A] = {
		groupName = "Custom Menu",
		displayName = "Exposure Delay",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "On" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD182] = {
		groupName = "Custom Menu",
		displayName = "Cell Kind",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "LR6",
					 [1] = "HR6",
					 [2] = "FR6",
					 [3] = "ZR6" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD06C] = {
		groupName = "Setup",
		displayName = "Numbering Mode",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "On",
					 [2] = "Reset" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD182] = {
		groupName = "Setup",
		displayName = "Comment",
	},

	[0xD091] = {
		groupName = "Setup",
		displayName = "Attach Comment",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Off",
					 [1] = "On" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD092] = {
		groupName = "Setup",
		displayName = "Sensor Orientation",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "On",
					 [1] = "Off" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD10B] = {
		groupName = "Camera Control",
		displayName = "Recording Media",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "SD Card",
					 [1] = "SDRAM" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD0C0] = {
		groupName = "Camera Control",
		displayName = "Bracketting",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "Disabled",
					 [1] = "Enabled" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD0C1] = {
		groupName = "Camera Control",
		displayName = "AE Bracketting Step",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1/3 ev",
					 [1] = "1/2 ev",
					 [2] = "2/3 ev",
					 [3] = "1 ev",
					 [4] = "1 1/3 ev",
					 [5] = "1 1/2 ev",
					 [6] = "1 2/3 ev",
					 [7] = "2 ev" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD0C2] = {
		groupName = "Camera Control",
		displayName = "AE Bracketting Pattern",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "No Image",
					 [1] = "2 in -",
					 [2] = "2 in +",
					 [3] = "3 in + & -" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD0C3] = {
		groupName = "Camera Control",
		displayName = "AE Bracketting Count"
	},

	[0xD0C4] = {
		groupName = "Camera Control",
		displayName = "WB Bracketting Step",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "1 ev",
					 [1] = "2 ev",
					 [2] = "3 ev" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},

	[0xD0C5] = {
		groupName = "Camera Control",
		displayName = "WB Bracketting Pattern",
		displayNameForValue = function( prop, val )
			retVal = "Undefined"
			vals = { [0] = "No Image",
					 [1] = "2 in -",
					 [2] = "2 in +",
					 [3] = "3 in + & -" }
			if vals[ val ] ~= nil then
				retVal = vals[ val ]
			end
			return retVal
		end 
	},
	
	[0xD100] = {
		groupName = "Controls",
		displayName = "Shutter Speed",
		displayNameForValue = function( prop, val )
			if val == 0xFFFFFFFF then
				retVal = "Bulb"
			else
				-- TODO: modified by EV Step
				local numerator = math.floor( val / 65536 )
				local denominator = math.floor( val - ( numerator * 65536 ) )
				if ( numerator / denominator ) > 1 then
					retVal = ( numerator / denominator ).." sec"
				else
					retVal = numerator.."/"..denominator.." sec"
				end
			end
			return retVal
		end 
	},	
}





PTP.NikonCorporation.Camera = {}


function PTP.NikonCorporation.Camera:new()
	return setmetatable( { }, 
						 { __index = PTP.NikonCorporation.Camera } )
end


-- processing actions
function PTP.NikonCorporation.Camera:getPropertyDisplayName( prop )
	local retVal = nil
	if PTP.NikonCorporation.DeviceProperties[ prop.DevicePropertyCode ] ~= nil then
		retVal = PTP.NikonCorporation.DeviceProperties[ prop.DevicePropertyCode ].displayName
	else
		retVal = PTP.Camera.getPropertyDisplayName( self, prop )
	end
	return retVal
end

	
function PTP.NikonCorporation.Camera:getPropertyDisplayNameForValue( prop, val )
	local retVal = nil
	if PTP.NikonCorporation.DeviceProperties[ prop.DevicePropertyCode ] ~= nil then
		retVal = val
		if PTP.NikonCorporation.DeviceProperties[ prop.DevicePropertyCode ].displayNameForValue ~= nil then
			retVal = PTP.NikonCorporation.DeviceProperties[ prop.DevicePropertyCode ].displayNameForValue( prop, val )
		end
	else
		retVal = PTP.Camera.getPropertyDisplayNameForValue( self, prop, val )
	end
	return retVal
end


return function( cam )
	setmetatable( PTP.NikonCorporation.Camera, { __index = cam } )
	return PTP.NikonCorporation.Camera:new()
end
