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

local addCommandHandler_ = addCommandHandler
      addCommandHandler  = function( commandName, fn, restricted, caseSensitive )
	-- add the default command handlers
	if type( commandName ) ~= "table" then
		commandName = { commandName }
	end
	for key, value in ipairs( commandName ) do
		if key == 1 then
			addCommandHandler_( value, fn, restricted, caseSensitive )
		else
			addCommandHandler_( value,
				function( player, ... )
					-- check if he has permissions to execute the command, default is not restricted (aka if the command is restricted - will default to no permission; otherwise okay)
					if hasObjectPermissionTo( player, "command." .. commandName[ 1 ], not restricted ) then
						fn( player, ... )
					end
				end
			)
		end
	end
	
	-- check for alternative handlers, such as createinterior = createint
	for k, v in ipairs( commandName ) do
		if v:find( "interior" ) then
			for key, value in pairs( { "int" } ) do
				local newCommand = v:gsub( "interior", value )
				if newCommand ~= v then
					-- add a second (replaced) command handler
					addCommandHandler_( newCommand,
						function( player, ... )
							-- check if he has permissions to execute the command, default is not restricted (aka if the command is restricted - will default to no permission; otherwise okay)
							if hasObjectPermissionTo( player, "command." .. commandName[ 1 ], not restricted ) then
								fn( player, ... )
							end
						end
					)
				end
			end
		end
	end
end

--

local interiors = { }
local colspheres = { }

local function getInteriorIDAt( x, y, z, interior )
	for name, i in pairs( interiorPositions ) do
		if interior == i.interior and getDistanceBetweenPoints3D( x, y, z, i.x, i.y, i.z ) < 15 then
			return name, i
		end
	end
end

local function createBlipEx( outside, inside )
	local interior = getElementInterior( inside )
	local x, y, z = getElementPosition( inside )
	
	local name, i = getInteriorIDAt( x, y, z, interior )
	if i and i.blip then
		return createBlipAttachedTo( outside, i.blip, 2, 255, 255, 255, 255, 0, 300 )
	end
end

local function loadInterior( id, outsideX, outsideY, outsideZ, outsideInterior, outsideDimension, insideX, insideY, insideZ, insideInterior, interiorName, interiorPrice, interiorType, characterID, locked, dropoff )
	local outside = createColSphere( outsideX, outsideY, outsideZ, 1 )
	setElementInterior( outside, outsideInterior )
	setElementDimension( outside, outsideDimension )
	setElementData( outside, "name", interiorName )
	
	-- we only need it set in case there's really something for sale
	if interiorType ~= 0 and characterID <= 0 then
		setElementData( outside, "type", interiorType )
		setElementData( outside, "price", interiorPrice )
	end
	
	local inside = createColSphere( insideX, insideY, insideZ, 1 )
	setElementInterior( inside, insideInterior )
	setElementDimension( inside, id )
	
	colspheres[ outside ] = { id = id, other = inside }
	colspheres[ inside ] = { id = id, other = outside }
	interiors[ id ] = { inside = inside, outside = outside, name = interiorName, type = interiorType, price = interiorPrice, characterID = characterID, locked = locked, blip = not locked and outsideDimension == 0 and not getElementData( outside, "price" ) and createBlipEx( outside, inside ), dropoff = dropoff }
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		-- check for our table to exist
		if not exports.sql:create_table( 'interiors', 
			{
				{ name = 'interiorID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'outsideX', type = 'float' },
				{ name = 'outsideY', type = 'float' },
				{ name = 'outsideZ', type = 'float' },
				{ name = 'outsideInterior', type = 'int(10) unsigned' },
				{ name = 'outsideDimension', type = 'int(10) unsigned' },
				{ name = 'insideX', type = 'float' },
				{ name = 'insideY', type = 'float' },
				{ name = 'insideZ', type = 'float' },
				{ name = 'insideInterior', type = 'int(10) unsigned' },
				{ name = 'interiorName', type = 'varchar(255)' },
				{ name = 'interiorType', type = 'tinyint(3) unsigned' },
				{ name = 'interiorPrice', type = 'int(10) unsigned' },
				{ name = 'characterID', type = 'int(10) unsigned', default = 0 },
				{ name = 'locked', type = 'tinyint(3)', default = 0 },
				{ name = 'dropoffX', type = 'float', null = true },
				{ name = 'dropoffY', type = 'float', null = true },
				{ name = 'dropoffZ', type = 'float', null = true },
			} ) then cancelEvent( ) return end
		
		--
		
		local result = exports.sql:query_assoc( "SELECT * FROM interiors ORDER BY interiorID ASC" )
		if result then
			for key, data in ipairs( result ) do
				loadInterior( data.interiorID, data.outsideX, data.outsideY, data.outsideZ, data.outsideInterior, data.outsideDimension, data.insideX, data.insideY, data.insideZ, data.insideInterior, data.interiorName, data.interiorPrice, data.interiorType, data.characterID, data.locked == 1, data.dropoffX and data.dropoffY and data.dropoffZ and { data.dropoffX, data.dropoffY, data.dropoffZ } or nil )
			end
		end
	end
)

addCommandHandler( "createinterior",
	function( player, commandName, id, price, type, ... )
		if id and tonumber( price ) and tonumber( type ) and ( ... ) then
			name = table.concat( { ... }, " " )
			interior = interiorPositions[ id:lower( ) ]
			if interior then
				local x, y, z = getElementPosition( player )
				local insertid = exports.sql:query_insertid( "INSERT INTO interiors (outsideX, outsideY, outsideZ, outsideInterior, outsideDimension, insideX, insideY, insideZ, insideInterior, interiorName, interiorType, interiorPrice) VALUES (" .. table.concat( { x, y, z, getElementInterior( player ), getElementDimension( player ), interior.x, interior.y, interior.z, interior.interior, '"%s"', tonumber( type ), tonumber( price ) }, ", " ) .. ")", name )
				if insertid then
					loadInterior( insertid, x, y, z, getElementInterior( player ), getElementDimension( player ), interior.x, interior.y, interior.z, interior.interior, name, tonumber( price ), tonumber( type ), 0, false )
					outputChatBox( "Interior created. (ID " .. insertid .. ")", player, 0, 255, 0 )
				else
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Interior " .. id:lower( ) .. " does not exist.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id] [price] [type 0=Gov 1=House 2=Biz] [name]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( { "deleteinterior", "delinterior" },
	function( player, commandName, interiorID )
		interiorID = tonumber( interiorID )
		if interiorID then
			local interior = interiors[ interiorID ]
			if interior then
				if exports.sql:query_free( "DELETE FROM interiors WHERE interiorID = " .. interiorID ) then
					outputChatBox( "You deleted interior " .. interiorID .. ".", player, 0, 255, 153 )
					
					-- teleport all players who're inside to the exit
					for key, value in ipairs( getElementsByType( "player" ) ) do
						if exports.players:isLoggedIn( value ) and getElementDimension( value ) == interiorID then
							setElementPosition( value, getElementPosition( interior.outside ) )
							setElementInterior( value, getElementInterior( interior.outside ) )
							setElementDimension( value, getElementDimension( interior.outside ) )
						end
					end
					
					-- cleanup now unused shops
					exports.shops:clearDimension( interiorID )
					
					-- delete the markers
					destroyElement( interior.outside )
					destroyElement( interior.inside )
					if interior.blip then
						destroyElement( interior.blip )
					end
				else
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Interior not found.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)


addCommandHandler( "setinterior",
	function( player, commandName, id )
		if id then
			local int = interiors[ getElementDimension( player ) ]
			if int then
				interior = interiorPositions[ id:lower( ) ]
				if interior then
					if exports.sql:query_free( "UPDATE interiors SET insideX = " .. interior.x .. ", insideY = " .. interior.y .. ", insideZ = " .. interior.z .. " , insideInterior = " .. interior.interior .. " WHERE interiorID = " .. getElementDimension( player ) ) then
						-- move the colshape
						setElementPosition( int.inside, interior.x, interior.y, interior.z )
						setElementInterior( int.inside, interior.interior )
						
						-- teleport all players to the new point
						for key, value in ipairs( getElementsByType( "player" ) ) do
							if exports.players:isLoggedIn( value ) and getElementDimension( value ) == getElementDimension( player ) then
								setElementPosition( value, interior.x, interior.y, interior.z )
								setElementInterior( value, interior.interior )
							end
						end
						
						-- create a blip if used
						if int.blip then
							destroyElement( int.blip )
							int.blip = nil
						end
						int.blip = not int.locked and getElementDimension( int.outside ) == 0 and not getElementData( int.outside, "price" ) and createBlipEx( int.outside, int.inside )
						
						-- show a message
						outputChatBox( "Interior updated - new id: " .. id:lower( ) .. ".", player, 0, 255, 0 )
					else
						outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Interior " .. id .. " does not exist.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "You are not in an interior.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "setinteriorprice",
	function( player, commandName, price )
		price = math.ceil( tonumber( price ) or -1 )
		if price and price >= 0 then
			local int = interiors[ getElementDimension( player ) ]
			if int then
				-- change the price in the db
				if exports.sql:query_free( "UPDATE interiors SET interiorPrice = " .. price .. " WHERE interiorID = " .. getElementDimension( player ) ) then
					if getElementData( int.outside, "price" ) then
						setElementData( int.outside, "price", price )
					end
					
					-- update the price
					int.price = price
					
					-- show a message
					outputChatBox( "Interior updated - new price: $" .. price .. ".", player, 0, 255, 0 )
				else
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "You are not in an interior.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [price]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "setinteriorname",
	function( player, commandName, ... )
		local name = table.concat( { ... }, " " )
		if #name > 0 then
			local int = interiors[ getElementDimension( player ) ]
			if int then
				-- change the price in the db
				if exports.sql:query_free( "UPDATE interiors SET interiorName = '%s' WHERE interiorID = " .. getElementDimension( player ), name ) then
					-- update the name
					int.name = name
					setElementData( int.outside, "name", name )
					
					-- show a message
					outputChatBox( "Interior updated - new name: " .. name .. ".", player, 0, 255, 0 )
				else
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "You are not in an interior.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [price]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "getinterior",
	function( player, ... )
		-- check if he has permissions to see at least one prop
		local int = interiors[ getElementDimension( player ) ]
		if int then
			if hasObjectPermissionTo( player, "command.createinterior", false ) or hasObjectPermissionTo( player, "command.deleteinterior", false ) or hasObjectPermissionTo( player, "command.setinterior", false ) or hasObjectPermissionTo( player, "command.setinteriorprice", false ) then
				local interior = getElementInterior( int.inside )
				local x, y, z = getElementPosition( int.inside )
				
				local name, i = getInteriorIDAt( x, y, z, interior )
				
				-- check if he has permissions to view each of the props
				outputChatBox( "-- Interior " .. getElementDimension( player ) .. " --", player, 255, 255, 255 )
				
				if hasObjectPermissionTo( player, "command.createinterior", false ) or hasObjectPermissionTo( player, "command.deleteinterior", false ) or hasObjectPermissionTo( player, "command.setinterior", false ) then
					outputChatBox( "id: " .. name, player, 255, 255, 255 )
				end
				
				if hasObjectPermissionTo( player, "command.createinterior", false ) or hasObjectPermissionTo( player, "command.setinteriorname", false ) then
					outputChatBox( "name: " .. int.name, player, 255, 255, 255 )
				end
				
				if hasObjectPermissionTo( player, "command.createinterior", false ) or hasObjectPermissionTo( player, "command.setinteriorprice", false ) then
					outputChatBox( "price: " .. int.price, player, 255, 255, 255 )
				end
			else
				outputChatBox( "Your Interior: " .. getElementDimension( player ), player ,255, 255, 255 )
			end
		else
			outputChatBox( "You are not in an interior.", player, 255, 0, 0 )
		end
	end
)

addCommandHandler( { "sellinterior", "sellproperty" },
	function( player, ... )
		local interiorID = getElementDimension( player )
		local interior = interiors[ interiorID ]
		if interior then
			-- we can only sell owned houses
			if interior.type > 0 and interior.characterID == exports.players:getCharacterID( player ) then
				-- update the sql before anything else
				if exports.sql:query_free( "UPDATE interiors SET characterID = 0 WHERE interiorID = " .. interiorID ) then
					interiors.characterID = 0
					exports.players:giveMoney( player, math.floor( interior.price / 2 ) )
					
					-- restore the element data which shows it as not sold
					setElementData( interior.outside, "type", interior.type )
					setElementData( interior.outside, "price", interior.price )
					
					-- TODO: destroy all house keys
					-- for now: destroy the person's key
					exports.items:take( player, 2, interior.id )
					
					-- destroy a blip if there was one
					if isElement( interior.blip ) then
						destroyElement( interior.blip )
						interior.blip = nil
					end
					
					-- teleport all players who're inside to the exit
					for key, value in ipairs( getElementsByType( "player" ) ) do
						if exports.players:isLoggedIn( value ) and getElementDimension( value ) == interiorID then
							setElementPosition( value, getElementPosition( interior.outside ) )
							setElementInterior( value, getElementInterior( interior.outside ) )
							setElementDimension( value, getElementDimension( interior.outside ) )
						end
					end
					
					-- show a message
					outputChatBox( "You sold this house for $" .. math.floor( interior.price / 2 ) .. ".", player, 0, 255, 0 )
				else
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "This is not your house.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "You are not in an interior.", player, 255, 0, 0 )
		end
	end
)

--

local p = { }

local function enterInterior( player, key, state, colShape )
	local data = colspheres[ colShape ]
	if data then
		local interior = interiors[ data.id ]
		if interior.type > 0 and interior.characterID == 0 then
			-- buy the interior
			if exports.players:takeMoney( player, interior.price ) then
				local characterID = exports.players:getCharacterID( player )
				if characterID then
					-- update the owner if possible
					if exports.sql:query_free( "UPDATE interiors SET characterID = " .. characterID .. " WHERE interiorID = " .. data.id ) then
						interior.characterID = characterID
						
						-- remove our element data that claims this as buyable
						removeElementData( interior.outside, "type" )
						removeElementData( interior.outside, "price" )
						
						-- give him the house key
						exports.items:give( player, 2, data.id )
						
						-- stick a blip to it
						interior.blip = not interior.locked and interior.outsideDimension == 0 and createBlipEx( interior.outside, interior.inside )
						
						-- message to the player
						outputChatBox( "Congratulations! You've bought " .. interior.name .. " for $" .. interior.price .. "!", player, 0, 255, 0 )
					else
						outputChatBox( "MySQL-Error.", player, 255, 0, 0 )
						exports.players:giveMoney( player, interior.price )
					end
				end
			else
				outputChatBox( "You need $" .. ( interior.price - exports.players:getMoney( player ) ) .. " to buy this property.", player, 255, 0, 0 )
			end
		elseif interior.type > 0 and interior.locked then
			exports.chat:me( player, "tries the door handle yet without success." )
		else
			local other = data.other
			if other then
				triggerEvent( "onColShapeLeave", colShape, player, true )
				-- teleport the player
				setElementDimension( player, getElementDimension( other ) )
				setElementInterior( player, getElementInterior( other ) )
				setCameraInterior( player, getElementInterior( other ) )
				setElementPosition( player, getElementPosition( other ) )
				setCameraTarget( player, player )
				
				triggerEvent( "onColShapeHit", other, player, true )
			end
		end
	end
end

local function lockInterior( player, key, state, colShape )
	local data = colspheres[ colShape ]
	if data then
		if exports.items:has( player, 2, data.id ) then
			if exports.sql:query_free( "UPDATE interiors SET locked = 1 - locked WHERE interiorID = " .. data.id ) then
				local interior = interiors[ data.id ]
				exports.chat:me( player, "puts the key in the door to " .. ( interior.locked and "un" or "" ) .. "lock it. ((" .. interior.name .. "))" )
				interior.locked = not interior.locked
				
				if interior.locked and interior.blip then
					destroyElement( interior.blip )
					interior.blip = nil
				elseif not interior.locked and getElementDimension( interior.outside ) == 0 and not getElementData( interior.outside, "price" ) then
					interior.blip = createBlipEx( interior.outside, interior.inside )
				end
			end
		end
	end
end

addEventHandler( "onColShapeHit", resourceRoot,
	function( element, matching )
		if matching and getElementType( element ) == "player" then
			if p[ element ] then
				unbindKey( element, "enter_exit", "down", enterInterior, p[ element ] )
				unbindKey( element, "k", "down", lockInterior, p[ element ] )
			end
			
			p[ element ] = source
			bindKey( element, "enter_exit", "down", enterInterior, p[ element ] )
			bindKey( element, "k", "down", lockInterior, p[ element ] )
			setElementData( element, "interiorMarker", true, false )
		end
	end
)

addEventHandler( "onColShapeLeave", resourceRoot,
	function( element, matching )
		if getElementType( element ) == "player" and p[ element ] then
			unbindKey( element, "enter_exit", "down", enterInterior, p[ element ] )
			unbindKey( element, "k", "down", lockInterior, p[ element ] )
			removeElementData( element, "interiorMarker", true, false )
			p[ element ] = nil
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)

addEventHandler( "onVehicleStartEnter", root,
	function( player )
		if p[ player ] then
			-- stop players from entering a vehicle while in an interior marker
			cancelEvent( )
		end
	end
)

--

function getInterior( id )
	return interiors[ id ]
end

function setDropOff( id, x, y, z )
	if interiors[ id ] and type( x ) == "number" and type( y ) == "number" and type( z ) == "number" then
		if exports.sql:query_free( "UPDATE interiors SET dropoffX = " .. x .. ", dropoffY = " .. y .. ", dropoffZ = " .. z .. " WHERE interiorID = " .. id ) then
			interiors[ id ].dropoff = { x, y, z }
			return true
		end
	end
end
