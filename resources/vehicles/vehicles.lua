local vehicleIDs = { }
local vehicles = { }

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local vehicles = exports.sql:query_assoc( "SELECT vehicleID, model, posX, posY, posZ, rotX, rotY, rotZ, numberplate, health FROM vehicles ORDER BY vehicleID ASC" )
		if vehicles then
			for key, data in ipairs( vehicles ) do
				local vehicle = createVehicle( data.model, data.posX, data.posY, data.posZ, data.rotX, data.rotY, data.rotZ, numberplate )
				
				-- tables for ID -> vehicle and vehicle -> data
				vehicleIDs[ data.vehicleID ] = vehicle
				vehicles[ vehicle ] = { vehicleID = data.vehicleID }
				
				setElementHealth( vehicle, data.health )
			end
		end
	end
)

addCommandHandler( "createvehicle", 
	function( player, commandName, model )
		model = tonumber( model )
		if model then
			local x, y, z = getElementPosition( player )
			x = x + 3
			z = z + 1
			
			local vehicle = createVehicle( model, x, y, z )
			if vehicle then
				local vehicleID, error = exports.sql:query_insertid( "INSERT INTO vehicles (model, posX, posY, posZ, rotX, rotY, rotZ, numberplate) VALUES (" .. table.concat( { model, x, y, z, 0, 0, 0, '"%s"' }, ", " ) .. ")", getVehiclePlateText( vehicle ) )
				if vehicleID then
					-- tables for ID -> vehicle and vehicle -> data
					vehicleIDs[ vehicleID ] = vehicle
					vehicles[ vehicle ] = { vehicleID = vehicleID }
					
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