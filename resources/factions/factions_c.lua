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

local localPlayer = getLocalPlayer( )

-- F3 to show the first faction's page
addCommandHandler( "showfaction",
	function( commandName, factionNum )
		if exports.players:isLoggedIn( ) then
			if not exports.gui:getShowing( ) then
				triggerServerEvent( "faction:show", localPlayer, tonumber( factionNum ) )
			elseif exports.gui:getShowing( ) == "faction" then
				exports.gui:hide( )
			end
		end
	end
)

bindKey( "F3", "down", "showfaction", "1" )

--

addEvent( "faction:show", true )
addEventHandler( "faction:show", localPlayer,
	function( ... )
		exports.gui:hide( )
		exports.gui:updateFaction( ... )
		exports.gui:show( "faction" )
	end
)
