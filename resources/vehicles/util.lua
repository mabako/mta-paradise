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

function isVehicleEmpty( vehicle )
	for seat = 0, getVehicleMaxPassengers( vehicle ) do
		if getVehicleOccupant( vehicle, seat ) then
			return false
		end
	end
	return true
end

function getPositionInFrontOf( element, distance, rotation )
	local x, y, z = getElementPosition( element )
	rz = 0
	if getElementType( element ) == "vehicle" then
		_, _, rz = getElementRotation( element )
	elseif getElementType( element ) == "player" then
		rz = getPedRotation( element )
	end
	rz = rz + ( rotation or 90 )
	return x + ( ( math.cos ( math.rad ( rz ) ) ) * ( distance or 3 ) ), y + ( ( math.sin ( math.rad ( rz ) ) ) * ( distance or 3 ) ), z, rz
end

local vehiclesWithFuel = { Automobile = true, Bike = true, ["Monster Truck"] = true, Quad = true }
function doesVehicleHaveFuel( vehicle )
	return isElement( vehicle ) and getElementType( vehicle ) == "vehicle" and vehiclesWithFuel[ getVehicleType( vehicle ) ] or false
end

local vehiclesWithEngine = { Automobile = true, Plane = true, Bike = true, Helicopter = true, Boat = true, Train = true, Trailer = false, BMX = false, ["Monster Truck"] = true, Quad = true }
function doesVehicleHaveEngine( vehicle )
	return isElement( vehicle ) and getElementType( vehicle ) == "vehicle" and vehiclesWithEngine[ getVehicleType( vehicle ) ] or false

end
