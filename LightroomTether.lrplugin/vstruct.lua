-- This format function packs a list of integers into a binary string.
-- The sizes of the integers can be specified, both little and big endian
-- ordering are supported. The format parameter is a string composed of 
-- ASCII digit numbers, the size in bytes of the corresponding value.
-- Example:
--   write_format(true, "421", 0x12345678, 0x432931, 0x61) returns "xV4.1)a",
--     a 7 bytes string whose characters are in hex: 78 56 45 12 31 29 61
function write_format(little_endian, format, ...)
  local res = ''
  local values = {...}
  for i=1,#format do
    local size = tonumber(format:sub(i,i))
    local value = values[i]
    local str = ""
    for j=1,size do
      str = str .. string.char(value % 256)
      value = math.floor(value / 256)
    end
    if not little_endian then
      str = string.reverse(str)
    end
    res = res .. str
  end
  return res
end

-- This format function does the inverse of write_format. It unpacks a binary
-- string into a list of integers of specified size, supporting big and little 
-- endian ordering. Example:
--   read_format(true, "421", "xV4.1)a") returns 0x12345678, 0x2931 and 0x61.
function read_format(little_endian, format, str)
  local idx = 0
  local res = {} 
  for i=1,#format do
    local size = tonumber(format:sub(i,i))
    local val = str:sub(idx+1,idx+size)
    local value = 0
    idx = idx + size
    if little_endian then
      val = string.reverse(val)
    end
      
    for j=1,size do
      value = value * 256 + val:byte(j)
    end
    res[i] = value
  end
  return res -- unpack(res)
end



vstruct = {}

vstruct.cursor = function( str )
	self = { data = str }
	return self
end


vstruct.unpack = function( format, cur )
	local retVal = {}
	local len = 0
	
	if cur.data:len() ~= 0 then
		if format:sub( 1, 2 ) == "<i" then
			len = format:sub( 3 )
			retVal = read_format( true, len, cur.data )[ 1 ]
			highbit = retVal - ( 2 ^ ( ( len * 8 ) - 1 ) )
			if highbit > 0 then
				retVal = ( ( 2 ^ ( len * 8 ) ) - retVal ) * -1 
			end		
			retVal = { [1] = retVal }
		elseif format:sub( 1, 2 ) == "<u" then
			len = format:sub( 3 )
			retVal = read_format( true, len, cur.data )
		elseif format:sub( 1, 1 ) == "s" then
			len = format:sub( 2 )
			retVal = { [1] = cur.data:sub( 0, len ) }
		end
	
		cur.data = cur.data:sub( len + 1 ) 
	end
	return retVal
end
