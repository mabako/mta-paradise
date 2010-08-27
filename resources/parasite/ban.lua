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

function ban( player, reason )
	-- write a log entry for it
	local r = getRealTime( )
	local file = fileExists( "parasite.log" ) and fileOpen( "parasite.log" ) or fileCreate( "parasite.log" )
	local size = fileGetSize( file )
	fileSetPos( file, size )
	fileWrite( file, "[" .. ("%04d-%02d-%02d %02d:%02d"):format(r.year+1900, r.month + 1, r.monthday, r.hour,r.minute) .. "] Account: " .. tostring( exports.players:getUserName( player ) ) .. " - Name: " .. getPlayerName( player ) .. " - IP: " .. getPlayerIP( player ) .. " - Serial: " .. ( getPlayerSerial( player ) or "?" ) .. " - Reason: " .. reason .. "\r\n" )
	fileClose( file )
	
	-- ban in the database
	local userID = exports.players:getUserID( client )
	if userID then
		exports.sql:query_free( "UPDATE wcf1_user SET banned = 1, banReason = 'Hacks', banUser = 0 WHERE userID = " .. userID )
	end
	
	-- ban the player
	local serial = getPlayerSerial( client )
	banPlayer( client, true, false, false, root, "Hacks" )
	if serial then
		addBan( nil, nil, serial, root, "Hacks" )
	end
end
