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

-- Import Groups
local groups = {
	{ groupName = "MTA Administrators", groupID = false, aclGroup = "Admin", displayName = "Administrator" }
}

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local data = exports.sql:query_assoc( "SELECT groupID, groupName FROM wcf1_group" )
		if data then
			for key, value in ipairs( data ) do
				for key2, value2 in ipairs( groups ) do
					if value.groupName == value2.groupName then
						value2.groupID = value.groupID
					end
				end
			end
		end
	end
)
--

local function showLoginScreen( player )
	-- remove the player from his vehicle if any
	if isPedInVehicle( player ) then
		removePedFromVehicle( player )
	end
	
	-- hide the current view (will be faded in client-side)
	fadeCamera( player, false, 0 )
	toggleAllControls( player, false, true, false )
	
	-- spawn the player etc.
	spawnPlayer( source, 2000.6, 1577.6, 16.5, 10, 0, 0, 1 )
	setPedFrozen( source, true )
	setElementAlpha( source, 0 )
	
	setCameraInterior( source, 0 )
	
	setCameraMatrix( source, 1999.8, 1580.95, 17.6, 2000, 1580, 17.5 )
	
	triggerClientEvent( player, getResourceName( resource ) .. ":spawnscreen", player )
end

addEvent( getResourceName( resource ) .. ":ready", true )
addEventHandler( getResourceName( resource ) .. ":ready", root,
	function( )
		if source == client then
			showLoginScreen( source )
		end
	end
)

--

local p = { }

addEvent( getResourceName( resource ) .. ":login", true )
addEventHandler( getResourceName( resource ) .. ":login", root,
	function( username, password )
		if source == client then
			if username and password and #username > 0 and #password > 0 then
				local info = exports.sql:query_assoc_single( "SELECT userID, banned, activationCode, SUBSTRING(LOWER(SHA1(CONCAT(userName,SHA1(CONCAT(password,salt))))),1,30) AS salt FROM wcf1_user WHERE `username` = '%s' AND password = SHA1(CONCAT(salt, SHA1(CONCAT(salt, SHA1('%s'))))) LIMIT 1", username, password )
				
				p[ source ] = nil
				if not info then
					triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 1 ) -- Wrong username/password
				else
					if info.banned == 1 then
						triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 2 ) -- Banned
					elseif info.activationCode > 0 then
						triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 3 ) -- Requires activation
					else
						-- check if another user is logged in on that account
						for player, data in pairs( p ) do
							if data.userID == info.userID then
								triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 5 ) -- another player with that account found
								return
							end
						end
						p[ source ] = { userID = info.userID, username = username }
						
						-- check for admin rights
						local shouldHaveAccount = false
						local account = getAccount( username )
						local groupinfo = exports.sql:query_assoc( "SELECT groupID FROM wcf1_user_to_groups WHERE userID = " .. info.userID )
						if groupinfo then
							local saveAcl = false
							
							-- loop through all retrieved groups
							for key, group in ipairs( groupinfo ) do
								for key2, group2 in ipairs( groups ) do
									-- we have a acl group of interest
									if group.groupID == group2.groupID then
										-- mark as person to have an account
										shouldHaveAccount = true
										
										-- add an account if it doesn't exist
										if not account then
											account = addAccount( username, info.salt ) -- due to MTA's limitations, the password can't be longer than 30 chars
											if not account then
												outputDebugString( "Account Error for " .. username .. " - addAccount failed.", 1 )
											else
												outputDebugString( "Added account " .. username, 3 )
											end
										end
										
										if account then
											-- if the player has a different account password, change it
											if not getAccount( username, info.salt ) then
												setAccountPassword( account, info.salt )
												getAccount( username, info.salt )
											end
											
											if not logIn( source, account, info.salt ) then
												-- something went wrong here
												outputDebugString( "Account Error for " .. username .. " - login failed.", 1 )
											else
												-- show him a message
												outputChatBox( "You are now logged in as " .. group2.displayName .. ".", source, 0, 255, 0 )
												if aclGroupAddObject( aclGetGroup( group2.aclGroup ), "user." .. username ) then
													saveAcl = true
													outputDebugString( "Added account " .. username .. " to " .. group2.aclGroup .. " ACL", 3 )
												end
											end
										end
									end
								end
							end
							
							-- save the acl if it was changed
							if saveAcl then
								aclSave( )
							end
						end
						if not shouldHaveAccount and account then
							-- remove account from all ACL groups we use
							local saveAcl = false
							for key, value in ipairs( groups ) do
								if aclGroupRemoveObject( aclGetGroup( value.aclGroup ), "user." .. username ) then
									saveAcl = true
									outputDebugString( "Removed account " .. username .. " from " .. value.aclGroup .. " ACL", 3 )
								end
							end
							
							-- save the acl if it was changed
							if saveAcl then
								aclSave( )
							end
							
							-- remove the account
							removeAccount( account )
							outputDebugString( "Removed account " .. username, 3 )
						end
						
						-- show characters
						local chars = exports.sql:query_assoc( "SELECT characterID, characterName, skin FROM characters WHERE userID = " .. info.userID )
						triggerClientEvent( source, getResourceName( resource ) .. ":characters", source, chars, true )
					end
				end
			end
		end
	end
)

local function savePlayer( player )
	if not player then
		for key, value in ipairs( getElementsByType( "player" ) ) do
			savePlayer( value )
		end
	else
		if isLoggedIn( source ) then
			-- save character since it's logged in
			local x, y, z = getElementPosition( source )
			exports.sql:query_free( "UPDATE characters SET x = " .. x .. ", y = " .. y .. ", z = " .. z .. ", dimension = " .. getElementDimension( source ) .. ", interior = " .. getElementInterior( source ) .. ", rotation = " .. getPedRotation( source ) .. ", health = " .. math.ceil( getElementHealth( source ) ) .. ", armor = " .. math.ceil( getPedArmor( source ) ) .. " WHERE characterID = " .. tonumber( p[ source ].charID ) )
		end
	end
end
setTimer( savePlayer, 300000, 0 ) -- Auto-Save every five minutes

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		savePlayer( )
		
		-- logout all players
		for key, value in ipairs( getElementsByType( "player" ) ) do
			if not isGuestAccount( getPlayerAccount( value ) ) then
				logOut( value )
			end
		end
	end
)

addEvent( getResourceName( resource ) .. ":logout", true )
addEventHandler( getResourceName( resource ) .. ":logout", root,
	function( )
		if source == client then
			savePlayer( source )
			p[ source ] = nil
			showLoginScreen( source )
			
			if not isGuestAccount( getPlayerAccount( source ) ) then
				logOut( source )
			end
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		savePlayer( source )
		p[ source ] = nil
	end
)

addEvent( getResourceName( resource ) .. ":spawn", true )
addEventHandler( getResourceName( resource ) .. ":spawn", root, 
	function( charID )
		if source == client then
			local userID = p[ source ] and p[ source ].userID
			if tonumber( userID ) and tonumber( charID ) then
				-- if the player is logged in, save him
				savePlayer( source )
				p[ source ].charID = nil
				
				--
				local char = exports.sql:query_assoc_single( "SELECT characterName, x, y, z, dimension, interior, skin, rotation, health, armor FROM characters WHERE userID = " .. tonumber( userID ) .. " AND characterID = " .. tonumber( charID ) )
				if char then
					local mtaCharName = char.characterName:gsub( " ", "_" )
					local otherPlayer = getPlayerFromName( mtaCharName )
					if otherPlayer and otherPlayer ~= source then
						kickPlayer( otherPlayer )
					end
					p[ source ].charID = nil
					setPlayerName( source, mtaCharName )
					setPlayerNametagText( source, "[" .. getID( source ) .. "] " .. char.characterName )
					
					-- spawn the player, as it's a valid char
					spawnPlayer( source, char.x, char.y, char.z, char.rotation, char.skin, char.interior, char.dimension )
					fadeCamera( source, true )
					setCameraTarget( source, source )
					setCameraInterior( source, char.interior )
					
					toggleAllControls( source, true, true, false )
					setPedFrozen( source, false )
					setElementAlpha( source, 255 )
					
					setElementHealth( source, char.health )
					setPedArmor( source, char.armor )
					
					p[ source ].charID = tonumber( charID )
					
					triggerClientEvent( source, getResourceName( resource ) .. ":onSpawn", source )
				end
			end
		end
	end
)

addEventHandler( "onPlayerWasted", root,
	function( )
		if isLoggedIn( source ) then
			local x, y, z = getElementPosition( source )
			spawnPlayer( source, x, y, z, getPedRotation( source ), getElementModel( source ), getElementInterior( source ), getElementDimension( source ) )
			fadeCamera( source, true )
			setCameraTarget( source, source )
			setCameraInterior( source, getElementInterior( source ) )
		end
	end
)

addEventHandler( "onPlayerChangeNick", root,
	function( )
		if isLoggedIn( source ) then
			cancelEvent( )
		end
	end
)

-- exports
function getCharacterID( player )
	return player and p[ player ] and p[ player ].charID
end

function isLoggedIn( player )
	return getCharacterID( player ) and true
end

-- retrieves a character name from the database id
function getCharacterName( characterID )
	if type( characterID ) == "number" then
		-- check if the player is online, if so we don't need to query
		for player, data in pairs( p ) do
			if data.charID == characterID then
				local name = getPlayerName( player ):gsub( "_", " " )
				return name
			end
		end
		
		local data = exports.sql:query_assoc_single( "SELECT characterName FROM characters WHERE characterID = " .. characterID )
		if data then
			return data.characterName
		end
	end
end