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

local vehicles = get( "vehicles" ) or { "Mule" } -- load the civilian vehicles that'll automatically trigger the delivery mission if being entered
local max_earnings = tonumber( get( "earnings" ) ) or 10
local delay = tonumber( get( "delay" ) ) or 5

-- put it in a for us better format
local vehicles2 = { }
for key, value in ipairs( vehicles ) do
	local model = getVehicleModelFromName( value )
	if model then
		vehicles2[ model ] = true
	else
		outputDebugString( "Vehicle '" .. tostring( value ) .. " does not exist." )
	end
end
vehicles = vehicles2
vehicles2 = nil

local function isDeliveryVehicle( vehicle )
	return vehicle and vehicles[ getElementModel( vehicle ) ] and not exports.vehicles:getOwner( vehicle ) or false
end

--

local p = { }

-- this would ideally be done depending on what shops order supplies/which government owned shops are even low on supplies
local function getNextDropOffPoint( current )
	-- select a random dropoff point as in an interior with a shop in it.
	local result = exports.sql:query_assoc_single( "SELECT interiorID, outsideX, outsideY, outsideZ, interiorName FROM shops s LEFT JOIN interiors i ON dimension = interiorID WHERE outsideDimension = 0 AND (characterID != 0 OR interiorType = 0)" .. ( current and ( " AND interiorID != " .. tonumber( current ) ) or "" ) .. " GROUP BY interiorID ORDER BY RAND() LIMIT 1" )
	if result then
		-- it would probably help if we used the position to calculate some position on the street or sidewalk
		return result.interiorID, result.outsideX, result.outsideY, result.outsideZ, result.interiorName
	end
end

local function newDropOff( player, earnings )
	p[ player ].vehicleOnResourceStart = nil
	local id, x, y, z, name = getNextDropOffPoint( p[ player ].dropOff )
	if id then
		p[ player ] = { dropOff = id, x = x, y = y, z = z, name = name }
		triggerClientEvent( player, "job-delivery:setdropoff", player, x, y, z )
		outputChatBox( "(( " .. ( earnings and ( "You earned $" .. earnings .. ". " ) or "" ) .. "Next Drop-Off: " .. name .. " ))", player, 255, 204, 0 )
		return true
	else
		outputDebugString( "No dropoff found, leaving " .. getPlayerName( player ) .. " without another task...", 2 )
		p[ player ] = { }
		triggerClientEvent( player, "job-delivery:setdropoff", player )
		return false
	end
end

addEventHandler( "onVehicleEnter", root,
	function( player, seat )
		if seat == 0 and isDeliveryVehicle( source ) then
			if not p[ player ] then
				p[ player ] = { }
			end
			
			if not p[ player ].dropOff then
				newDropOff( player )
			else
				triggerClientEvent( player, "job-delivery:showdropoff", player )
			end
		end
	end
)

--

addEventHandler( "onResourceStart", root,
	function( )
		setElementData( resourceRoot, "delay", delay )
		
		--
		
		for key, value in ipairs( getElementsByType( "player" ) ) do
			local vehicle = getPedOccupiedVehicle( value )
			if vehicle and getPedOccupiedVehicleSeat( value ) == 0 and isDeliveryVehicle( vehicle ) then
				p[ value ] = { vehicleOnResourceStart = vehicle }
			end
		end
		
		setTimer(
			function( )
				for key, value in pairs( p ) do
					p[ key ].vehicleOnResourceStart = nil
				end
			end, 10000, 1
		)
	end
)

addEvent( "job-delivery:ready", true )
addEventHandler( "job-delivery:ready", root,
	function( )
		if source == client then
			if p[ source ] and getPedOccupiedVehicle( source ) == p[ source ].vehicleOnResourceStart and getPedOccupiedVehicleSeat( source ) == 0 then
				newDropOff( source )
			end
		end
	end
)

--

addEvent( "job-delivery:complete", true )
addEventHandler( "job-delivery:complete", root,
	function( )
		if source == client then
			local vehicle = getPedOccupiedVehicle( source )
			if p[ source ] and p[ source ].dropOff and isDeliveryVehicle( vehicle ) and getPedOccupiedVehicleSeat( source ) == 0 then
				-- distance check
				if getDistanceBetweenPoints2D( p[ source ].x, p[ source ].y, getElementPosition( vehicle ) ) < 22.5 then
					local health = math.min( 1000, getElementHealth( vehicle ) )
					if health <= 350 then
						outputChatBox( "Fix your truck!", player, 255, 0, 0 )
					else
						-- calculate earnings based on vehicle health
						local earnings = math.ceil( ( health - 350 ) / 650 * max_earnings )
						exports.players:giveMoney( source, earnings )
						
						-- get a new drop-off
						newDropOff( source, earnings )
					end
				end
			end
		end
	end
)

addEventHandler( "onCharacterLogout", root,
	function( )
		if p[ source ] and p[ source ].dropOff then
			triggerClientEvent( source, "job-delivery:setdropoff", source )
		end
		p[ source ] = nil
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)
