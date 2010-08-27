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

local allowUpdate = get( 'auto_update' ) ~= 0 -- change this setting to 0 to only print the required queries to console but not actually change stuff, removing it or setting it to anything but 0 leaves it enabled

--

local query_update = nil
if allowUpdate then
	query_update = query_free
else
	query_update = function( str, ... )
			if ( ... ) then
				local t = { ... }
				for k, v in ipairs( t ) do
					t[ k ] = escape_string( tostring( v ) ) or ""
				end
				str = str:format( unpack( t ) )
			end
			outputServerLog( str )
			return true
		end
end
local function getColumnString( value )
	local str = "`" .. escape_string( value.name ) .. "` " .. escape_string( value.type )
	
	if not value.null then
		str = str .. " NOT NULL"
	end
	
	if value.default then
		if value.default == 'CURRENT_TIMESTAMP' then
			str = str .. " DEFAULT CURRENT_TIMESTAMP"
		else
			str = str .. " DEFAULT '" .. escape_string( tostring( value.default ) ) .. "'"
		end
	end
	
	if value.auto_increment then
		str = str .. " AUTO_INCREMENT"
	end
	
	return str
end

function create_table( name, columns )
	if sourceResource == getResourceFromName( "runcode" ) then
		return false
	end
	
	if not query_assoc_single( "SHOW TABLES LIKE '%s'", name ) then
		-- try to create the missing table
		local cols = { }
		local keys = { }
		local autoIncrementValue = ""
		
		for key, value in pairs( columns ) do
			if value.primary_key then
				table.insert( keys, "`" .. escape_string( value.name ) .."`" )
			end
			
			if type( value.auto_increment ) == "number" then
				autoIncrementValue = " AUTO_INCREMENT=" .. value.auto_increment
			end
			
			table.insert( cols, getColumnString( value ) )
		end
		
		if #keys > 0 then
			table.insert( cols, "PRIMARY KEY (" .. table.concat( keys, ", " ) .. ")" )
		end
		
		if query_update( "CREATE TABLE `%s`(\n  " .. table.concat( cols, ",\n  " ) .. "\n) ENGINE=MyISAM" .. autoIncrementValue, name ) then
			outputDebugString( "Created table " .. name, 3 )
			return true, true
		else
			outputDebugString( "Unable to create table " .. name, 1 )
			return false
		end
	else
		-- make sure all columns do exist
		local result = query_assoc( 'DESCRIBE ' .. name )
		local fields = { }
		local primary_keys = { }
		local has_primary_key = false
		local change_primary_keys = false
		
		for key, value in pairs( result ) do
			fields[ value.Field ] = { name = value.Field, type = value.Type, null = value.Null == "YES", auto_increment = value.Extra == "auto_increment", primary_key = value.Key == 'PRI' or nil, default = value.Default }
			if value.Key == 'PRI' then
				has_primary_key = true
			end
		end
		
		local insertWhere = "FIRST"
		for key, value in ipairs( columns ) do
			if not fields[ value.name ] then
				if query_update( "ALTER TABLE `%s` ADD " .. getColumnString( value ) .. " " .. insertWhere, name ) then
					outputDebugString( "Created column " .. name .. "." .. value.name, 3 )
				else
					outputDebugString( "Unable to create column " .. name .. "." .. value.name, 1 )
					return false
				end
			else
				-- let's check if everything is alright
				local f = fields[ value.name ]
				local str = getColumnString( value )
				if getColumnString( f ) ~= str then
					if query_update( "ALTER TABLE `%s` MODIFY COLUMN " .. str, name ) then
						outputDebugString( "Changed field " .. name .. "." .. value.name, 3 )
					else
						outputDebugString( "Changing field " .. name .. "." .. value.name .. " failed", 1 )
						return false
					end
				end
				
				-- verify our primary keys
				if value.primary_key then
					table.insert( primary_keys, "`" .. escape_string( value.name ) .."`" )
				end
				
				if f.primary_key ~= value.primary_key then
					change_primary_keys = true
				end
			end
			insertWhere = "AFTER `" .. escape_string( value.name ) .. "`"
		end
		
		-- change the primary key if we have to
		if change_primary_keys then
			outputDebugString( "Changing primary keys...", 3 )
			if has_primary_key then
				if #primary_keys == 0 then
					if not query_update( "ALTER TABLE `%s` DROP PRIMARY KEY", name ) then
						outputDebugString( "Unable to drop primary key", 1 )
						return false
					end
				else
					if not query_update( "ALTER TABLE `%s` DROP PRIMARY KEY, ADD PRIMARY KEY(" .. table.concat( primary_keys, ", " ) .. ")", name ) then
						outputDebugString( "Unable to change primary key", 1 )
						return false
					end
				end
			elseif #primary_keys > 0 then
				if not query_update( "ALTER TABLE `%s` ADD PRIMARY KEY(" .. table.concat( primary_keys, ", " ) .. ")", name ) then
					outputDebugString( "Unable to add new primary key", 1 )
					return false
				end
			end
		end
		return true, false
	end
end
