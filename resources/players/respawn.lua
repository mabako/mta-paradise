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

local respawnDelay = tonumber( get( 'respawn_delay' ) ) or 15
local wastedTimes = { }

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		-- clients need this setting
		setElementData( source, "respawnDelay", respawnDelay )
	end
)

addEventHandler( "onPlayerWasted", root,
	function( )
		-- save when the player died to avoid anyone bypassing our delay
		wastedTimes[ source ] = getTickCount( )
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		wastedTimes[ source ] = nil
	end
)

addEvent( "onPlayerRespawn", true )
addEventHandler( "onPlayerRespawn", root,
	function( )
		if source == client then
			-- we only want players who're actually dead and logged in
			if isLoggedIn( source ) and isPedDead( source ) then
				-- check if we can already respawn
				if wastedTimes[ source ] and getTickCount( ) - wastedTimes[ source ] >= respawnDelay * 1000 then
					-- hide the screen
					fadeCamera( source, false, 1 )
					
					-- spawn him at the hospital
					setTimer(
						function( source )
							if isElement( source ) and isLoggedIn( source ) and isPedDead( source ) then
								spawnPlayer( source, 1607, 1819, 10.8, 0, getElementModel( source ), 0, 0 )
								fadeCamera( source, true )
								setCameraTarget( source, source )
								setCameraInterior( source, 0 )
							end
						end,
						1200,
						1,
						source
					)
					
					-- reset the wasted time counter
					wastedTimes[ source ] = nil
				end
			end
		end
	end
)
