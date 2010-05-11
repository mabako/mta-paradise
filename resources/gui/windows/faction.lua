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

--

local function leave( faction )
	triggerServerEvent( "faction:leave", localPlayer, faction )
	hide( )
	windows.faction[2].content = { }
end

--

windows.faction =
{
	widthScale = 1.4,
	{
		type = "label",
		text = "",
		font = "bankgothic",
		alignX = "center",
	},
	{
		type = "grid",
		columns =
		{
			{ name = "Name", width = 0.35 },
			{ name = "Rights", width = 0.1, alignX = "center" },
			{ name = "Rank", width = 0.4, alignX = "center" },
			{ name = "Activity", width = 0.15, alignX = "center" }
		},
		content = { }
	},
	{
		type = "button",
		text = "Leave",
		onClick = nil,
	},
}

function updateFaction( fnum, members, name )
	windows.faction[1].text = name
	
	local grid = { }
	
	for key, value in ipairs( members ) do
		t =
		{
			value[1],
			value[2] == 2 and "Owner" or value[2] == 1 and "Leader" or "",
			value[3],
			value[4] == -1 and "Online" or value[4] == 0 and "Today" or value[4] == 1 and "Yesterday" or value[4] and ( value[4] .. " days ago" ) or "Never",
		}
		
		if value[4] == -1 then
			t.color = { 191, 255, 191 }
		end
		
		table.insert( grid, t )
	end
	
	windows.faction[2].content = grid
	windows.faction[3].onClick = function( key ) if key == 1 then leave( fnum ) end end
end
