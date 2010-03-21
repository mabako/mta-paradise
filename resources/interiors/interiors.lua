local interiors = { }
local colspheres = { }

local function loadInterior( id, outsideX, outsideY, outsideZ, outsideInterior, outsideDimension, insideX, insideY, insideZ, insideInterior, interiorName )
	local outside = createColSphere( outsideX, outsideY, outsideZ, 1 )
	setElementInterior( outside, outsideInterior )
	setElementDimension( outside, outsideDimension )
	setElementData( outside, "name", interiorName )
	
	local inside = createColSphere( insideX, insideY, insideZ, 1 )
	setElementInterior( inside, insideInterior )
	setElementDimension( inside, id )
	
	colspheres[ outside ] = { id = id, other = inside }
	colspheres[ inside ] = { id = id, other = outside }
	interiors[ id ] = { inside = inside, outside = outside }
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local result = exports.sql:query_assoc( "SELECT interiorID, outsideX, outsideY, outsideZ, outsideInterior, outsideDimension, insideX, insideY, insideZ, insideInterior, interiorName FROM interiors ORDER BY interiorID ASC" )
		if result then
			for key, data in ipairs( result ) do
				loadInterior( data.interiorID, data.outsideX, data.outsideY, data.outsideZ, data.outsideInterior, data.outsideDimension, data.insideX, data.insideY, data.insideZ, data.insideInterior, data.interiorName )
			end
		end
	end
)

addCommandHandler( "createinterior",
	function( player, commandName, id, ... )
		if id and ( ... ) then
			name = table.concat( { ... }, " " )
			interior = interiorPositions[ id:lower( ) ]
			if interior then
				local x, y, z = getElementPosition( player )
				local insertid = exports.sql:query_insertid( "INSERT INTO interiors (outsideX, outsideY, outsideZ, outsideInterior, outsideDimension, insideX, insideY, insideZ, insideInterior, interiorName) VALUES (" .. table.concat( { x, y, z, getElementInterior( player ), getElementDimension( player ), interior.x, interior.y, interior.z, interior.interior, '"%s"' }, ", " ) .. ")", name )
				if insertid then
					loadInterior( insertid, x, y, z, getElementInterior( player ), getElementDimension( player ), interior.x, interior.y, interior.z, interior.interior, name )
					outputChatBox( "Interior created (ID " .. insertid .. ")", player, 0, 255, 0 )
				else
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Interior " .. interiorName .. " does not exist.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id] [name]", player, 255, 255, 255 )
		end
	end,
	true
)

--

local p = { }

function enterInterior( player, key, state, colShape )
	local other = colspheres[ colShape ] and colspheres[ colShape ].other
	if other then
		-- teleport the player
		setElementPosition( player, getElementPosition( other ) )
		setElementDimension( player, getElementDimension( other ) )
		setElementInterior( player, getElementInterior( other ) )
		setCameraInterior( player, getElementInterior( other ) )
		setCameraTarget( player, player )
	end
end

addEventHandler( "onColShapeHit", resourceRoot,
	function( element, matching )
		if matching and getElementType( element ) == "player" then
			if p[ element ] then
				unbindKey( element, "enter_exit", "down", enterInterior, p[ element ] )
			else
				addEventHandler( "onPlayerVehicleEnter", element, cancelEvent ) -- stop players from entering vehicles
			end
			
			p[ element ] = source
			bindKey( element, "enter_exit", "down", enterInterior, p[ element ] )
		end
	end
)

addEventHandler( "onColShapeLeave", resourceRoot,
	function( element, matching )
		if getElementType( element ) == "player" and p[ element ] then
			unbindKey( element, "enter_exit", "down", enterInterior, p[ element ] )
			removeEventHandler( "onPlayerVehicleEnter", element, cancelEvent )
			p[ element ] = nil
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)