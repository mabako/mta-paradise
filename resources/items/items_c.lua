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

local items = { }

-- syncing items from the server
addEvent( "syncItems", true )
addEventHandler( "syncItems", root,
	function( item_table )
		items[ source ] = item_table
	end
)

-- load our stuff when we indicate we're ready, as the resource can be restarted inbetween
addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "loadItems", getLocalPlayer( ) )
	end
)

function get( element )
	return items[ element ]
end

function has( element, item, value, name )
	-- we need a base to work on
	if items[ element ] then
		-- at least the item is needed
		if type( item ) == 'number' then
			-- check if he has it
			for key, v in ipairs( items[ element ] ) do
				if v.item == item and ( not value or v.value == value ) and ( not name or v.name == name ) then
					return true, key, v
				end
			end
			return false -- nope, no error either
		end
		return false, "Invalid Parameters"
	end
	return false, "Element not loaded"
end
