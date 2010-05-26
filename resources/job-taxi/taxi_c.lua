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

local hornTime = nil
local localPlayer = getLocalPlayer( )

bindKey( "horn", "both",
	function( button, state )
		if state == "down" then
			hornTime = getTickCount( )
		elseif hornTime then
			if getTickCount( ) - hornTime < 200 then
				local vehicle = getPedOccupiedVehicle( localPlayer )
				if vehicle and getVehicleOccupant( vehicle ) == localPlayer then
					triggerServerEvent( getResourceName( resource ) .. ":toggleLights", vehicle )
				end
			end
			hornTime = nil
		end
	end
)

--

local screenX, screenY = guiGetScreenSize( )
local vehicle = nil
local lastUpdate = 0
local lastPosition = { 0, 0, 0 }
local updateIntervall = 2000

function renderTaximeter( )
	if getPedOccupiedVehicle( localPlayer ) == vehicle then
		local distance = getElementData( vehicle, "taxi:distance" )
		if distance then
			text = ("Taximeter: %.1fm"):format( distance )
			if getVehicleOccupant( vehicle ) == localPlayer then
				text = text .. " - /resettaxi to reset"
				
				local tick = getTickCount( )
				if tick - lastUpdate > updateIntervall then
					local x, y, z = getElementPosition( vehicle )
					local distance = getDistanceBetweenPoints3D( x, y, z, unpack( lastPosition ) ) / 2
					
					if distance > 0.001 and distance < 40 then
						triggerServerEvent( getResourceName( resource ) .. ":update", vehicle, distance )
					end
					
					lastPosition = { x, y, z }
					lastUpdate = tick
				end
			end
		else
			text = "Taximeter is off"
			if getVehicleOccupant( vehicle ) == localPlayer then
				text = text .. " - /taximeter to turn it on"
			end
		end
			-- draw the text
		dxDrawText( text, 4, 4, screenX, screenY * 0.98 + 2, tocolor( 0, 0, 0, 255 ), 1, "pricedown", "center", "bottom", false, false, true )
		dxDrawText( text, 0, 0, screenX, screenY * 0.98, tocolor( 255, 255, 255, 255 ), 1, "pricedown", "center", "bottom", false, false, true )
	end
end

addEvent( getResourceName( resource ) .. ":show", true )
addEventHandler( getResourceName( resource ) .. ":show", root,
	function( )
		vehicle = source
		lastPosition = { getElementPosition( source ) }
		addEventHandler( "onClientRender", root, renderTaximeter )
	end
)

addEvent( getResourceName( resource ) .. ":hide", true )
addEventHandler( getResourceName( resource ) .. ":hide", root,
	function( )
		vehicle = nil
		removeEventHandler( "onClientRender", root, renderTaximeter )
	end
)

--

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( getResourceName( resource ) .. ":ready", localPlayer )
	end
)
