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

-- addCommandHandler supporting arrays as command names (multiple commands with the same function)
local addCommandHandler_ = addCommandHandler
      addCommandHandler  = function( commandName, fn, restricted, caseSensitive )
	-- add the default command handlers
	if type( commandName ) ~= "table" then
		commandName = { commandName }
	end
	for key, value in ipairs( commandName ) do
		if key == 1 then
			addCommandHandler_( value, fn, restricted, caseSensitive )
		else
			addCommandHandler_( value,
				function( player, ... )
					-- check if he has permissions to execute the command, default is not restricted (aka if the command is restricted - will default to no permission; otherwise okay)
					if hasObjectPermissionTo( player, "command." .. commandName[ 1 ], not restricted ) then
						fn( player, ... )
					end
				end
			)
		end
	end
end

--

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
						outputChatBox( "Set " .. name .. "'s skin to " .. skin, player, 0, 255, 153 )
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

addCommandHandler( { "freeze", "unfreeze" },
	function( player, commandName, otherPlayer )
		if otherPlayer then
			local other, name = exports.players:getFromName( player, otherPlayer )
			if other then
				if player == other or not hasObjectPermissionTo( other, "command.freeze", false ) then
					local frozen = isPedFrozen( other )
					if frozen then
						outputChatBox( "You've unfrozen " .. name .. ".", player, 0, 255, 153 )
						if player ~= other then
							outputChatBox( "You have been unfrozen by " .. getPlayerName( player ) .. ".", other, 0, 255, 153 )
						end
					else
						outputChatBox( "You froze " .. name .. ".", player, 0, 255, 153 )
						if player ~= other then
							outputChatBox( "You have been frozen by " .. getPlayerName( player ) .. ".", other, 0, 255, 153 )
						end
					end
					toggleAllControls( other, frozen, true, false )
					setPedFrozen( other, not frozen )
					local vehicle = getPedOccupiedVehicle( other )
					if vehicle then
						setVehicleFrozen( vehicle, not frozen )
					end
				else
					outputChatBox( "You can't freeze this player.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( { "sethealth", "sethp" },
	function( player, commandName, otherPlayer, health )
		local health = tonumber( health )
		if otherPlayer and health and health >= 0 and health <= 100 then
			local other, name = exports.players:getFromName( player, otherPlayer )
			if other then
				local oldHealth = getElementHealth( other )
				if player == other or oldHealth < health or not hasObjectPermissionTo( other, "command.sethealth", false ) then
					if health < 1 then
						if killPed( other ) then
							outputChatBox( "You've killed " .. name .. ".", player, 0, 255, 153 )
						end
					elseif setElementHealth( other, health ) then
						outputChatBox( "You've set " .. name .. "'s health to " .. health .. ".", player, 0, 255, 153 )
					end
				else
					outputChatBox( "You can't change this player's health to a smaller value.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player] [health]", player, 255, 255, 255 )
		end
	end,
	true
)

addEventHandler( "onPlayerQuit", root,
	function( type, reason, player )
		if player and getElementType( player ) == "player" then
			if type == "Kicked" then
				outputChatBox( getPlayerName( player ):gsub( "_", " " ) .. " kicked " .. getPlayerName( source ) .. "." .. ( reason and #reason > 0 and ( " Reason: " .. reason ) or "" ), root, 255, 0, 0 )
			end
		end
	end
)

addCommandHandler( "kick",
	function( player, commandName, otherPlayer, ... )
		if otherPlayer then
			local other, name = exports.players:getFromName( player, otherPlayer, true )
			if other then
				if not hasObjectPermissionTo( other, "command.kick", false ) then
					local reason = table.concat( { ... }, " " )
					kickPlayer( other, player, #reason > 0 and reason )
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

--

local function contains( t, s )
	for key, value in pairs( t ) do
		if value.displayName == s then
			return true
		end
	end
	return false
end

addCommandHandler( "admins",
	function( player, commandName, ... )
		if exports.players:isLoggedIn( player ) then
			outputChatBox( "Admins: ", player, 255, 255, 91 )
			local count = 0
			for key, value in ipairs( getElementsByType( "player" ) ) do
				local groups = exports.players:getGroups( value )
				if groups and #groups >= 1 then
					if contains( groups, "Administrator" ) then
						outputChatBox( "  Admin " .. getPlayerName( value ):gsub( "_", " " ), player, 255, 255, 91 )
						count = count + 1
					end
				end
			end
			
			if count == 0 then
				outputChatBox( "  None.", player, 255, 255, 91 )
			end
		end
	end
)
addCommandHandler( "mods",
	function( player, commandName, ... )
		if exports.players:isLoggedIn( player ) then
			outputChatBox( "Moderators: ", player, 255, 255, 191 )
			local count = 0
			for key, value in ipairs( getElementsByType( "player" ) ) do
				local groups = exports.players:getGroups( value )
				if groups and #groups >= 1 then
					if contains( groups, "Moderator" ) then
						outputChatBox( "  Moderator " .. getPlayerName( value ):gsub( "_", " " ), player, 255, 255, 191 )
						count = count + 1
					end
				end
			end
			
			if count == 0 then
				outputChatBox( "  None.", player, 255, 255, 191 )
			end
		end
	end
)
