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
end

--

local p = { }
local shops = { }
local dimensions = { }

local function createShopPed( shopID )
	local shop = shops[ shopID ]
	if shop then
		local ped = createPed( shop.skin ~= 0 and shop.skin or shop_configurations[ shop.configuration ].skin, shop.x, shop.y, shop.z, shop.rotation )
		if ped then
			shops[ ped ] = shopID
			shop.ped = ped
			
			setPedRotation( ped, shop.rotation )
			setElementInterior( ped, shop.interior )
			setElementDimension( ped, shop.dimension )
			setPedFrozen( ped, true )
			
			return true
		end
	end
	outputDebugString( "Failed to create Shop " .. tostring( shopID ) )
	return false
end

addEventHandler( "onPedWasted", resourceRoot,
	function( )
		local shopID = shops[ source ]
		if shopID then
			shops[ source ] = nil
			destroyElement( source )
			
			createShopPed( shopID )
		end
	end
)

local function loadShop( shopID, x, y, z, rotation, interior, dimension, configuration, skin )
	shops[ shopID ] = { shopID = shopID, x = x, y = y, z = z, rotation = rotation, interior = interior, dimension = dimension, configuration = configuration, skin = skin }
	if not createShopPed( shopID ) then
		outputDebugString( "shop creation failed: shop " .. tostring( shopID ) )
	end
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		-- check for our tables to exist
		if not exports.sql:create_table( 'shops', 
			{
				{ name = 'shopID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'x', type = 'float' },
				{ name = 'y', type = 'float' },
				{ name = 'z', type = 'float' },
				{ name = 'rotation', type = 'float' },
				{ name = 'interior', type = 'tinyint(3) unsigned' },
				{ name = 'dimension', type = 'int(10) unsigned' },
				{ name = 'configuration', type = 'varchar(45)' },
				{ name = 'skin', type = 'int(10) unsigned', default = 0 },
			} ) then cancelEvent( ) return end
		
		if not exports.sql:create_table( 'shopitems',
			{
				{ name = 'shopItemID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'shopID', type = 'int(10) unsigned' },
				{ name = 'item', type = 'int(10) unsigned' },
				{ name = 'value', type = 'text' },
				{ name = 'name', type = 'text', null = true },
				{ name = 'description', type = 'text', null = true },
				{ name = 'price', type = 'int(10) unsigned' },
			} ) then cancelEvent( ) return end
		
		--
		
		local result = exports.sql:query_assoc( "SELECT * FROM shops ORDER BY shopID ASC" )
		if result then
			for key, data in ipairs( result ) do
				loadShop( data.shopID, data.x, data.y, data.z, data.rotation, data.interior, data.dimension, data.configuration, data.skin )
				
				dimensions[ data.dimension ] = true
				if exports['job-delivery'] then
					exports['job-delivery']:addDropOff( data.dimension )
				end
			end
		end
		
		--
		
		local result = exports.sql:query_assoc( "SELECT * FROM shopitems ORDER BY shopItemID ASC" )
		if result then
			for key, data in ipairs( result ) do
				local shop = shops[ data.shopID ]
				if shop then
					if not shop.items then
						shop.items = { }
					end
					table.insert( shop.items, { itemID = data.item, itemValue = data.value, name = data.name and data.name ~= "" and data.name, description = data.description and data.description ~= "" and data.description, price = data.price } )
				end
			end
		end
	end
)

addCommandHandler( "createshop",
	function( player, commandName, config )
		if config then
			if shop_configurations[ config ] then
				local x, y, z = getElementPosition( player )
				local rotation = getPedRotation( player )
				local interior = getElementInterior( player )
				local dimension = getElementDimension( player )
				
				local shopID = exports.sql:query_insertid( "INSERT INTO shops (x, y, z, rotation, interior, dimension, configuration) VALUES (" .. table.concat( { x, y, z, rotation, interior, dimension, '"%s"' }, ", " ) .. ")", config )
				if shopID then
					loadShop( shopID, x, y, z, rotation, interior, dimension, config, 0 )
					
					outputChatBox( "Created new shop with ID " .. shopID .. ", type is " .. config .. ".", player, 0, 255, 0 )
					exports['job-delivery']:addDropOff( dimension )
				else
					outputChatBox( "Shop creation failed (SQL-Error).", player, 255, 0, 0 )
				end
			else
				outputChatBox( "There is no configuration named '" .. config .. "'.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [type]", player, 255, 255, 255 )
		end
	end,
	true
)

local function deleteShop( shopID )
	local shop = shops[ shopID ]
	if shop then
		-- close gui using this shop
		for player, data in pairs( p ) do
			if data.shopID == shopID then
				triggerClientEvent( player, "shops:clear", shop.ped or resourceRoot )
				p[ player ].shopID = nil
			end
		end
		
		-- remove from shops list
		if shop.ped then
			destroyElement( shop.ped )
			shops[ shop.ped ] = nil
		end
		
		-- unset
		shops[ shopID ] = nil
		
		-- check if we still have any shops in this dimension
		local stillHasAShop = false
		for key, value in pairs( shops ) do
			if value.dimension == shop.dimension then
				stillHasAShop = true
				break
			end
		end
		
		if not stillHasAShop and exports['job-delivery'] then
			dimensions[ shop.dimension ] = nil
			exports['job-delivery']:removeDropOff( shop.dimension )
		end
	end
end

addCommandHandler( { "deleteshop", "delshop" },
	function( player, commandName, shopID )
		shopID = tonumber( shopID )
		if shopID then
			local shop = shops[ shopID ]
			if shop then
				if exports.sql:query_free( "DELETE FROM shops WHERE shopID = " .. shopID ) and exports.sql:query_free( "DELETE FROM shopitems WHERE shopID = " .. shopID ) then
					outputChatBox( "You deleted shop " .. shopID .. ".", player, 0, 255, 153 )
					deleteShop( shopID )
				else
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Shop not found.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "nearbyshops",
	function( player, commandName )
		if hasObjectPermissionTo( player, "command.createshop", false ) or hasObjectPermissionTo( player, "command.deleteshop", false ) then
			local x, y, z = getElementPosition( player )
			local dimension = getElementDimension( player )
			local interior = getElementInterior( player )
			
			outputChatBox( "Nearby Shops:", player, 255, 255, 0 )
			for key, value in pairs( shops ) do
				if isElement( key ) and getElementDimension( key ) == dimension and getElementInterior( key ) == interior then
					local distance = getDistanceBetweenPoints3D( x, y, z, getElementPosition( key ) )
					if distance < 20 then
						outputChatBox( "  Shop " .. value .. " - Type: " .. tostring( shops[ value ].configuration ) .. ".", player, 255, 255, 0 )
					end
				end
			end
		end
	end
)

-- client interaction

addEventHandler( "onElementClicked", resourceRoot,
	function( button, state, player )
		if button == "left" and state == "up" then
			local shopID = shops[ source ]
			if shopID then
				local shop = shops[ shopID ]
				if shop then
					local x, y, z = getElementPosition( player )
					if getDistanceBetweenPoints3D( x, y, z, getElementPosition( source ) ) < 5 and getElementDimension( player ) == getElementDimension( source ) then
						if not p[ player ] then
							p[ player ] = { synched = { } }
						end
						p[ player ].shopID = shopID
						
						if shop.items then -- custom items
							-- these are manually synched if not sent yet
							if not p[ player ].synched[ shopID ] then
								triggerClientEvent( player, "shops:sync", source, shopID, shop.items )
								p[ player ].synched[ shopID ] = true
							end
							
							triggerClientEvent( player, "shops:open", source, shopID )
						elseif shop_configurations[ shop.configuration ] then
							triggerClientEvent( player, "shops:open", source, shop.configuration )
						end
					end
				end
			end
		end
	end
)

addEventHandler( "onCharacterLogout", root,
	function( )
		if p[ source ] then
			p[ source ].shopID = nil
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)

addEvent( "shops:close", true )
addEventHandler( "shop:close", root,
	function( )
		if source == client then
			p[ source ].shopID = nil
		end
	end
)

addEvent( "shops:buy", true )
addEventHandler( "shops:buy", root,
	function( key )
		if source == client and type( key ) == "number" then
			-- check if the player is even meant to shop, if so only the index is transferred so we need to know where
			if p[ source ] then
				local shop = shops[ p[ source ].shopID ]
				if shop then
					-- check if it's a valid item
					local item = shop.items and shop.items[ key ] or shop_configurations[ shop.configuration ][ key ]
					if item then
						if exports.players:takeMoney( source, item.price ) then
							local value = item.itemID == 7 and exports.items:createPhone( ) or item.itemValue
							if exports.items:give( source, item.itemID, value, item.name ) then
								outputChatBox( "You've bought a " .. ( item.name or exports.items:getName( item.itemID ) ) .. " for $" .. item.price .. ".", source, 0, 255, 0 )
								if item.itemID == 7 then
									outputChatBox( "Your phone number is #" .. value .. ".", source, 0, 255, 0 )
								end
							end
						else
							outputChatBox( "You can't afford to buy a " .. ( item.name or exports.items:getName( item.itemID ) ) .. ".", source, 0, 255, 0 )
						end
					end
				end
			end
		end
	end
)

--

function clearDimension( dimension )
	if dimension then
		for key, value in pairs( shops ) do
			if type( value ) == "table" then
				if value.dimension == dimension then
					if exports.sql:query_free( "DELETE FROM shops WHERE shopID = " .. value.shopID ) and exports.sql:query_free( "DELETE FROM shopitems WHERE shopID = " .. value.shopID ) then
						deleteShop( value.shopID )
					end
				end
			end
		end
	end
end

function getAllDimensions( )
	return dimensions
end
