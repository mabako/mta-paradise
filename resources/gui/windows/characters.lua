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

windows.characters = { }

function updateCharacters( characters )
	local set = false
	if getWindowTable( ) == windows.characters then
		set = true
	end
	
	windows.characters = { type = "pane", panes = { } }
	
	-- helper function
	local function add( title, text, skin, characterID )
		table.insert( windows.characters.panes,
			{
				image = ":players/images/skins/" .. skin .. ".png",
				title = title,
				text = text,
				onHover = function( cursor, pos )
						color = { 0, 255, 0, 31 }
						if characterID == -1 then
							color[1] = 255
						elseif characterID == -2 then
							color[1] = 255
							color[2] = 0
						end
						dxDrawRectangle( pos[1], pos[2], pos[3] - pos[1], pos[4] - pos[2], tocolor( unpack( color ) ) )
					end,
				onClick = function( key )
						if key == 1 then
							exports.players:selectCharacter( characterID, title )
						end
					end,
				wordBreak = true
			}
		)
	end
	
	for key, value in ipairs( characters ) do
		add( value.characterName, nil, value.skin, value.characterID )
	end
	
	-- add new char & logout
	add( "New Character", "Select this option to create a new character.", -1, -1 )
	add( "Logout", "Logs you out.\nYou will be prompted to login again before you can continue playing.", -2, -2 )
	
	if set then
		setWindowTable( windows.characters )
	end
end

