--[[----------------------------------------------------------------------------

Mountainstorm Photography

--------------------------------------------------------------------------------

Pickle.lua
Provides a function to pickle a data variable into a lua string

------------------------------------------------------------------------------]]



local Pickle = {}


function Pickle:pickle( tt )
	local retVal = ""
	
	local ts = type( tt )
	if ts == "nil" then
		retVal = "nil"
	elseif ts == "number" then
		retVal = tostring( tt )
	elseif ts == "string" then
		local str = string.gsub( tt, '"', '\\"' )
		str = string.gsub( str, '\\', '\\\\' )
		retVal = "\""..str.."\""
	elseif ts == "boolean" then
		retVal = "false"
		if tt == true then
			retVal = "true"
		end
	elseif ts == "table" then
		local first = true
		retVal = "{"
		for k, v in pairs( tt ) do
			if first == false then
				retVal = retVal..","
			end
			retVal = retVal.."["..Pickle:pickle( k ).."]="..Pickle:pickle( v )
			first = false
		end
		retVal = retVal.."}"
	else
		-- its a function, thread or userdata - oops
		print( "unable to dump object, type: "..ts )
	end
	return retVal
end


return Pickle
