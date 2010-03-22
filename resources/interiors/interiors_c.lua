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

addEventHandler( "onClientRender", getRootElement( ),
	function( )
		-- get the camera matrix
		local cx, cy, cz = getCameraMatrix( )
		
		-- loop through all vehicles you can buy
		local dimension = getElementDimension( getLocalPlayer( ) )
		for key, colshape in ipairs ( getElementsByType( "colshape", resourceRoot ) ) do
			if isElement( colshape ) and getElementDimension( colshape ) == dimension and getElementData( colshape, "name" ) then
				local px, py, pz = getElementPosition( colshape )
				local distance = getDistanceBetweenPoints3D( px, py, pz, cx, cy, cz )
				if distance < 10 and isLineOfSightClear( cx, cy, cz, px, py, pz, true, true, true, true, false, false, true, colshape ) then
					local sx, sy = getScreenFromWorldPosition( px, py, pz )
					if sx and sy then
						-- name
						local text = getElementData( colshape, "name" )
						
						-- background
						local width = dxGetTextWidth( text )
						local height = dxGetFontHeight( )
						dxDrawRectangle( sx - width / 2 - 5, sy - height / 2 - 5, width + 10, height + 10, tocolor( 0, 0, 0, 200 ) )
						
						-- text
						dxDrawText( text, sx, sy, sx, sy, tocolor( 255, 255, 255, 255 ), 1, "default", "center", "center" )
					end
				end
			end
		end
	end
)