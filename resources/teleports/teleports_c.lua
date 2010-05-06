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

local localPlayer = getLocalPlayer( )
local pickups = { }

local function destroy( colshape )
	if pickups[ colshape ] then
		destroyElement( pickups[ colshape ].pickup )
		pickups[ colshape ] = nil
	end
end

addEventHandler( "onClientRender", getRootElement( ),
	function( )
		-- get the camera matrix
		local cx, cy, cz = getCameraMatrix( )
		
		-- loop through all vehicles you can buy
		local dimension = getElementDimension( localPlayer )
		for key, colshape in ipairs ( getElementsByType( "colshape", resourceRoot ) ) do
			if getElementDimension( colshape ) == dimension then
				local px, py, pz = getElementPosition( colshape )
				local distance = getDistanceBetweenPoints3D( px, py, pz, cx, cy, cz )
				if distance <= 17.5 then
					-- pickup to it
					if not pickups[ colshape ] then
						pickup = createPickup( px, py, pz, 3, 1318 )
						setElementInterior( pickup, getElementInterior( localPlayer ) )
						setElementDimension( pickup, dimension )
						
						pickups[ colshape ] = { pickup = pickup }
					end
				else
					destroy( colshape )
				end
			else
				destroy( colshape )
			end
		end
	end
)

addEventHandler( "onClientElementDestroy", resourceRoot,
	function( )
		destroy( source )
	end
)
