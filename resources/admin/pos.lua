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

addCommandHandler( { "getpos", "pos" },
	function( player, commandName )
		local x, y, z = getElementPosition( player )
		outputChatBox( "Position: " .. ( math.floor( x * 100 ) / 100 ) .. ", " .. ( math.floor( y * 100 ) / 100 ) .. ", " .. ( math.floor( z * 100 ) / 100 ), player, 0, 255, 153 )
		outputChatBox( "Interior: " .. getElementInterior( player ) .. ", Dimension: " .. getElementDimension( player ), player, 0, 255, 153 )
	end,
	true
)
