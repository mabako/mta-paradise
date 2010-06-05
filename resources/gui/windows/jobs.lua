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

local closeButton =
{
	type = "button",
	text = "Close",
	onClick = function( key )
			if key == 1 then
				hide( )
				
				windows.jobs = { widthScale = 0.5, closeButton }
			end
		end,
}

windows.jobs = { closeButton }

function updateJobs( content )
	-- scrap what we had before
	windows.jobs = {
		widthScale = 0.5,
		onClose = function( )
				triggerServerEvent( "jobs:close", getLocalPlayer( ) )
				windows.jobs = { widthScale = 0.5, closeButton }
			end,
		{
			type = "label",
			text = "Jobs",
			font = "bankgothic",
			alignX = "center",
		},
		{
			type = "pane",
			panes = { }
		}
	}
	
	-- let's add all items
	for k, value in ipairs( content ) do
		local description = value.description or exports.items:getDescription( value.itemID )
		table.insert( windows.jobs[2].panes,
			{
				image = exports.items:getImage( value.itemID, value.itemValue, value.name ) or ":players/images/skins/-1.png",
				title = value,
				onHover = function( cursor, pos )
						dxDrawRectangle( pos[1], pos[2], pos[3] - pos[1], pos[4] - pos[2], tocolor( unpack( { 0, 255, 0, 31 } ) ) )
					end,
				onClick = function( key )
						if key == 1 then
							triggerServerEvent( "jobs:select", getLocalPlayer( ), value:lower( ) )
							
							
							setTimer( hide, 50, 1 )
							windows.jobs = { widthScale = 0.5, closeButton }
						end
					end,
			}
		)
	end
	
	-- add a close button as well
	table.insert( windows.jobs, closeButton )
end
