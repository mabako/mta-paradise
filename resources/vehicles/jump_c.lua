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
local startTime = nil
local highest = nil

local damageMultiplier =
{
	Automobile = 1, Bike = 0.3, BMX = 0.4, ["Monster Truck"] = 0.1, Quad = 0.2,
	Bus = 3, Coach = 3, Sweeper = 0.5, Towtruck = 0.8, Trashmaster = 4, Barracks = 3, Enforcer = 0.2, Rhino = 0,
	Benson = 2, ["Black Boxville"] = 1.4, Boxville = 1.4, ["Cement Truck"] = 4, ["Combine Harvester"] = 2, ["DFT-30"] = 3, Dumper = 3, Dune = 0.4, Flatbed = 3, Hotdog = 2, Linerunner = 1.5, Mule = 1.3, Packer = 2.5, Roadtrain = 1.5, Yankee = 1.3,
	Bandito = 0, ["BF Injection"] = 0, Sandking = 0
}

local function damage( vehicle )
	local damage = highest * ( ( getTickCount( ) - startTime ) / 45 ) * ( damageMultiplier[ getVehicleName( vehicle ) ] or damageMultiplier[ getVehicleType( vehicle ) ] or 0 )
	if damage > 0 then
		setElementHealth( vehicle, math.max( 250, getElementHealth( vehicle ) - damage ) )
	end
end

addEventHandler( "onClientRender", root,
	function( )
		local vehicle = getPedOccupiedVehicle( localPlayer )
		if vehicle and getVehicleOccupant( vehicle ) == localPlayer then
			if not isVehicleOnGround( vehicle ) then
				local _, _, a = getElementBoundingBox( vehicle )
				local x, y, z = getElementPosition( vehicle )
				local b = getGroundPosition( x, y, z )
				a = 1.3 * a + z
				if not startTime then
					if b + 1 < a then
						startTime = getTickCount( )
						highest = math.abs( a - b )
					end
				elseif b + 1 > a then
					damage( vehicle )
					startTime = nil
					highest = nil
				else
					local this = math.abs( a - b )
					if this > highest then
						highest = this
					end
				end
			elseif startTime then
				damage( vehicle )
				startTime = nil
				highest = nil
			end
		end
	end
)

addEventHandler( "onClientPlayerVehicleEnter", localPlayer,
	function( )
		startTime = nil
		highest = nil
	end
)
