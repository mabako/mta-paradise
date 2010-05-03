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

addCommandHandler( "get",
	function( player, commandName, otherPlayer )
		if otherPlayer then
			local other, name = exports.players:getFromName( player, otherPlayer )
			if other then
				-- todo: vehicle teleports
				removePedFromVehicle( other )
				
				local x, y, z = getElementPosition( player )
				setElementPosition( other, x + 1, y, z )
				setElementInterior( other, getElementInterior( player ) )
				setElementDimension( other, getElementDimension( player ) )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "goto",
	function( player, commandName, otherPlayer )
		if otherPlayer then
			local other, name = exports.players:getFromName( player, otherPlayer )
			if other then
				-- todo: vehicle teleports
				removePedFromVehicle( player )
				
				local x, y, z = getElementPosition( other )
				setElementPosition( player, x + 1, y, z )
				setElementInterior( player, getElementInterior( other ) )
				setElementDimension( player, getElementDimension( other ) )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "kick",
	function( player, commandName, otherPlayer, ... )
		if otherPlayer and ( ... ) then
			local other, name = exports.players:getFromName( player, otherPlayer )
			if other then
				if not hasObjectPermissionTo( other, "command.kick" ) then
					local reason = table.concat( { ... }, " " )
					kickPlayer( other, player, reason )
				else
					outputChatBox( "You can't kick this player.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player] [reason]", player, 255, 255, 255 )
		end
	end,
	true
)
