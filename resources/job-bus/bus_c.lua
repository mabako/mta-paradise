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
local position = nil
local marker = nil
local blip = nil
local blip2 = nil
local wait = false
local screenX, screenY = guiGetScreenSize( )

function drawWaitingText( )
	-- check if we still need to wait
	local text = "Wait..."
	local vehicle = getPedOccupiedVehicle( localPlayer )
	if vehicle then
		if getElementHealth( vehicle ) <= 350 then
			text = "Fix your vehicle"
		elseif wait and wait ~= 0 then
			local diff = wait - getTickCount( )
			if diff >= 0 then
				text = ( "Please wait %.1f seconds" ):format( diff / 1000 )
			else
				triggerServerEvent( getResourceName( resource ) .. ":complete", localPlayer )
				wait = 0
			end
		end
		
		-- draw the text
		dxDrawText( text, 4, 4, screenX, screenY, tocolor( 0, 0, 0, 255 ), 1, "pricedown", "center", "center" )
		dxDrawText( text, 0, 0, screenX, screenY, tocolor( 255, 255, 255, 255 ), 1, "pricedown", "center", "center" )
	end
end

--

local function hide( )
	if isElement( blip ) then
		destroyElement( blip )
	end
	blip = nil
	
	if isElement( blip2 ) then
		destroyElement( blip2 )
	end
	blip2 = nil
	
	if isElement( marker ) then
		destroyElement( marker )
	end
	marker = nil
	
	if wait then
		wait = false
		removeEventHandler( "onClientRender", root, drawWaitingText )
	end
end

local function show( )
	hide( )
	
	if position then
		-- in lack of a more detailed close-location (aka we use the entrance), use large markers
		marker = createMarker( position.x, position.y, position.z, "checkpoint", 3, position.stop and 0 or 255, 255, 0, 63 )
		if marker then
			blip = createBlipAttachedTo( marker, 0, 2, position.stop and 0 or 255, 255, 0, 255 )
		end
		
		if position.nx and position.ny and position.nz then
			blip2 = createBlip( position.nx, position.ny, position.nz, 0, 1, position.nstop and 0 or 255, 255, 0, 255 )
		end
	end
end

addEvent( getResourceName( resource ) .. ":show", true )
addEventHandler( getResourceName( resource ) .. ":show", localPlayer, show )

addEvent( getResourceName( resource ) .. ":set", true )
addEventHandler( getResourceName( resource ) .. ":set", localPlayer,
	function( x, y, z, stop, nx, ny, nz, nstop )
		if x and y and z then
			position = { x = x, y = y, z = z, stop = stop, nx = nx, ny = ny, nz = nz, nstop = nstop }
			show( )
		else
			position = nil
			hide( )
		end
	end
)

addEventHandler( "onClientPlayerVehicleExit", localPlayer, hide )

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( getResourceName( resource ) .. ":ready", localPlayer )
	end
)

addEventHandler( "onClientMarkerHit", resourceRoot,
	function( element, matching )
		if matching and element == localPlayer then
			if position.stop then
				if not wait then
					wait = getTickCount( ) + getElementData( resourceRoot, "delay" ) * 1000
					addEventHandler( "onClientRender", root, drawWaitingText )
				end
			else
				triggerServerEvent( getResourceName( resource ) .. ":complete", localPlayer )
			end
		end
	end
)

addEventHandler( "onClientMarkerLeave", resourceRoot,
	function( element, matching )
		if matching and element == localPlayer then
			wait = false
			removeEventHandler( "onClientRender", root, drawWaitingText )
		end
	end
)