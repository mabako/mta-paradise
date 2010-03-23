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

local data = { }

local function notify( element, to )
	-- is loaded
	if data[ element ] then
		-- support for both single and multiple users
		if to then
			to = { [ to ] = true }
		else
			to = data[ element ].subscribers
		end
		
		-- easier
		local items = data[ element ].items
		
		-- send it to every reciever
		for value in pairs( to ) do
			triggerClientEvent( value, "syncItems", value, items )
		end
	else
		-- not loaded, send no items
		triggerClientEvent( to, "syncItems", to )
	end
end

local function getID( element )
	if getElementType( element ) == "player" then
		return exports.players:getCharacterID( element )
	end
end

local function load( element, force )
	if isElement( element ) then
		local elementID = getID( element )
		if elementID then
			if force or not data[ element ] or data[ element ].id ~= elementID then
				-- initalize a table for it
				data[ element ] = {
					['items'] = { },
					['subscribers'] = { },
					id = elementID
				}
				
				-- load items
				local i = exports.sql:query_assoc( "SELECT `index`, item, value, name FROM items WHERE owner = " .. elementID )
				for key, value in ipairs( i ) do
					table.insert( data[ element ].items, value )
				end
				
				-- player should get notified of his items
				if getElementType( element ) == "player" then
					data[ element ].subscribers[ element ] = true
					notify( element, element )
				end
				
				return true
			end
			return true
		end
		return false, "Element has no unique ID"
	end
	return false, tostring( element ) .. " is no element"
end

local function subscribe( element, to )
	-- Make sure we have an element to subscribe to
	if load( to ) then
		-- subscribe to the element
		data[ to ].subscribers[ element ] = true
		return true
	end
	return false, "Unable to load element"
end

function get( element )
	if load( element ) then
		return data[ element ].items
	end
end

function give( element, item, value, name )
	-- we need a base to work on
	if load( element ) then
		-- we need at least item and value
		if type( item ) == 'number' and ( type( value ) == "number" or type( value ) == "string" ) then
			name2 = "NULL"
			if name then
				name2 = "'" .. exports.sql:escape_string( tostring( name ) ) .. "'"
			else
				name = nil
			end
			
			local index, error = exports.sql:query_insertid( "INSERT INTO items (owner, item, value, name) VALUES (" .. getID( element ) .. ", " .. item .. ", '%s', " .. name2 .. ")", value )
			if index then
				table.insert( data[ element ].items, { index = index, item = item, value = value, name = name } )
				notify( element )
				return true
			end
			return false, "MySQL Query failed"
		end
		return false, "Invalid Parameters"
	end
	return false, "Unable to load element"
end

local function unload( element )
	-- clear old references
	if data[ element ] then
		-- don't have any items
		data[ element ].items = nil
		
		-- tell everyone who cares
		notify( element )
		
		-- delete
		data[ element ] = nil
		return true
	end
	return false, "Element has no loaded items"
end

local function unsubscribe( element, from )
	if from then
		-- we need to have an actual item to unsubscribe from
		if load( from ) then
			-- remove our reference
			data[ from ].subscribers[ element ] = nil
		end
		return true
	else
		-- look through all saved items
		for key, value in pairs( data ) do
			-- remove subscriber reference if exists
			if value.subscribers[ element ] then
				value.subscribers[ element ] = nil
			end
		end
	end
end

addEventHandler( "onElementDestroy", root,
	function( )
		unload( source )
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		unload( source )
		unsubscribe( source )
	end
)

addEventHandler( "onCharacterLogin", root,
	function( )
		load( source, true )
	end
)

addEventHandler( "onCharacterLogout", root,
	function( )
		unload( source )
		unsubscribe( source )
	end
)

addEvent( "loadItems", true )
addEventHandler( "loadItems", root,
	function( )
		if source == client then
			if exports.players:isLoggedIn( source ) then
				load( source, true )
			end
		end
	end
)