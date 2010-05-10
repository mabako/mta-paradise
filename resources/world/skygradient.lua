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

local inside = false
local localPlayer = getLocalPlayer( )
local konamiCode = false

addEventHandler( "onClientRender", root,
	function( )
		if not inside and getElementInterior( localPlayer ) > 0 then
			inside = true
			setSkyGradient( 0, 0, 0, 0, 0, 0 )
		elseif inside and getElementInterior( localPlayer ) == 0 then
			inside = false
			if konamiCode then
				setSkyGradient( 255, 255, 255, 255, 200, 230 )
			else
				resetSkyGradient( )
			end
		end
	end
)

addEventHandler( "onClientResourceStop", resourceRoot,
	function( )
		if inside or konamiCode then
			resetSkyGradient( )
		end
	end
)

--

local konamiProcess = 0
local screenX, screenY = guiGetScreenSize( )

bindKey( 'arrow_u', 'down',
	function( )
		if not konamiCode then
			if konamiProcess == 0 then
				setTimer(
					function( )
						if konamiProcess ~= 0 then
							if konamiProcess == 8 then
								bindKey( "b", "down", "chatbox", "LocalOOC" )
							end
							
							konamiProcess = 0
						end
					end,
					15000,
					1
				)
			end
			
			if konamiProcess == 0 or konamiProcess == 1 then
				konamiProcess = konamiProcess + 1
			end
		end
	end
)

bindKey( 'arrow_d', 'down',
	function( )
		if konamiProcess == 2 or konamiProcess == 3 then
			konamiProcess = konamiProcess + 1
		end
	end
)

bindKey( 'arrow_l', 'down',
	function( )
		if konamiProcess == 4 or konamiProcess == 6 then
			konamiProcess = konamiProcess + 1
		end
	end
)

bindKey( 'arrow_r', 'down',
	function( )
		if konamiProcess == 5 or konamiProcess == 7 then
			konamiProcess = konamiProcess + 1
		end
	end
)

bindKey( 'b', 'down',
	function( )
		if konamiProcess == 8 then
			konamiProcess = konamiProcess + 1
		end
	end
)

bindKey( 'a', 'down',
	function( )
		if konamiProcess == 9 then
			konamiCode = true
			konamiProcess = 0
			
			if getElementInterior( localPlayer ) == 0 then
				setSkyGradient( 255, 255, 255, 255, 200, 230 )
			end
			
			-- our favorite weather
			setWeather( 78 )
			
			-- line calculator
			i = 0
			local function isOnScreen( a, b, c, d, e, f )
				if getScreenFromWorldPosition( a, b, c, 0.4 ) or getScreenFromWorldPosition( d, e, f, 0.4 ) or getScreenFromWorldPosition( ( a + d ) / 2, ( b + e ) / 2, ( c + f ) / 2, 0.4 ) then
					i = i + 1
					return true
				end
			end
			
			-- fps calc
			fps = 0
			lastfps = 0
			setTimer( function( ) lastfps = fps fps = 0 end, 1000, 1 )
			
			addEventHandler( "onClientRender", root,
				function( )
					-- draw all lines
					i = 0
					fps = fps + 1
					
					local px, py, pz = getElementPosition( localPlayer )
					px = math.ceil( px / 5 ) * 5
					py = math.ceil( py / 5 ) * 5
					pz = math.ceil( pz / 5 ) * 5
					
					for x = px - 30, px + 30, 5 do
						for y = py - 30, py + 30, 5 do
							if isOnScreen( x, y, pz - 15, x, y, pz + 20 ) then
								dxDrawLine3D( x, y, pz - 100, x, y, pz + 100, tocolor( 255, 255, 255, 191 ), 5, true )
							end
						end
						
					end
					
					for z = pz - 15, pz + 20, 5 do
						for x = px - 30, px + 30, 5 do
							if isOnScreen( x, py - 30, z, x, py + 30, z ) then
								dxDrawLine3D( x, py - 100, z, x, py + 100, z, tocolor( 255, 255, 255, 191 ), 5, true )
							end
						end
						for y = py - 30, py + 30, 5 do
							if isOnScreen( px - 30, y, z, px + 30, y, z ) then
								dxDrawLine3D( px - 100, y, z, px + 100, y, z, tocolor( 255, 255, 255, 191 ), 5, true )
							end
						end
					end
					
					-- fps/line counter
					dxDrawText( "FPS: " .. lastfps .. " - Lines: " .. i, 0, screenY - 16 )
				end
			)
		end
	end
)
