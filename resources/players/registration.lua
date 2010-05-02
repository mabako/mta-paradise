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

local allowRegistration = tonumber( get( 'allow_registration' ) ) == 1 and true or false
local registrationErrorMessage = get( 'registration_error_message' )
if registrationErrorMessage then
	-- fix for newlines in message
	registrationErrorMessage = registrationErrorMessage:gsub( "\\n", "\n" )
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		setElementData( source, "allowRegistration", allowRegistration )
		setElementData( source, "registrationErrorMessage", registrationErrorMessage )
	end
)

local function trim( str )
	return str:gsub("^%s*(.-)%s*$", "%1")
end

addEvent( getResourceName( resource ) .. ":register", true )
addEventHandler( getResourceName( resource ) .. ":register", root,
	function( username, password )
		if source == client then
			if allowRegistration then
				if username and password then
					username = trim( username )
					password = trim( password )
					
					-- client length checks are the same
					if #username >= 3 and #password >= 8 then
						-- see if that username is free at all
						local info = exports.sql:query_assoc_single( "SELECT COUNT(userID) AS usercount FROM wcf1_user WHERE username = '%s'", username )
						if not info then
							triggerClientEvent( source, getResourceName( resource ) .. ":registrationResult", source, 1 )
						elseif info.usercount == 0 then
							-- generate a salt (SHA1)
							local salt = ''
							local chars = { 'a', 'b', 'c', 'd', 'e', 'f', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
							for i = 1, 40 do
								salt = salt .. chars[ math.random( 1, #chars ) ]
							end
							
							-- create the user
							if exports.sql:query_free( "INSERT INTO wcf1_user (username,salt,password) VALUES ('%s', '%s', SHA1(CONCAT('%s', SHA1(CONCAT('%s', " .. ( sha1 and ( "'" .. sha1( password ) .. "'" ) or "SHA1('%s')" ) .. ")))))", username, salt, salt, salt, not sha1 and password ) then
								triggerClientEvent( source, getResourceName( resource ) .. ":registrationResult", source, 0 ) -- will automatically login when this is sent
							else
								triggerClientEvent( source, getResourceName( resource ) .. ":registrationResult", source, 3 )
							end
						else
							triggerClientEvent( source, getResourceName( resource ) .. ":registrationResult", source, 3 )
						end
					else
						-- shouldn't happen
						triggerClientEvent( source, getResourceName( resource ) .. ":registrationResult", source, 1 )
					end
				else
					-- can't do much without a username and password
					triggerClientEvent( source, getResourceName( resource ) .. ":registrationResult", source, 1 )
				end
			else
				triggerClientEvent( source, getResourceName( resource ) .. ":registrationResult", source, 2, registrationErrorMessage )
			end
		end
	end
)
