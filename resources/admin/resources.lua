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

addCommandHandler( "restartall",
	function( player )
		for index, resource in ipairs ( getResources ( ) ) do
			if ( getResourceState ( resource ) == "running" and getResourceName ( resource ) ~= "admin") then
				if not restartResource ( resource ) then
					outputServerLog( "restartall: Failed to restart '" .. getResourceName ( resource ) .. "' . Try starting it manually. If error persists, restarting the server is recommended." )
				end
			end
		end
		outputServerLog( "restartall: Restarting all resources" .. " (Requested by " .. ( not player and "Console" or getAccountName( getPlayerAccount( player ) ) or getPlayerName(player) ) .. ")" )
		if ( player ) then
			outputChatBox ( "All resources have been restarted." )
		end
	end,
	true
)

addCommandHandler( "startall",
	function( player )
		for index, resource in ipairs ( getResources ( ) ) do
			if ( getResourceState ( resource ) == "loaded" ) then
				if not startResource ( resource ) then
					outputServerLog( "startall: Failed to start resource '" .. getResourceName ( resource ) .. "' . Try starting it manually. If error persists, restarting the server is recommended." )
				end
			end
		end
		outputServerLog( "startall: Starting all resources. " .. " (Requested by " .. ( not player and "Console" or getAccountName( getPlayerAccount( player ) ) or getPlayerName(player) ) .. ")" )
		if ( player ) then
			outputChatBox ( "All resources have been started." )
		end
	end,
	true
)
