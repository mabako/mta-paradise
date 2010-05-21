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

local function destroy( element )
	if pickups[ element ] then
		destroyElement( pickups[ element ].pickup )
		pickups[ element ] = nil
	end
end

addEventHandler( "onClientRender", getRootElement( ),
	function( )
		-- get the camera matrix
		local cx, cy, cz = getCameraMatrix( )
		local dimension = getElementDimension( localPlayer )
		local interior = getElementInterior( localPlayer )
		
		-- loop through all vehicles you can buy
		local dimension = getElementDimension( localPlayer )
		for key, element in ipairs ( getElementsByType( "3dtext", resourceRoot ) ) do
			if getElementDimension( element ) == dimension and getElementInterior( element ) == interior then
				local px, py, pz = getElementPosition( element )
				local distance = getDistanceBetweenPoints3D( px, py, pz, cx, cy, cz )
				local text = getElementData( element, "text" )
				if distance <= 17.5 and text then
					if not pickups[ element ] then
						pickup = createPickup( px, py, pz, 3, 1239 )
						setElementInterior( pickup, interior )
						setElementDimension( pickup, dimension )
						
						pickups[ element ] = { pickup = pickup }
					end
					if isLineOfSightClear( cx, cy, cz, px, py, pz + 0.5, true, true, true, true, false, false, true, localPlayer ) then
						local sx, sy = getScreenFromWorldPosition( px, py, pz + 0.5 )
						if sx and sy then
							dxDrawText( tostring( text ), sx + 2, sy + 2, sx, sy, tocolor( 0, 0, 0, 255 ), 1, "default", "center", "center" )
							dxDrawText( tostring( text ), sx, sy, sx, sy, tocolor( 255, 255, 255, 255 ), 1, "default", "center", "center" )
						end
					end
				else
					destroy( element )
				end
			else
				destroy( element )
			end
		end
	end
)

addEventHandler( "onClientElementDestroy", resourceRoot,
	function( )
		destroy( source )
	end
)
