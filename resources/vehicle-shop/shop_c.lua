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

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		for key, value in ipairs( getElementsByType( "vehicle-shop", resourceRoot ) ) do
			-- find out our shop ID
			shopID = tonumber( gettok( getElementID( value ), 2, string.byte(' ') ) )
			
			-- try to access that shop
			local shop = shops[ shopID ]
			if shop then
				shops[ value ] = shop
				
				-- stick a blip to it
				if shop.blip then
					local x, y, z = unpack( shop.position )
					createBlip( x, y, z, shop.blip )
				end
			end
		end
	end
)

--

local localPlayer = getLocalPlayer( )
local screenX, screenY = guiGetScreenSize( )
local vehicle = nil
local x, y, z = 0, 0, 0

local function messageBox( )
	if getDistanceBetweenPoints3D( x, y, z, getElementPosition( localPlayer ) ) > 0.5 then
		-- moved away from the position he was at, so we remove the box
		removeEventHandler( "onClientRender", root, messageBox )
		vehicle = nil
	else
		-- text to display
		if getPlayerMoney( ) - getVehiclePrice( vehicle ) < 0 then
			text = "You need $" .. ( getVehiclePrice( vehicle ) - getPlayerMoney( ) ) .. "\nto buy this " .. getVehicleName( vehicle ) .. "."
		else
			text = "To buy this " .. getVehicleName( vehicle ) .. "\n for $" .. getVehiclePrice( vehicle ) .. ", press Enter."
		end
		
		-- get the width
		local width = dxGetTextWidth( text, 2, "default" )
		local height = dxGetFontHeight( 2 )
		
		-- draw the box and text
		dxDrawRectangle( screenX / 2 - width / 2 - 5, screenY / 2 - height - 5, width + 10, 2 * height + 10, tocolor( 0, 0, 0, 200 ), true )
		dxDrawText( text, screenX / 2 - width / 2, screenY / 2 - height, screenX / 2 + width / 2, screenY / 2 + height, tocolor( 255, 255, 255, 255 ), 2, "default", "center", "center", true, false, true )
	end
end

addEvent( getResourceName( resource ) .. ":buyPopup", true )
addEventHandler( getResourceName( resource ) .. ":buyPopup", resourceRoot,
	function( )
		local parent = getElementParent( source )
		local shop = shops[ parent ]
		if shop then
			if not vehicle then
				-- we don't have a vehicle yet
				addEventHandler( "onClientRender", root, messageBox )
			elseif source == vehicle then
				-- pressed enter again
				removeEventHandler( "onClientRender", root, messageBox )
				vehicle = nil
				
				triggerServerEvent( getResourceName( resource ) .. ":buyVehicle", source )
				return
			end -- in any other case, different vehicle, we keep the event
			x, y, z = getElementPosition( localPlayer )
			vehicle = source
		end
	end
)

--

addEventHandler( "onClientRender", getRootElement( ),
	function( )
		-- get the camera matrix
		local cx, cy, cz = getCameraMatrix( )
		
		-- loop through all vehicles you can buy
		for _, vehicle in ipairs ( getElementsByType( "vehicle", resourceRoot ) ) do
			if isElement( vehicle ) and isElementStreamedIn( vehicle ) then
				local px, py, pz = getElementPosition( vehicle )
				local distance = getDistanceBetweenPoints3D( px, py, pz, cx, cy, cz )
				if distance < 20 and isElementOnScreen( vehicle ) and isLineOfSightClear( cx, cy, cz, px, py, pz, true, true, false, true, false, false, true, vehicle ) then
					pz = pz + 0.5
					local _, _, _, _, _, dz = getElementBoundingBox( vehicle )
					local sx, sy = getScreenFromWorldPosition( px, py, pz + dz )
					if sx and sy then
						local text = tostring( getVehicleName( vehicle ) ) .. "\n$" .. tostring( getVehiclePrice( vehicle ) )
						
						-- background
						local width = dxGetTextWidth( text )
						local height = dxGetFontHeight( ) * 2
						dxDrawRectangle( sx - width / 2 - 5, sy - height / 2 - 5, width + 10, height + 10, tocolor( 0, 0, 0, 200 ) )
						
						-- text
						dxDrawText( text, sx, sy, sx, sy, tocolor( 255, 255, 255, 255 ), 1, "default", "center", "center" )
					end
				end
			end
		end
	end
)