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
				triggerServerEvent( "job-delivery:complete", localPlayer )
				wait = 0
			end
		end
		
		-- draw the text
		dxDrawText( text, 4, 4, screenX, screenY, tocolor( 0, 0, 0, 255 ), 1, "pricedown", "center", "center" )
		dxDrawText( text, 0, 0, screenX, screenY, tocolor( 255, 255, 255, 255 ), 1, "pricedown", "center", "center" )
	end
end

--

local function hideDropOff( )
	if isElement( blip ) then
		destroyElement( blip )
	end
	blip = nil
	
	if isElement( marker ) then
		destroyElement( marker )
	end
	marker = nil
	
	if wait then
		wait = false
		removeEventHandler( "onClientRender", root, drawWaitingText )
	end
end

local function showDropOff( )
	hideDropOff( )
	
	if position then
		-- in lack of a more detailed close-location (aka we use the entrance), use large markers
		marker = createMarker( position.x, position.y, position.z, "checkpoint", 17.5, 0, 255, 0, 63 )
		if marker then
			blip = createBlipAttachedTo( marker, 0, 3, 0, 255, 0, 255 )
		end
	end
end

addEvent( "job-delivery:showdropoff", true )
addEventHandler( "job-delivery:showdropoff", localPlayer, showDropOff )

addEvent( "job-delivery:setdropoff", true )
addEventHandler( "job-delivery:setdropoff", localPlayer,
	function( x, y, z )
		if x and y and z then
			position = { x = x, y = y, z = z }
			showDropOff( )
		else
			position = nil
			hideDropOff( )
		end
	end
)

addEventHandler( "onClientPlayerVehicleExit", localPlayer, hideDropOff )

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "job-delivery:ready", localPlayer )
	end
)

addEventHandler( "onClientMarkerHit", resourceRoot,
	function( element, matching )
		if matching and element == localPlayer then
			if not wait then
				wait = getTickCount( ) + getElementData( resourceRoot, "delay" ) * 1000
				addEventHandler( "onClientRender", root, drawWaitingText )
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