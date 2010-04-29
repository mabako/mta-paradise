--[[
Copyright (c) 2010 MTA: Paradise

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
]]

local vehicleColors
function getRandomVehicleColor( vehicle )
	-- load the vehicle colors
	if not vehicleColors then
		-- function to read a single line
		local function fileReadLine( file )
			local buffer = ""
			local tmp
			repeat
				tmp = fileRead( file, 1 ) or nil
				if tmp and tmp ~= "\r" and tmp ~= "\n" then
					buffer = buffer .. tmp
				end
			until not tmp or tmp == "\n" or tmp == ""
			
			return buffer
		end
		
		-- read the file
		vehicleColors = { }
		local file = fileOpen( "vehiclecolors.conf", true )
		while not fileIsEOF( file ) do
			local line = fileReadLine( file )
			if #line > 0 and line:sub( 1, 1 ) ~= "#" then
				local model = tonumber( gettok( line, 1, string.byte(' ') ) )
				if not vehicleColors[ model ] then
					vehicleColors[ model ] = { }
				end
				vehicleColors[ model ][ #vehicleColors[ model ] + 1 ] = {
					tonumber( gettok( line, 2, string.byte(' ') ) ),
					tonumber( gettok( line, 3, string.byte(' ') ) ) or nil,
					-- tonumber( gettok( line, 4, string.byte(' ') ) ) or nil, -- We only use the first two vehicle colors anyway
					-- tonumber( gettok( line, 5, string.byte(' ') ) ) or nil
				}
			end
		end
		fileClose( file )
	end
	
	local colors = vehicleColors[ getElementModel( vehicle ) ]
	if colors then
		return unpack( colors[ math.random( 1, #colors ) ] )
	end
end
