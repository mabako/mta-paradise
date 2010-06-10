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

local fuelRoot
local fuelStation
local screenX, screenY = guiGetScreenSize( )
local refilling = 0
local xfuel = false
local tick = false

local function renderFuelStation( )
	local vehicle = getPedOccupiedVehicle( getLocalPlayer( ) )
	if vehicle and getVehicleOccupant( vehicle ) == getLocalPlayer( ) then
		local fuel = xfuel or getElementData( vehicle, "fuel" )
		
		dxDrawRectangle( screenX - 160, screenY - 200, 140, 200, tocolor( 0, 0, 0, 193 ) )
		dxDrawImage( screenX - 110, screenY - 190, 40, 40, "fuelpoint.png" )
		dxDrawText( tostring( getElementData( fuelStation, "name" ) or "" ), screenX - 150, screenY - 145, screenX - 20, 20, tocolor( 255, 255, 255, 255 ), 0.95, "bankgothic", "center" )
		dxDrawText( "Fuel: " .. ( fuel + refilling ) .. "%", screenX - 150, screenY - 120, screenX - 20, 20, tocolor( 255, 255, 255, 255 ), 0.5, "bankgothic", "center" )
		if getVehicleEngineState( vehicle ) then
			refilling = 0
			dxDrawText( "Turn your\nengine off.", screenX - 150, screenY - 100, screenX - 20, 20, tocolor( 255, 255, 255, 255 ), 0.5, "bankgothic", "center" )
		else
			if fuel + refilling < 100 and getPlayerMoney( ) >= math.ceil( refilling * 0.25 ) then
				dxDrawText( "Hold 'Space'\nto fill.", screenX - 150, screenY - 100, screenX - 20, 20, tocolor( 255, 255, 255, 255 ), 0.5, "bankgothic", "center" )
			end
			
			if refilling > 0 then
				dxDrawText( "Price: $" .. math.ceil( refilling * 0.25 ), screenX - 150, screenY - 65, screenX - 20, 20, tocolor( 255, 255, 255, 255 ), 0.5, "bankgothic", "center" )
			end
			
			if getTickCount( ) - tick > 160 then
				tick = getTickCount( )
				if getKeyState( 'space' ) and refilling + fuel < 100 and math.ceil( ( refilling + 1 ) * 0.25 ) <= getPlayerMoney( ) then
					refilling = refilling + 1
					
					if fuel + refilling == 100 then
						triggerServerEvent( "vehicles:fill", fuelStation, refilling )
						xfuel = fuel + refilling
						refilling = 0
					end
				elseif not getKeyState( 'space' ) and refilling > 0 and fuel + refilling <= 100 then
					triggerServerEvent( "vehicles:fill", fuelStation, refilling )
					xfuel = fuel + refilling
					refilling = 0
				end
			end
		end
	end
end

addEventHandler( "onClientElementDataChange", root,
	function( name )
		if name == "fuel" and source == getPedOccupiedVehicle( getLocalPlayer( ) ) then
			xfuel = false
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		fuelRoot = getElementsByType( "fuelpoint" )[ 1 ]
		if fuelRoot then
			addEventHandler( "onClientColShapeHit", fuelRoot,
				function( element )
					if element == getLocalPlayer( ) then
						fuelStation = source
						tick = getTickCount( )
						addEventHandler( "onClientRender", root, renderFuelStation )
					end
				end
			)
			
			addEventHandler( "onClientColShapeLeave", fuelRoot,
				function( element )
					if element == getLocalPlayer( ) then
						removeEventHandler( "onClientRender", root, renderFuelStation )
						xfuel = nil
						fuelStation = nil
					end
				end
			)
		else
			outputDebugString( "No fuelRoot", 1 )
		end
	end
)
