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

local resourceName = getResourceName( resource )

addEvent( resourceName .. ":gtasa", true )
addEventHandler( resourceName .. ":gtasa", root,
	function( cheat )
		if source == client and type( cheat ) == "string" then
			ban( client, "GTA:SA Cheat - " .. cheat )
		else
			ban( client, "Fake " .. resourceName .. ":gtasa event with param " .. tostring( cheat ) )
		end
	end
)

addEvent( resourceName .. ":update", true )
addEventHandler( resourceName .. ":update", root,
	function( gameSpeed, isNormalGameSpeed, gravity )
		if hasObjectPermissionTo( client, "command.crun", false ) then
			return -- we can skip that part as clients are allowed to do so
		elseif source == client and type( gameSpeed ) == "number" and type( isNormalGameSpeed ) == "boolean" and type( gravity ) == "number" then
			if gameSpeed ~= getGameSpeed( ) or ( getGameSpeed( ) == 1 ) ~= isNormalGameSpeed then
				ban( client, "Gamespeed Modification: " .. gameSpeed .. " - expected " .. getGameSpeed( ) )
			elseif gravity * 100000 ~= getGravity( ) * 100000 then
				ban( client, "Gravity Modification: " .. gravity .. " - expected " .. getGravity( ) )
			end
		else
			ban( client, "Fake " .. resourceName .. ":update event with param " .. tostring( gameSpeed ) .. "; " .. tostring( isNormalGameSpeed ) .. "; " .. tostring( gravity ) )
		end
	end
)
