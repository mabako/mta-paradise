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

local connection = nil
local connection = nil
local null = nil
local results = { }

-- connection functions
local function connect( )
	-- retrieve the settings
	local server = get( "server" ) or "localhost"
	local user = get( "user" ) or "root"
	local password = get( "password" ) or ""
	local db = get( "database" ) or "mta"
	local port = get( "port" ) or 3306
	
	-- connect
	connection = mysql_connect ( server, user, password, db, port )
	if connection then
		return true
	else
		outputDebugString ( "Connection to MySQL Failed.", 1 )
		return false
	end
end

local function disconnect( )
	if connection and mysql_ping( connection ) then
		mysql_close( connection )
	end
end

local function checkConnection( )
	if not connection or not mysql_ping( connection ) then
		return connect( )
	end
	return true
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		if not mysql_connect then
			if hasObjectPermissionTo( resource, "function.shutdown" ) then
				shutdown( "MySQL module missing." )
			end
			cancelEvent( true, "MySQL module missing." )
		elseif not hasObjectPermissionTo( resource, "function.mysql_connect" ) then
			if hasObjectPermissionTo( resource, "function.shutdown" ) then
				shutdown( "Insufficient ACL rights for mysql resource." )
			end
			cancelEvent( true, "Insufficient ACL rights for mysql resource." )
		elseif not connect( ) then
			if connection then
				outputDebugString( mysql_error( connection ), 1 )
			end
			
			if hasObjectPermissionTo( resource, "function.shutdown" ) then
				shutdown( "MySQL failed to connect." )
			end
			cancelEvent( true, "MySQL failed to connect." )
		else
			null = mysql_null( )
		end
	end
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		for key, value in pairs( results ) do
			mysql_free_result( value )
		end
		
		disconnect( )
	end
)

--

function escape_string( str )
	if type( str ) == "string" then
		return mysql_escape_string( connection, str )
	end
end

function query( str, ... )
	checkConnection( )
	
	if ( ... ) then
		local t = { ... }
		for k, v in ipairs( t ) do
			t[ k ] = escape_string( tostring( v ) ) or ""
		end
		str = str:format( unpack( t ) )
	end
	
	local result = mysql_query( connection, str )
	if result then
		local num = #results + 1
		results[ num ] = result
		return num
	end
	return false, mysql_error( connection )
end

function query_free( str, ... )
	checkConnection( )
	
	if ( ... ) then
		local t = { ... }
		for k, v in ipairs( t ) do
			t[ k ] = escape_string( tostring( v ) ) or ""
		end
		str = str:format( unpack( t ) )
	end
	
	local result = mysql_query( connection, str )
	if result then
		mysql_free_result( result )
		return true
	end
	return false, mysql_error( connection )
end

function free_result( result )
	if results[ result ] then
		mysql_free_result( results[ result ] )
		results[ result ] = nil
	end
end

function query_assoc( str, ... )
	local t = { }
	local result, error = query( str, ... )
	if result then
		for result, row in mysql_rows_assoc( results[ result ] ) do
			local num = #t + 1
			t[ num ] = { }
			for key, value in pairs( row ) do
				if value ~= null then
					t[ num ][ key ] = tonumber( value ) or value
				end
			end
		end
		free_result( result )
		return t
	end
	return false, error
end

function query_assoc_single( str, ... )
	local t = { }
	local result, error = query( str, ... )
	if result then
		local row = mysql_fetch_assoc( results[ result ] )
		if row then
			for key, value in pairs( row ) do
				if value ~= null then
					t[ key ] = tonumber( value ) or value
				end
			end
			return t
		end
		free_result( result )
		return false
	end
	return false, error
end

function query_insertid( str, ... )
	local id = false
	local result, error = query( str, ... )
	if result then
		id = mysql_insert_id( connection )
		free_result( result )
		return id
	end
	return false, error
end