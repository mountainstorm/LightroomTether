--[[----------------------------------------------------------------------------

Mountainstorm Photography

------------------------------------------------------------------------------]]


return {
	LrSdkVersion = 2.0,
	LrSdkMinimumVersion = 2.0,

	LrPluginName = "$$$/LightroomTether/PluginName=LightroomTether",
	LrToolkitIdentifier = 'com.mountainstorm.lightroomtether',
	
	LrExportMenuItems = {
		{
			title = "Begin Camera Tether",
			file = 'LtBeginTether.lua',
		},
	},

	VERSION = { major=4, minor=0, revision=3, build=1, },
}
