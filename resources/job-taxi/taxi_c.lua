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

bindKey( "horn", "both",
	function( button, state )
		if state == "down" then
			hornTime = getTickCount( )
		elseif hornTime then
			if getTickCount( ) - hornTime < 200 then
				local vehicle = getPedOccupiedVehicle( getLocalPlayer( ) )
				if vehicle and getVehicleOccupant( vehicle ) == getLocalPlayer( ) then
					triggerServerEvent( getResourceName( resource ) .. ":toggleLights", vehicle )
				end
			end
			hornTime = nil
		end
	end
)
