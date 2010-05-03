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

-- we don't want our shops to die, do we?
addEventHandler( "onClientPedDamage", resourceRoot, cancelEvent )

addEvent( "shops:open", true )
addEventHandler( "shops:open", resourceRoot,
	function( configuration )
		local c = shop_configurations[ configuration ]
		local items = { }
		for key, value in ipairs( c ) do
			table.insert( items, value )
		end
		
		exports.gui:updateShopContent( items )
		exports.gui:show( 'shop' )
	end
)

addEventHandler( "onClientResourceStop", resourceRoot,
	function( )
		if exports.gui:getShowing( ) == "shop" then
			exports.gui:hide( )
		end
	end
)
