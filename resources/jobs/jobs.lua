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

local ped = nil

local function createOurPed( )
	if ped then
		destroyElement( ped )
	end
	
	ped = createPed( 211, 359.7, 173.65, 1008.4 )
	setPedRotation( ped, 270 )
	setElementDimension( ped, 1 )
	setElementInterior( ped, 3 )
end

addEventHandler( "onPedWasted", resourceRoot, createOurPed )
addEventHandler( "onResourceStart", resourceRoot, createOurPed )

--

local p = { }

addEventHandler( "onElementClicked", resourceRoot,
	function( button, state, player )
		if button == "left" and state == "up" then
			local x, y, z = getElementPosition( player )
			if getDistanceBetweenPoints3D( x, y, z, getElementPosition( source ) ) < 5 and getElementDimension( player ) == getElementDimension( source ) then
				p[ player ] = true
				
				local jobs = { }
				for key, value in ipairs( getResources( ) ) do
					if getResourceState( value ) == "running" and getResourceName( value ):sub( 1, 4 ) == "job-" then
						table.insert( jobs, getResourceName( value ):sub( 5, 5 ):upper( ) .. getResourceName( value ):sub( 6 ) )
					end
				end
				table.sort( jobs )
				
				triggerClientEvent( player, "jobs:open", source, jobs )
			end
		end
	end
)

addEventHandler( "onCharacterLogout", root,
	function( )
		if p[ source ] then
			p[ source ] = nil
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)

addEvent( "jobs:select", true )
addEventHandler( "jobs:select", root,
	function( key )
		if source == client and type( key ) == "string" then
			-- check if the player is even meant to select a job
			if p[ source ] then
				if exports.players:getJob( source ) == key then
					outputChatBox( "(( That's already your job. ))", source, 255, 0, 0 )
				else
					local res = getResourceFromName( "job-" .. key )
					if res and getResourceState( res ) == "running" then
						if exports.players:setJob( source, key ) then
							call( res, "introduce", source )
						end
						p[ source ] = nil
					end
				end
			end
		end
	end
)

addEvent( "jobs:close", true )
addEventHandler( "jobs:close", root,
	function( )
		if source == client then
			p[ source ] = nil
		end
	end
)
