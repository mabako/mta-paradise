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

local engineState = nil
local localPlayer = getLocalPlayer( )

addEventHandler( "onClientVehicleStartEnter", resourceRoot,
	function( player, seat )
		-- save the state for when we're done entering, as GTA automatically turns the engines on
		if seat == 0 and player == localPlayer then
			engineState = { vehicle = source, state = getVehicleEngineState( source ) }
		else
			engineState = nil
		end
	end
)
addEventHandler( "onClientVehicleEnter", resourceRoot,
	function( player, seat )
		-- restore the engine state
		if seat == 0 and player == localPlayer and engineState.vehicle == source then
			setVehicleEngineState( source, engineState.state )
		end
		engineState = nil
	end
)