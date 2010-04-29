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
				if distance < 10 then
					-- pickup to it
					local type = getElementData( colshape, "type" )
					if pickups[ colshape ] and pickups[ colshape ].type ~= type then
						destroy( colshape )
					end
					
					if not pickups[ colshape ] then
						pickup = createPickup( px, py, pz, 3, type == 1 and 1273 or type == 2 and 1272 or 1318 )
						setElementInterior( pickup, getElementInterior( localPlayer ) )
						setElementDimension( pickup, dimension )
						
						pickups[ colshape ] = { type = type, pickup = pickup }
					end
					
					-- name
					local text = getElementData( colshape, "name" )	
					if text and ( distance < 2 or isLineOfSightClear( cx, cy, cz, px, py, pz + 0.7, true, true, true, true, false, false, true, localPlayer ) ) then
						local sx, sy = getScreenFromWorldPosition( px, py, pz + 0.7 )
						if sx and sy then
							local price = getElementData( colshape, "price" )
							if price then
								text = text .. "\nPress 'Enter' to buy for $" .. price .. "."
							end
							
							-- background
							local width = dxGetTextWidth( text )
							local height = ( price and 2 or 1 ) * dxGetFontHeight( )
							dxDrawRectangle( sx - width / 2 - 5, sy - height / 2 - 5, width + 10, height + 10, tocolor( 0, 0, 0, 200 ) )
							
							-- text
							dxDrawText( text, sx, sy, sx, sy, tocolor( 255, 255, 255, 255 ), 1, "default", "center", "center" )
						end
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
