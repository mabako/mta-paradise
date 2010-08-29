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

local p = { }

local function getStaff( duty )
	local t = { }
	for key, value in ipairs( getElementsByType( "player" ) ) do
		if hasObjectPermissionTo( value, "command.acceptreport", false ) then
			if not duty or exports.players:getOption( value, "staffduty" ) then
				t[ #t + 1 ] = value
			end
		end
	end
	return t
end

local function staffMessage( message )
	for key, value in ipairs( getStaff( true ) ) do
		outputChatBox( message, value, 255, 204, 255 )
	end
end

local tokenCounter = 0
local function getNewToken( )
	local token
	repeat
		tokenCounter = tokenCounter + 1
		token = string.char( math.random( string.byte( "a" ), string.byte( "z" ) ), math.random( string.byte( "a" ), string.byte( "z" ) ), math.random( string.byte( "a" ), string.byte( "z" ) ) )
		for key, value in pairs( p ) do
			if value.token == token then
				token = nil
				break
			end
		end
	until token
	return token
end

local function getReport( token )
	for key, value in pairs( p ) do
		if value.token == token then
			return key, value
		end
	end
end

local function count( t )
	local c = 0
	for key, value in pairs( t ) do
		c = c + 1
	end
	return c
end

local function clearReport( player )
	if p[ player ] then
		local pos = p[ player ].pos
		p[ player ] = nil

		-- free the queue position
		for key, value in pairs( p ) do
			if value.pos >= pos then
				value.pos = value.pos - 1
			end
		end
	end
end

local function otherReports( ignore )
	local other = { }
	for i = 1, math.min( 4, count( p ) ) do
		for key, value in pairs( p ) do
			if value.pos == i then
				if key ~= ignore then
					table.insert( other, value.token )
				end
				break
			end
		end
	end
	
	if #other > 0 then
		local cnt = count( p ) - ( ignore and 1 or 0 )
		return cnt .. " remaining reports: " .. table.concat( other, ", " ) .. ( cnt > #other and ", ..." or "" )
	else
		return ""
	end
end

addCommandHandler( { "report", "re" },
	function( player, commandName, other, ... )
		if not p[ player ] then
			if other and ( ... ) then
				if other == "-" then
					other = "*"
				end
				
				local other, name = exports.players:getFromName( player, other )
				if other then
					local reason = table.concat( { ... }, " " )
					p[ player ] = { other = other, pos = count( p ) + 1, reason = reason, time = { getTime( ) }, token = getNewToken( ) }
					if other == player then
						outputChatBox( "[" .. p[ player ].token .. "] You opened a new report, it's on position " .. p[ player ].pos .. " in queue. You can close it at any time by using /endreport.", player, 255, 102, 204 )
					else
						outputChatBox( "[" .. p[ player ].token .. "] You reported [" .. exports.players:getID( other ) .. "] " .. name .. ", your report is on position " .. p[ player ].pos .. " in queue. You can close it at any time by using /endreport.", player, 255, 102, 204 )
					end
					outputChatBox( "Reason: " .. reason, player, 255, 102, 204 )
					
					staffMessage( "[" .. p[ player ].token .. "] [" .. exports.players:getID( player ) .. "] "  .. getPlayerName( player ):gsub( "_", " " ) .. " reported [" .. exports.players:getID( other ) .. "] " .. name .. ". /ar " .. p[ player ].token .. " to accept it. (Queue #" .. p[ player ].pos .. ")" )
					staffMessage( "[" .. p[ player ].token .. "] Reason: " .. reason )
				end
			else
				outputChatBox( "Syntax: /" .. commandName .. " [player or -] [reason]", player, 255, 255, 255 )
			end
		else
			outputChatBox( "Your report [" .. p[ player ].token .. "] is on position " .. p[ player ].pos .. " in the queue. Use /endreport to close your report.", player, 255, 102, 204 )
		end
	end
)

addCommandHandler( { "endreport", "er" },
	function( player, commandName )
		if p[ player ] then
			staffMessage( "[" .. p[ player ].token .. "] [" .. exports.players:getID( player ) .. "] "  .. getPlayerName( player ):gsub( "_", " " ) .. " closed his/her report. " .. otherReports( player ) )
			outputChatBox( "You closed your report.", player, 255, 102, 204 )
			clearReport( player )
		else
			outputChatBox( "You don't have a report open.", player, 255, 102, 204 )
		end
	end
)

addCommandHandler( "reports",
	function( player, commandName )
		if hasObjectPermissionTo( player, "command.acceptreport", false ) then
			outputChatBox( count( p ) .. " reports:", player, 255, 204, 255 )
			for i = 1, count( p ) do
				for reporter, report in pairs( p ) do
					if report.pos == i then
						outputChatBox( "  #" .. i .. " - " .. ( "%02d:%02d" ):format( unpack( report.time ) ) .. " [" .. report.token .. "] [" .. exports.players:getID( reporter ) .. "] "  .. getPlayerName( reporter ):gsub( "_", " " ) .. " reported [" .. exports.players:getID( report.other ) .. "] " .. getPlayerName( report.other ):gsub( "_", " " ) .. ". Handler: " .. ( report.handler and getPlayerName( report.handler ):gsub( "_", " " ) or "None" ) .. ".", player, 255, 204, 255 )
						outputChatBox( "  #" .. i .. " - " .. ( "%02d:%02d" ):format( unpack( report.time ) ) .. " [" .. report.token .. "] Reason: " .. report.reason, player, 255, 204, 255 )
						break
					end
				end
			end
		end
	end
)

addCommandHandler( { "acceptreport", "ar" },
	function( player, commandName, report )
		if report then
			local reporter, report = getReport( report )
			if report then
				if report.handler then
					outputChatBox( getPlayerName( report.handler ):gsub( "_", " " ) .. " is already handling this report.", player, 255, 0, 0 )
				else
					report.handler = player
					staffMessage( "[" .. report.token .. "] "  .. getPlayerName( player ):gsub( "_", " " ) .. " accepted the report." )
					outputChatBox( getPlayerName( player ):gsub( "_", " " ) .. " accepted your report.", reporter, 0, 255, 153 )
				end
			else
				outputChatBox( "This report does not exist.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [report]", player, 255, 255, 255 )
		end
	end
)

addCommandHandler( { "closereport", "cr" },
	function( player, commandName, report, ... )
		if hasObjectPermissionTo( player, "command.acceptreport", false ) then
			if report then
				local reporter, report = getReport( report )
				if report then
					if report.handler and report.handler ~= player then
						outputChatBox( "You are not handling this report.", player, 255, 0, 0 )
					else
						staffMessage( "[" .. report.token .. "] "  .. getPlayerName( player ):gsub( "_", " " ) .. " closed the report. " .. otherReports( reporter ) )
						if ( ... ) then
							staffMessage( "[" .. report.token .. "] Comment: " .. table.concat( { ... }, " " ) )
						end
						outputChatBox( getPlayerName( player ):gsub( "_", " " ) .. " closed your report.", reporter, 255, 102, 204 )
						if ( ... ) then
							outputChatBox( "Comment: " .. table.concat( { ... }, " " ), reporter, 255, 102, 204 )
						end
						clearReport( reporter )
					end
				else
					outputChatBox( "This report does not exist.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Syntax: /" .. commandName .. " [report] [comment]", player, 255, 255, 255 )
			end
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		if p[ source ] then
			staffMessage( "[" .. p[ source ].token .. "] [" .. exports.players:getID( source ) .. "] "  .. getPlayerName( source ):gsub( "_", " " ) .. " left the server. Report is closed. " .. otherReports( source ) )
			clearReport( source )
		end
		
		for player, report in pairs( p ) do
			if report.other == source then
				staffMessage( "[" .. p[ source ].token .. "] Reported player [" .. exports.players:getID( source ) .. "] "  .. getPlayerName( source ):gsub( "_", " " ) .. " left the server. Report is closed. " .. otherReports( player ) )
				outputChatBox( "Your report was closed, as " .. getPlayerName( source ):gsub( "_", " " ) .. " left the server.", player, 255, 102, 204 )
				clearReport( player )
			elseif report.handler == source then
				staffMessage( "[" .. p[ source ].token .. "] Handler [" .. exports.players:getID( source ) .. "] "  .. getPlayerName( source ):gsub( "_", " " ) .. " left the server. Report is unassigned. " .. otherReports( ) )
				outputChatBox( getPlayerName( source ):gsub( "_", " " ) .. " left the server - your report is unassigned.",  player, 255, 102, 204 )
				report.handler = nil
			end
		end
	end
)
