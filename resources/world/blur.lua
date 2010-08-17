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

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		local xml = xmlLoadFile( "blur.xml" )
		if xml then
			local blur = tonumber( xmlNodeGetValue( xml ) )
			if blur and blur >= 0 and blur <= 255 then
				setBlurLevel( blur )
			else
				-- default: blur is off
				setBlurLevel( 0 )
			end
			xmlUnloadFile( xml )
		else
			-- default: blur is off
			setBlurLevel( 0 )
		end
	end
)

addCommandHandler( "toggleblur",
	function( )
		local blur = getBlurLevel( ) == 0 and 38 or 0
		local xml = xmlCreateFile( "blur.xml", "blur" )
		if xml then
			xmlNodeSetValue( xml, tostring( blur ) )
			xmlSaveFile( xml )
			xmlUnloadFile( xml )
		end
		outputChatBox( "Blur is " .. ( blur == 0 and "dis" or "en" ) .. "abled.", 0, 255, 0 )
		setBlurLevel( blur )
	end
)
