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

addCommandHandler( "setskin",
	function( player, commandName, otherPlayer, skin )
		skin = tonumber( skin )
		if otherPlayer and skin then
			local other, name = exports.players:getFromName( player, otherPlayer )
			if other then
				local oldSkin = getElementModel( other )
				local characterID = exports.players:getCharacterID( other )
				if oldSkin == skin then
					outputChatBox( name .. " is already using that skin.", player, 255, 255, 0 )
				elseif characterID and setElementModel( other, skin ) then
					if exports.sql:query_free( "UPDATE characters SET skin = " .. skin .. " WHERE characterID = " .. characterID ) then
						outputChatBox( "Set " .. name .. "'s skin to " .. skin, player, 0, 255, 0 )
						exports.players:updateCharacters( other )
					else
						outputChatBox( "Failed to save skin.", player, 255, 0, 0 )
						setElementModel( other, oldSkin )
					end
				else
					outputChatBox( "Skin " .. skin .. " is invalid.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player] [skin]", player, 255, 255, 255 )
		end
	end,
	true
)
