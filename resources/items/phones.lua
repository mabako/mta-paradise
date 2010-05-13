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

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		if not exports.sql:create_table( 'phones',
			{
				{ name = 'phoneNumber', type = 'int(10) unsigned', primary_key = true, auto_increment = 10000 },
			} ) then cancelEvent( ) return end
	end
)

-- we need to export a function to generate a new (unused) phone number, really
function createPhone( )
	local number = exports.sql:query_insertid( "INSERT INTO phones VALUES ()" );
	return number -- we don't want to return the MySQL error if that failed
end
