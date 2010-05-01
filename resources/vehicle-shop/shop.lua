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

local function populateSpots( force )
	-- get all players positions to check if there's no nearby player
	local players = { }
	if not force then
		for key, value in ipairs( getElementsByType( "player" ) ) do
			if getElementDimension( value ) == 0 and getElementInterior( value ) == 0 then
				players[ #players + 1 ] = { getElementPosition( value ) }
			end
		end
	end
	
	-- get vehicle positions in case any is near
	local vehicles = { }
	for key, value in ipairs( getElementsByType( "vehicle" ) ) do
		if getElementDimension( value ) == 0 and getElementInterior( value ) == 0 then
			vehicles[ #vehicles + 1 ] = { getElementPosition( value ) }
		end
	end
	
	for key, value in ipairs( shops ) do
		if #value.spots > 0 and #value.prices then
			-- check that no player is near the first spot (as it should be close with the rest)
			local canPopulate = true
			for k, v in ipairs( players ) do
				if getDistanceBetweenPoints3D( value.position[1], value.position[2], value.position[3], v[1], v[2], v[3] ) < 200 then
					canPopulate = false
					break
				end
			end
			
			if canPopulate then
				-- create new ones instead
				for k, v in ipairs( value.spots ) do
					local data = value.prices[ math.random( 1, #value.prices ) ]
					
					if v.vehicle and isElement( v.vehicle ) then
						-- already have a car, change it with another one
						if setElementModel( v.vehicle, data.model ) then
							-- if we actually changed the model, assign a random color if we can
							local color1, color2 = getRandomVehicleColor( v.vehicle )
							if color1 then
								setVehicleColor( v.vehicle, color1, color2 or color1, color1, color2 or color1 )
							end
						end
					else
						-- make sure no vehicle is nearby
						local canPopulate = true
						for _, x in ipairs( vehicles ) do
							if getDistanceBetweenPoints3D( x[1], x[2], x[3], v[1], v[2], v[3] ) < 1 then
								canPopulate = false
								break
							end
						end
						
						if canPopulate then
							-- create a new vehicle as we didn't have one before
							local vehicle = createVehicle( data.model, unpack( v ) )
							
							-- assign it to our shop
							setElementParent( vehicle, value.root )
							
							-- it's locked or people would drive it off
							setVehicleLocked( vehicle, true )
							
							-- we don't want people to trash 'em up really
							setVehicleDamageProof( vehicle, true )
							
							-- save it
							v.vehicle = vehicle
						end
					end
				end
			end
		end
	end
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		for key, value in ipairs( shops ) do
			-- create an element for every shop
			value.root = createElement( "vehicle-shop", "vehicle-shop " .. key )
			
			-- easier lookup
			shops[ value.root ] = value
		end
		
		-- initalize our vehicles
		populateSpots( true )
		
		-- populate with other cars every minute
		setTimer( populateSpots, 60000, 0 )
	end
)

addEventHandler( "onVehicleStartEnter", resourceRoot,
	function( player )
		if not isPedDead( player ) then
			-- show popup for buying
			triggerClientEvent( player, getResourceName( resource ) .. ":buyPopup", source )
		end
		
		-- don't let him enter the vehicle
		cancelEvent( )
	end
)

addEventHandler( "onVehicleEnter", resourceRoot,
	function( )
		-- vehicles can't be entered
		cancelEvent( )
	end
)

addEvent( getResourceName( resource ) .. ":buyVehicle", true )
addEventHandler( getResourceName( resource ) .. ":buyVehicle", resourceRoot,
	function( )
		if client then
			-- let's see if he has enough money
			if exports.players:takeMoney( client, getVehiclePrice( source ) ) then
				-- try to create a permanent one
				local vehicle, vehicleID = exports.vehicles:create( client, source )
				
				if vehicle then
					-- if that works, destroy our temporary one
					destroyElement( source )
					
					-- tell him
					outputChatBox( "Congratulations! You've bought a " .. getVehicleName( vehicle ) .. "!", client, 255, 127, 0 )
					outputChatBox( "You can use /park to set a permanent spawn position for this vehicle.", client, 255, 255, 0 )
					
					-- give him the keys
					exports.items:give( client, 1, vehicleID )
				else
					-- failed somewhere
					exports.players:giveMoney( client, getVehiclePrice( source ) )
				end
			end
		end
	end
)
