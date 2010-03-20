local vehicleIDs = { }
local vehicles = { }

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local result = exports.sql:query_assoc( "SELECT vehicleID, model, posX, posY, posZ, rotX, rotY, rotZ, numberplate, health, color1, color2 FROM vehicles ORDER BY vehicleID ASC" )
		if result then
			for key, data in ipairs( result ) do
				local vehicle = createVehicle( data.model, data.posX, data.posY, data.posZ, data.rotX, data.rotY, data.rotZ, numberplate )
				
				-- tables for ID -> vehicle and vehicle -> data
				vehicleIDs[ data.vehicleID ] = vehicle
				vehicles[ vehicle ] = { vehicleID = data.vehicleID }
				
				setElementHealth( vehicle, data.health )
				setVehicleColor( vehicle, data.color1, data.color2, data.color1, data.color2 ) -- most vehicles don't use second/third color anyway
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
				local color1, color2 = getVehicleColor( vehicle )
				local vehicleID, error = exports.sql:query_insertid( "INSERT INTO vehicles (model, posX, posY, posZ, rotX, rotY, rotZ, numberplate, color1, color2) VALUES (" .. table.concat( { model, x, y, z, 0, 0, 0, '"%s"', color1, color2 }, ", " ) .. ")", getVehiclePlateText( vehicle ) )
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

function saveVehicle( vehicle )
	if vehicle then
		local data = vehicles[ vehicle ]
		if data then
			local x, y, z = getElementPosition( vehicle )
			local rx, ry, rz = getVehicleRotation( vehicle )
			local success, error = exports.sql:query_free( "UPDATE vehicles SET posX = " .. x .. ", posY = " .. y .. ", posZ = " .. z .. ", rotX = " .. rx .. ", rotY = " .. ry .. ", rotZ = " .. rz .. ", health = " .. math.min( 1000, math.ceil( getElementHealth( vehicle ) ) ) .. " WHERE vehicleID = " .. data.vehicleID )			
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