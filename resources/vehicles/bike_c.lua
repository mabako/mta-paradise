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
local state = true

bindKey( "steer_forward", "up",
	function( )
		local vehicle = getPedOccupiedVehicle( localPlayer )
		if state and vehicle and getVehicleOccupant( vehicle ) == localPlayer then
			if getVehicleType( vehicle ) == "BMX" or getVehicleType( vehicle ) == "Quad" or getVehicleType( vehicle ) == "Bike" then
				toggleControl( "steer_forward", false )
				toggleControl( "accelerate", false )
				setControlState( "accelerate", false )
				state = false
				
				setTimer( toggleControl, 500, 1, "accelerate", true )
				
				setTimer(
					function( )
						toggleControl( "steer_forward", true )
						state = true
					end,
					4000,
					1
				)
			end
		end
	end
)
