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

local p = { }

addEvent( "nametags:chatbubble", true )
addEventHandler( "nametags:chatbubble", root,
	function( state )
		if source == client then
			-- since you can't request the state for your local player anyway, here we go for syncing it
			if state == true or state == false or state == 1 then
				if state == true then
					p[ source ] = true
				else
					p[ source ] = nil
				end
				
				local x, y, z = getElementPosition( source )
				local dimension = getElementDimension( source )
				local interior = getElementInterior( source )
				
				for key, player in ipairs( getElementsByType( "player" ) ) do
					if player ~= source and getElementDimension( player ) == dimension and getElementInterior( player ) == interior and getDistanceBetweenPoints3D( x, y, z, getElementPosition( player ) ) < 250 then
						triggerClientEvent( player, "nametags:chatbubble", source, state )
					end
				end
			end
		else
			-- remote player has a chat bubble, thus tell the client. if not, this is called by streaming in and can be ignored
			if p[ source ] then
				triggerClientEvent( client, "nametags:chatbubble", source, true )
			end
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)
