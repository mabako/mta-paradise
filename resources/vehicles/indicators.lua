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

addEvent( "i:left", true )
addEventHandler( "i:left", resourceRoot,
	function( state )
		if client and source == getPedOccupiedVehicle( client ) then
			setElementData( source, "i:left", state )
		end
	end
)

addEvent( "i:right", true )
addEventHandler( "i:right", resourceRoot,
	function( state )
		if client and source == getPedOccupiedVehicle( client ) then
			setElementData( source, "i:right", state )
		end
	end
)
