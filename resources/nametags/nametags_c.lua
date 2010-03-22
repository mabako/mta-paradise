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

local nametags = { }

-- settings
local _max_distance = 120 -- max. distance it's visible
local _min_distance = 7.5 -- minimum distance, if a player is nearer his nametag size wont change
local _alpha_distance = 20 -- nametag is faded out after this distance
local _nametag_alpha = 170 -- alpha of the nametag (max.)
local _bar_alpha = 120 -- alpha of the bar (max.)
local _scale = 0.2 -- change this to keep it looking good (proportions)
local _nametag_textsize = 0.6 -- change to increase nametag text
local _bar_width = 40
local _bar_height = 6
local _bar_border = 1.2

-- adjust settings
local _, screenY = guiGetScreenSize( )
real_scale = screenY / ( _scale * 800 ) 
local _alpha_distance_diff = _max_distance - _alpha_distance

addEventHandler( 'onClientRender', root, 
	function( )
		-- get the camera position of the local player
		local cx, cy, cz = getCameraMatrix( )
		
		-- loop through all players
		for player in pairs( nametags ) do
			if isElementOnScreen( player ) then
				local px, py, pz = getElementPosition( player )
				local distance = getDistanceBetweenPoints3D( px, py, pz, cx, cy, cz )
				if distance <= _max_distance and isLineOfSightClear( cx, cy, cz, px, py, pz, true, true, false, true, false, false, true, getPedOccupiedVehicle( player ) ) then
					local dz = 1 + 2 * math.min( 1, distance / _min_distance ) * _scale
					if isPedDucked( player ) then
						dz = dz / 2
					end
					pz = pz + dz
					local sx, sy = getScreenFromWorldPosition( px, py, pz )
					if sx and sy then
						-- how large should it be drawn
						distance = math.max( distance, _min_distance )
						local scale = _max_distance / ( real_scale * distance )
						
						-- visibility
						local alpha = ( ( distance - _alpha_distance ) / _alpha_distance_diff )
						local bar_alpha = ( alpha < 0 ) and _bar_alpha or _bar_alpha - (alpha * _bar_alpha)
						local nametag_alpha = bar_alpha / _bar_alpha * _nametag_alpha
						
						-- draw the player's name
						local r, g, b = getPlayerNametagColor( player )
						dxDrawText( getPlayerNametagText( player ), sx, sy, sx, sy, tocolor( r, g, b, nametag_alpha ), scale * _nametag_textsize, 'default', 'center', 'bottom' )
						
						-- draw the health bar
						local width, height = math.ceil( _bar_width * scale ), math.ceil( _bar_height * scale )
						local sx = sx - width / 2
						local border = math.ceil( _bar_border * scale )
						
						-- draw the armor bar
						local armor = getPedArmor( player )
						if armor > 0 then
							
							-- outer background
							dxDrawRectangle( sx, sy, width, height, tocolor( 0, 0, 0, bar_alpha ) )
							
							-- get the colors
							local r, g, b = 255, 255, 255
							
							-- inner background, which fills the whole bar but is somewhat transparent
							dxDrawRectangle( sx + border, sy + border, width - 2 * border, height - 2 * border, tocolor( r, g, b, 0.4 * bar_alpha ) )
							
							-- fill it with the actual armor
							dxDrawRectangle( sx + border, sy + border, math.floor( ( width - 2 * border ) / 100 * getPedArmor( player ) ), height - 2 * border, tocolor( r, g, b, bar_alpha ) ) 
							
							-- set the nametag below
							sy = sy + 1.2 * height
						end
						
						-- outer background
						dxDrawRectangle( sx, sy, width, height, tocolor( 0, 0, 0, bar_alpha ) )
						
						-- get the colors
						local health = getElementHealth( player )
						local r, g, b = 255 - 255 * health / 100, 255 * health / 100, 0
						
						-- inner background, which fills the whole bar but is somewhat transparent
						dxDrawRectangle( sx + border, sy + border, width - 2 * border, height - 2 * border, tocolor( r, g, b, 0.4 * bar_alpha ) )
						
						-- fill it with the actual health
						dxDrawRectangle( sx + border, sy + border, math.floor( ( width - 2 * border ) / 100 * health ), height - 2 * border, tocolor( r, g, b, bar_alpha ) ) 
					end
				end
			end
		end
	end
)

addEventHandler( 'onClientResourceStart', getResourceRootElement( ),
	function( )
		for _, player in pairs( getElementsByType( 'player' ) ) do
			if player ~= getLocalPlayer( ) then
				-- hide the default nametag
				setPlayerNametagShowing( player, false )
				
				-- save the player data
				nametags[ player ] = true
			end
		end
	end
)

addEventHandler( 'onClientResourceStop', getResourceRootElement( ),
	function( )
		-- handle stopping this resource
		for player in pairs( nametags ) do
			-- restore the nametag
			setPlayerNametagShowing( player, true )
			
			-- remove saved data
			nametags[ player ] = nil
		end
	end
)

addEventHandler ( 'onClientPlayerJoin', root,
	function( )
		-- hide the nametag
		setPlayerNametagShowing( source, false )
		
		-- save the player data
		nametags[ source ] = true
	end
)

addEventHandler ( 'onClientPlayerQuit', root,
	function( )
		-- cleanup
		nametags[ source ] = nil
	end
)