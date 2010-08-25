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

local advertisement = { "www.", "mtasa.tk" }

--

addEventHandler( "onPlayerConnect", root,
	function( nick, ip, username, serial, version )
		for key, value in ipairs( advertisement ) do
			if nick == value or nick:find( value ) then
				cancelEvent( true, "'" .. nick .. "' is not allowed as nick. Go to Settings > Multiplayer to change it.")
				return
			end
		end
	end
)

addEventHandler( "onPlayerChangeNick", root,
	function( old, nick )
		for key, value in ipairs( advertisement ) do
			if nick == value or nick:find( value ) then
				cancelEvent( )
				return
			end
		end
	end
)
