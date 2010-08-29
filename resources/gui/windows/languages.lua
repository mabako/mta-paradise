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

windows.languages = {
	{
		type = "label",
		text = "Character Languages",
		font = "bankgothic",
		alignX = "center",
	},
	{
		type = "pane",
		panes = { }
	}
}

local function getSkillLevel( skill )
	if skill < 100 then
		return "awful"
	elseif skill < 200 then
		return "horrible"
	elseif skill < 400 then
		return "okay"
	elseif skill < 600 then
		return "good"
	elseif skill < 750 then
		return "decent"
	elseif skill < 950 then
		return "great"
	else
		return "perfect"
	end
end

local getWindowTable = function( ) return end
function updateLanguages( languages )
	local set = false
	if getWindowTable( ) == windows.languages then
		set = true
	end
	
	windows.languages[2] = { type = "pane", panes = { } }
	
	-- helper function
	local function add( flag, skill, current )
		local title = exports.players:getLanguageName( flag )
		table.insert( windows.languages[2].panes,
			{
				image = ":players/images/flags/" .. flag .. ".png",
				title = " " .. title,
				text = "Your Level of " .. title .. " is " .. getSkillLevel( skill ) .. ", you are able to understand the language to " .. math.floor( skill / 10 ) .. "%." .. ( current and "" or " To write in " .. title .. ", prefix your text with #" .. flag ),
				onHover = function( cursor, pos )
						if not current then
							dxDrawRectangle( pos[1], pos[2], pos[3] - pos[1], pos[4] - pos[2], tocolor( 255, 255, 0, 63 ) )
						end
					end,
				onClick = function( key )
						if key == 1 then
							triggerServerEvent( "players:selectLanguage", getLocalPlayer( ), flag )
						end
					end,
				onRender = function( pos )
						if current then
							dxDrawRectangle( pos[1], pos[2], pos[3] - pos[1], pos[4] - pos[2], tocolor( 0, 255, 0, 63 ) )
						end
					end,
				wordBreak = true
			}
		)
	end
	
	for key, value in pairs( languages ) do
		add( key, value.skill, value.current )
	end
	
	if set then
		setWindowTable( windows.languages )
	end
end
