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
local offsetX = 0

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		-- since we're left of the version label, get that position
		local label = guiCreateLabel( 0, 0, screenX, 1, "MTA: Paradise " .. exports.server:getVersion( ), false )
		offsetX = guiLabelGetTextExtent( label )
		destroyElement( label )
		
		-- hide our area name as we render our own
		showPlayerHudComponent( "area_name", false )
	end
)

addEventHandler( "onClientResourceStop", resourceRoot,
	function( )
		showPlayerHudComponent( "area_name", true )
	end
)

addEventHandler( "onClientRender", root,
	function( )
		if exports.players:isLoggedIn( ) then
			-- zone name
			local x, y, z = getCameraMatrix( )
			local zone = getZoneName( x, y, z )
			
			if zone and zone ~= "San Andreas" and zone ~= "Unknown" and getElementDimension( getLocalPlayer( ) ) == 0 then
				dxDrawText( zone, 0, 0, screenX - offsetX - 10, screenY + 1, tocolor( 255, 255, 255, 127 ), 1, "pricedown", "right", "bottom" )
			end
		end
	end
)
