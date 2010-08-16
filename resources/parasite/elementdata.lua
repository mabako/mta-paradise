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

addEventHandler( "onElementDataChange", root,
	function( name, old )
		-- we don't allow any client to change element data
		if client then
			-- ban the player
			ban( client, "Trying to change element data (Element: " .. tostring( source ) .. ", name = " .. tostring( name ) .. ", value = " .. tostring( getElementData( source, name ) ) .. ", old = " .. tostring( old ) .. ")" )
			
			-- restore the old data
			if isElement( source ) then
				if old == nil then
					removeElementData( source, name )
				else
					setElementData( source, name, old )
				end
			end
		end
	end
)
