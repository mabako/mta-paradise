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

windows.inventory =
{
	{
		type = "label",
		text = "Inventory",
		font = "bankgothic",
		alignX = "center",
	},
	{
		type = "vpane",
		lines = 7,
		panes = { }
	},
	{
		type = "button",
		text = "Close",
		onClick = function( ) hide( ) showCursor( false ) end,
	}
}

function updateInventory( )
	windows.inventory[2].panes = { }
	local t = exports.items:get( getLocalPlayer( ) )
	if t then
		for k, v in ipairs( t ) do
			local image = exports.items:getImage( v.item, v.value, v.name )
			table.insert( windows.inventory[2].panes,
				{
					image = image or ":players/images/skins/-1.png",
					onHover = function( cursor, pos )
							dxDrawRectangle( pos[1], pos[2], pos[3] - pos[1], pos[4] - pos[2], tocolor( unpack( { 255, 255, 0, 63 } ) ) )
						end,
					onClick = function( key )
							if key == 1 then
								triggerServerEvent( "items:use", getLocalPlayer( ), k )
							end
						end
				}
			)
		end
	end
end
setTimer( updateInventory, 500, 1 )
