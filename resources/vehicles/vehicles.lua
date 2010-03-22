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

local vehicleIDs = { }
local vehicles = { }

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local result = exports.sql:query_assoc( "SELECT vehicleID, model, posX, posY, posZ, rotX, rotY, rotZ, respawnPosX, respawnPosY, respawnPosZ, respawnRotX, respawnRotY, respawnRotZ, numberplate, health, color1, color2, interior, dimension, respawnInterior, respawnDimension FROM vehicles ORDER BY vehicleID ASC" )
		if result then
			for key, data in ipairs( result ) do
				local vehicle = createVehicle( data.model, data.posX, data.posY, data.posZ, data.rotX, data.rotY, data.rotZ, numberplate )
				
				-- tables for ID -> vehicle and vehicle -> data
				vehicleIDs[ data.vehicleID ] = vehicle
				vehicles[ vehicle ] = { vehicleID = data.vehicleID, respawnInterior = data.respawnInterior, respawnDimension = data.respawnDimension }
				
				-- some properties
				setElementHealth( vehicle, data.health )
				setVehicleColor( vehicle, data.color1, data.color2, data.color1, data.color2 ) -- most vehicles don't use second/third color anyway
				setVehicleRespawnPosition( vehicle, data.respawnPosX, data.respawnPosY, data.respawnPosZ, data.respawnRotX, data.respawnRotY, data.respawnRotZ )
				setElementInterior( vehicle, data.interior )
				setElementDimension( vehicle, data.dimension )
			end
		end
	end
)

addCommandHandler( "createvehicle", 
	function( player, commandName, ... )
		model = table.concat( { ... }, " " )
		model = getVehicleModelFromName( model ) or tonumber( model )
		if model then
			local x, y, z = getElementPosition( player )
			x = x + 3
			z = z + 1
			
			local vehicle = createVehicle( model, x, y, z )
			if vehicle then
				local color1, color2 = getVehicleColor( vehicle )
				local vehicleID, error = exports.sql:query_insertid( "INSERT INTO vehicles (model, posX, posY, posZ, rotX, rotY, rotZ, numberplate, color1, color2, respawnPosX, respawnPosY, respawnPosZ, respawnRotX, respawnRotY, respawnRotZ, interior, dimension, respawnInterior, respawnDimension) VALUES (" .. table.concat( { model, x, y, z, 0, 0, 0, '"%s"', color1, color2, x, y, z, 0, 0, 0, getElementInterior( player ), getElementDimension( player ), getElementInterior( player ), getElementDimension( player ) }, ", " ) .. ")", getVehiclePlateText( vehicle ) )
				if vehicleID then
					-- tables for ID -> vehicle and vehicle -> data
					vehicleIDs[ vehicleID ] = vehicle
					vehicles[ vehicle ] = { vehicleID = vehicleID, respawnInterior = getElementInterior( player ), respawnDimension = getElementDimension( player ) }
					
					-- some properties
					setElementInterior( vehicle, getElementInterior( player ) )
					setElementDimension( vehicle, getElementDimension( player ) )
					
					-- success message
					outputChatBox( "Created " .. getVehicleName( vehicle ) .. " (ID " .. vehicleID .. ")", player, 0, 255, 0 )
				else
					destroyElement( vehicle )
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Invalid Vehicle Model.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [model]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "repairvehicle",
	function( player, commandName, otherPlayer )
		if otherPlayer then
			target, targetName = exports.players:getFromName( player, otherPlayer )
		else
			target = player
			targetName = getPlayerName( player ):gsub( "_", " " )
		end
		
		if target then
			local vehicle = getPedOccupiedVehicle( target )
			if vehicle then
				fixVehicle( vehicle )
			end
			outputChatBox( "Your vehicle has been repaired by " .. getPlayerName( player ):gsub( "_", " " ) .. ".", target, 0, 255, 153 )
			if player ~= target then
				outputChatBox( "You repaired " .. targetName .. "'s vehicle.", target, 0, 255, 153 )
			end
		end
	end,
	true
)

addCommandHandler( "repairvehicles",
	function( player, commandName )
		for vehicle in pairs( vehicles ) do
			fixVehicle( vehicle )
		end
		outputChatBox( "*** " .. getPlayerName( player ):gsub( "_", " " ) .. " repaired all vehicles. ***", root, 0, 255, 153 )
	end,
	true
)

addCommandHandler( "respawnvehicle",
	function( player, commandName, vehicleID )
		vehicleID = tonumber( vehicleID )
		if vehicleID then
			local vehicle = vehicleIDs[ vehicleID ]
			if vehicle then
				respawnVehicle( vehicle )
				outputChatBox( "You respawned vehicle " .. vehicleID .. " (" .. getVehicleName( vehicle ) .. ").", player, 0, 255, 153 )
			else
				outputChatBox( "Vehicle not found.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "respawnvehicles",
	function( player, commandName )
		for vehicle in pairs( vehicles ) do
			if isVehicleEmpty( vehicle ) then
				respawnVehicle( vehicle )
			end
		end
		outputChatBox( "*** " .. getPlayerName( player ):gsub( "_", " " ) .. " respawned all vehicles. ***", root, 0, 255, 153 )
	end,
	true
)

addCommandHandler( "park",
	function( player, commandName )
		local vehicle = getPedOccupiedVehicle( player )
		if vehicle then
			local data = vehicles[ vehicle ]
			if data then
				if --[[ owner check or ]] hasObjectPermissionTo( player, "command.createvehicle", false ) then
					local x, y, z = getElementPosition( vehicle )
					local rx, ry, rz = getVehicleRotation( vehicle )
					local success, error = exports.sql:query_free( "UPDATE vehicles SET respawnPosX = " .. x .. ", respawnPosY = " .. y .. ", respawnPosZ = " .. z .. ", respawnRotX = " .. rx .. ", respawnRotY = " .. ry .. ", respawnRotZ = " .. rz .. ", respawnInterior = " .. getElementInterior( vehicle ) .. ", respawnDimension = " .. getElementDimension( vehicle ) .. " WHERE vehicleID = " .. data.vehicleID )			
					if success then
						setVehicleRespawnPosition( vehicle, x, y, z, rx, ry, rz )
						data.respawnInterior = getElementInterior( vehicle )
						data.respawnDimension = getElementDimension( vehicle )
						outputChatBox( "Vehicle " .. data.vehicleID .. " (" .. getVehicleName( vehicle ) .. ") has been parked.", player, 0, 255, 0 )
					else
						outputChatBox( "Parking Vehicle failed.", player, 255, 0, 0 )
					end
				else
					outputChatBox( "You cannot park this vehicle.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "You aren't driving a vehicle.", player, 255, 0, 0 )
		end
	end
)

addCommandHandler( "getvehicle",
	function( player, commandName, vehicleID )
		vehicleID = tonumber( vehicleID )
		if vehicleID then
			local vehicle = vehicleIDs[ vehicleID ]
			if vehicle then
				local x, y, z = getElementPosition( player )
				setElementPosition( vehicle, x + 3, y, z + 1 )
				setElementDimension( vehicle, getElementDimension( player ) )
				setElementInterior( vehicle, getElementInterior( player ) )
				outputChatBox( "You teleported vehicle " .. vehicleID .. " (" .. getVehicleName( vehicle ) .. ") to you.", player, 0, 255, 153 )
			else
				outputChatBox( "Vehicle not found.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "gotovehicle",
	function( player, commandName, vehicleID )
		vehicleID = tonumber( vehicleID )
		if vehicleID then
			local vehicle = vehicleIDs[ vehicleID ]
			if vehicle then
				local x, y, z = getElementPosition( vehicle )
				setElementPosition( player, x - 3, y, z )
				setElementDimension( player, getElementDimension( vehicle ) )
				setElementInterior( player, getElementInterior( vehicle ) )
				outputChatBox( "You teleported to vehicle " .. vehicleID .. " (" .. getVehicleName( vehicle ) .. ").", player, 0, 255, 153 )
			else
				outputChatBox( "Vehicle not found.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

function saveVehicle( vehicle )
	if vehicle then
		local data = vehicles[ vehicle ]
		if data then
			local x, y, z = getElementPosition( vehicle )
			local rx, ry, rz = getVehicleRotation( vehicle )
			local success, error = exports.sql:query_free( "UPDATE vehicles SET posX = " .. x .. ", posY = " .. y .. ", posZ = " .. z .. ", rotX = " .. rx .. ", rotY = " .. ry .. ", rotZ = " .. rz .. ", health = " .. math.min( 1000, math.ceil( getElementHealth( vehicle ) ) ) .. ", interior = " .. getElementInterior( vehicle ) .. ", dimension = " .. getElementDimension( vehicle ) .. " WHERE vehicleID = " .. data.vehicleID )			
			if error then
				outputDebugString( error )
			end
		end
	end
end

addEventHandler( "onVehicleExit", root,
	function( )
		saveVehicle( source )
	end
)

setTimer(
	function( )
		-- save all vehicles
		for vehicle in pairs( vehicles ) do
			saveVehicle( vehicle )
		end
	end,
	60000,
	0
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		-- save all occupied vehicles on resource start
		local occupiedVehicles = { }
		for _, value in ipairs( getElementsByType( "player" ) ) do
			local vehicle = getPedOccupiedVehicle( value )
			if vehicle then
				occupiedVehicles[ vehicle ] = true
			end
		end
		
		for vehicle in pairs( occupiedVehicles ) do
			saveVehicle( vehicle )
		end
	end
)

addEventHandler( "onVehicleRespawn", resourceRoot,
	function( )
		local data = vehicles[ source ]
		if data then
			setElementInterior( source, data.respawnInterior )
			setElementDimension( source, data.respawnDimension )
			saveVehicle( source )
		end
	end
)