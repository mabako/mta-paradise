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

local respawnKeys = { 'enter_exit', 'fire' }

--

local respawnKey = false
local respawnWait = false
local localPlayer = getLocalPlayer( )
local screenX, screenY = guiGetScreenSize( )

function drawRespawnText( )
	-- makes only sense if we actually found a key to respawn - if not: player can't enter vehicles (makes no sense)
	if respawnKey then
		local text = "Press '" .. respawnKey .. "' to respawn"
		
		-- check if we still need to wait
		if respawnWait then
			local diff = respawnWait - getTickCount( )
			if diff >= 0 then
				text = ( "Wait %.1f seconds to respawn" ):format( diff / 1000 )
			elseif isCursorShowing( ) then
				-- check if the player presses a control, wouldn't be caught by SA as the key is down
				for key, value in ipairs( respawnKeys ) do
					local keys = getBoundKeys( value )
					if keys then
						for k in pairs( keys ) do
							if not k:find( 'mouse' ) and getKeyState( k ) then
								requestRespawn( )
								break
							end
						end
					end
				end
			end
		end
		
		-- draw the text
		dxDrawText( text, 4, 4, screenX, screenY, tocolor( 0, 0, 0, 255 ), 1, "pricedown", "center", "center" )
		dxDrawText( text, 0, 0, screenX, screenY, tocolor( 255, 255, 255, 255 ), 1, "pricedown", "center", "center" )
	end
end

function requestRespawn( )
	if isPlayerDead( localPlayer ) and respawnWait and respawnWait - getTickCount( ) < 0 then
		-- restore all keys
		for key, value in ipairs( respawnKeys ) do
			bindKey( value, 'down', requestRespawn )
			if value == 'fire' then
				toggleControl( value, true )
			end
		end
		respawnWait = false
		removeEventHandler( "onClientRender", root, drawRespawnText )
		
		-- let's respawn!
		triggerServerEvent( "onPlayerRespawn", localPlayer )
	end
end

addEventHandler( "onClientPlayerWasted", localPlayer,
	function( )
		-- keep the camera (reset when the player respawns)
		setCameraMatrix( getCameraMatrix( ) )
		
		-- bind all configured keys usable for respawn
		for key, value in ipairs( respawnKeys ) do
			bindKey( value, 'down', requestRespawn )
			if value == 'fire' then
				toggleControl( value, false )
			end
		end
		
		-- find a key that can be used for respawning, display it later
		respawnKey = false
		respawnWait = getTickCount( ) + getElementData( resourceRoot, 'respawnDelay' ) * 1000
		for key, value in ipairs( respawnKeys ) do
			local keys = getBoundKeys( value )
			if keys then
				for k in pairs( keys ) do
					respawnKey = k
					break
				end
			end
			
			if respawnKey then
				break
			end
		end
		addEventHandler( "onClientRender", root, drawRespawnText )
	end
)
