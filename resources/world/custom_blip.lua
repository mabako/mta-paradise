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

local screenX, screenY = guiGetScreenSize( )
local blip = nil
local clicked = false

addEventHandler( "onClientRender", root,
	function( )
		if clicked and isPlayerMapVisible( ) and isCursorShowing( ) then
			local minX, minY, maxX, maxY = getPlayerMapBoundingBox( )
			
			-- get the position in pixels
			local cx, cy = getCursorPosition( )
			cx = math.floor( cx * screenX + 0.5 )
			cy = math.floor( cy * screenY + 0.5 )
			
			-- check if we clicked on the map
			if minX and cx > 0 and cy > 0 and cx < screenX and cy < screenY and cx >= minX and cy >= minY and cx <= maxX and cy <= maxY then
				-- calculate to coords between -3000 and 3000 each
				local wx = ( cx - minX ) / ( maxX - minX )  * 6000 - 3000
				local wy = 3000 - ( cy - minY ) / ( maxY - minY )  * 6000
				
				blip = createBlip( wx, wy, 0, 41, 2 )
			end
			
		end
		clicked = false
	end
)

addEventHandler( 'onClientClick', root,
	function( button, state )
		if button == "left" and state == "up" then
			if blip then
				destroyElement( blip )
				blip = nil
			else
				clicked = true
			end
		end
	end
)
