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

-- Events
addEvent( "onCharacterLogin", false )
addEvent( "onCharacterLogout", false )

-- Import Groups
local groups = {
	{ groupName = "MTA Moderators", groupID = false, aclGroup = "Moderator", displayName = "Moderator", nametagColor = { 255, 255, 191, priority = 5 } },
	{ groupName = "MTA Administrators", groupID = false, aclGroup = "Admin", displayName = "Administrator", nametagColor = { 255, 255, 91, priority = 10 }, defaultForFirstUser = true },
	{ groupName = "Developers", groupID = false, aclGroup = "Developer", displayName = "Developer", nametagColor = { 191, 255, 191, priority = 20 } },
}

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		-- create all mysql tables
		if not exports.sql:create_table( 'characters',
			{
				{ name = 'characterID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'characterName', type = 'varchar(22)' },
				{ name = 'userID', type = 'int(10) unsigned' },
				{ name = 'x', type = 'float' },
				{ name = 'y', type = 'float' },
				{ name = 'z', type = 'float' },
				{ name = 'interior', type = 'int(10) unsigned' },
				{ name = 'dimension', type = 'int(10) unsigned' },
				{ name = 'skin', type = 'int(10) unsigned' },
				{ name = 'rotation', type = 'float' },
				{ name = 'health', type = 'tinyint(3) unsigned', default = 100 },
				{ name = 'armor', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'money', type = 'bigint(20) unsigned', default = 100 },
				{ name = 'created', type = 'timestamp', default = 'CURRENT_TIMESTAMP' },
				{ name = 'lastLogin', type = 'timestamp', default = '0000-00-00 00:00:00' },
			} ) then cancelEvent( ) return end
		
		if not exports.sql:create_table( 'wcf1_user',
			{
				{ name = 'userID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'username', type = 'varchar(255)' },
				{ name = 'password', type = 'varchar(40)' },
				{ name = 'salt',  type = 'varchar(40)' },
				{ name = 'banned',  type = 'tinyint(1) unsigned', default = 0 },
				{ name = 'activationCode',  type = 'int(10) unsigned', default = 0 },
			} ) then cancelEvent( ) return end
		
		local success, didCreateTable = exports.sql:create_table( 'wcf1_group',
			{
				{ name = 'groupID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'groupName', type = 'varchar(255)', default = '' },
			} )
		if not success then cancelEvent( ) return end
		if didCreateTable then
			-- add default groups
			for key, value in ipairs( groups ) do
				value.groupID = exports.sql:query_insertid( "INSERT INTO wcf1_group (groupName) VALUES ('%s')", value.groupName )
			end
		else
			-- import all groups
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
		
		local success, didCreateTable = exports.sql:create_table( 'wcf1_user_to_groups',
			{
				{ name = 'userID', type = 'int(10) unsigned', default = 0, primary_key = true },
				{ name = 'groupID', type = 'int(10) unsigned', default = 0, primary_key = true },
			} )
		if not success then cancelEvent( ) return end
		if didCreateTable then
			for key, value in ipairs( groups ) do
				if value.defaultForFirstUser then
					exports.sql:query_free( "INSERT INTO wcf1_user_to_groups (userID, groupID) VALUES (1, " .. value.groupID .. ")" )
				end
			end
		end
		
		-- verify all accounts and remove invalid ones; new (valid) accounts will not be added until the player logs in
		local saveAcl = false
		local accounts = getAccounts( )
		for key, account in ipairs( accounts ) do
			local accountName = getAccountName( account )
			if accountName ~= "Console" then -- console may exist untouched
				local user = exports.sql:query_assoc_single( "SELECT userID FROM wcf1_user WHERE username = '%s'", accountName )
				if user then
					-- account should be deleted if no group is found
					local shouldBeDeleted = true
					
					if user.userID then -- if this doesn't exist, the user does not exist in the db
						-- fetch all of his groups
						local groupinfo = exports.sql:query_assoc( "SELECT groupID FROM wcf1_user_to_groups WHERE userID = " .. user.userID )
						if groupinfo then
							-- look through all of our pre-defined groups
							for key, group in ipairs( groups ) do
								-- user does not have this group
								local hasGroup = false
								
								-- check if he does have it
								for key2, group2 in ipairs( groupinfo ) do
									if group.groupID == group2.groupID then
										-- has the group
										hasGroup = true
										
										-- shouldn't delete his account
										shouldBeDeleted = false
										
										-- make sure acl rights are set correctly
										if aclGroupAddObject( aclGetGroup( group.aclGroup ), "user." .. accountName ) then
											outputDebugString( "Cleanup: Added account " .. accountName .. " to ACL " .. group.aclGroup, 3 )
											saveAcl = true
										end
									end
								end
								
								-- doesn't have it
								if not hasGroup then
									-- make sure acl rights are removed
									if aclGroupRemoveObject( aclGetGroup( group.aclGroup ), "user." .. accountName ) then
										outputDebugString( "Cleanup: Removed account " .. accountName .. " from ACL " .. group.aclGroup, 3 )
										saveAcl = true
									end
								end
							end
						end
					end
					
					-- has no relevant group, thus we don't need the MTA account
					if shouldBeDeleted then
						outputDebugString( "Cleanup: Removed account " .. accountName, 3 )
						removeAccount( account )
					end
				end
			end
		end
		
		-- if we should save the acl, do it (permissions changed)
		if saveAcl then
			aclSave( )
		end
	end
)
--

local function showLoginScreen( player, screenX, screenY, token )
	-- we need at least 800x600 for proper display of all GUI
	if screenX and screenY then
		if screenX < 800 or screenY < 600 then
			kickPlayer( player, "Use 800x600 or a larger resolution." )
			return
		end
	end
	
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
	
	setPlayerNametagColor( source, 127, 127, 127 )
	
	triggerClientEvent( player, getResourceName( resource ) .. ":spawnscreen", player )
	if token and #token > 0 then
		performLogin( source, token )
	end
end

addEvent( getResourceName( resource ) .. ":ready", true )
addEventHandler( getResourceName( resource ) .. ":ready", root,
	function( ... )
		if source == client then
			showLoginScreen( source, ... )
		end
	end
)

--

local p = { }

local function getPlayerHash( player )
	local ip = getPlayerIP( player ) or "255.255.255.0"
	return ip:sub(ip:find("%d+%.%d+%.")) .. ( getPlayerSerial( player ) or "R0FLR0FLR0FLR0FLR0FLR0FLR0FLR0FL" )
end

addEvent( getResourceName( resource ) .. ":login", true )
addEventHandler( getResourceName( resource ) .. ":login", root,
	function( username, password )
		if source == client then
			if username and password and #username > 0 and #password > 0 then
				local info = exports.sql:query_assoc_single( "SELECT CONCAT(SHA1(CONCAT(username, '%s')),SHA1(CONCAT(salt, SHA1(CONCAT('%s',SHA1(CONCAT(salt, SHA1(CONCAT(username, SHA1(password)))))))))) AS token FROM wcf1_user WHERE `username` = '%s' AND password = SHA1(CONCAT(salt, SHA1(CONCAT(salt, " .. ( sha1 and ( "'" .. sha1(password) .. "'" ) or "SHA1('%s')" ) .. "))))", getPlayerHash( source ), getPlayerHash( source ), username, not sha1 and password )
				p[ source ] = nil
				if not info then
					triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 1 ) -- Wrong username/password
				else
					performLogin( source, info.token, true )
				end
			end
		end
	end
)

function performLogin( source, token, isPasswordAuth )
	if source then
		if token then
			if #token == 80 then
				local info = exports.sql:query_assoc_single( "SELECT userID, username, banned, activationCode, SUBSTRING(LOWER(SHA1(CONCAT(userName,SHA1(CONCAT(password,salt))))),1,30) AS salts FROM wcf1_user WHERE CONCAT(SHA1(CONCAT(username, '%s')),SHA1(CONCAT(salt, SHA1(CONCAT('%s',SHA1(CONCAT(salt, SHA1(CONCAT(username, SHA1(password)))))))))) = '%s' LIMIT 1", getPlayerHash( source ), getPlayerHash( source ), token )
				p[ source ] = nil
				if not info then
					if isPasswordAuth then
						triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 1 ) -- Wrong username/password
					else
						return false
					end
				else
					if info.banned == 1 then
						triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 2 ) -- Banned
						return false
					elseif info.activationCode > 0 then
						triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 3 ) -- Requires activation
						return false
					else
						-- check if another user is logged in on that account
						for player, data in pairs( p ) do
							if data.userID == info.userID then
								triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 5 ) -- another player with that account found
								return false
							end
						end
						local username = info.username
						p[ source ] = { userID = info.userID, username = username, groups = { } }
						
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
											account = addAccount( username, info.salts ) -- due to MTA's limitations, the password can't be longer than 30 chars
											if not account then
												outputDebugString( "Account Error for " .. username .. " - addAccount failed.", 1 )
											else
												outputDebugString( "Added account " .. username, 3 )
											end
										end
										
										if account then
											-- if the player has a different account password, change it
											if not getAccount( username, info.salts ) then
												setAccountPassword( account, info.salts )
											end
											
											if isGuestAccount( getPlayerAccount( source ) ) and not logIn( source, account, info.salts) then
												-- something went wrong here
												outputDebugString( "Account Error for " .. username .. " - login failed.", 1 )
											else
												-- show him a message
												table.insert( p[ source ].groups, group2 )
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
						local chars = exports.sql:query_assoc( "SELECT characterID, characterName, skin FROM characters WHERE userID = " .. info.userID .. " ORDER BY lastLogin DESC" )
						if isPasswordAuth then
							triggerClientEvent( source, getResourceName( resource ) .. ":characters", source, chars, true, token )
						else
							triggerClientEvent( source, getResourceName( resource ) .. ":characters", source, chars, true )
						end
						return true
					end
				end
			end
		end
	end
	return false
end

local function savePlayer( player )
	if not player then
		for key, value in ipairs( getElementsByType( "player" ) ) do
			savePlayer( value )
		end
	else
		if isLoggedIn( player ) then
			-- save character since it's logged in
			local x, y, z = getElementPosition( player )
			exports.sql:query_free( "UPDATE characters SET x = " .. x .. ", y = " .. y .. ", z = " .. z .. ", dimension = " .. getElementDimension( player ) .. ", interior = " .. getElementInterior( player ) .. ", rotation = " .. getPedRotation( player ) .. ", health = " .. math.floor( getElementHealth( player ) ) .. ", armor = " .. math.floor( getPedArmor( player ) ) .. ", lastLogin = NOW() WHERE characterID = " .. tonumber( getCharacterID( player ) ) )
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
			if p[ source ].charID then
				triggerEvent( "onCharacterLogout", source )
			end
			p[ source ] = nil
			showLoginScreen( source )
			
			if not isGuestAccount( getPlayerAccount( source ) ) then
				logOut( source )
			end
		end
	end
)

addEventHandler( "onPlayerJoin", root,
	function( )
		setPlayerNametagColor( source, 127, 127, 127 )
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		if p[ source ] then
			savePlayer( source )
			if p[ source ].charID then
				triggerEvent( "onCharacterLogout", source )
			end
			p[ source ] = nil
		end
	end
)

addEvent( getResourceName( resource ) .. ":spawn", true )
addEventHandler( getResourceName( resource ) .. ":spawn", root, 
	function( charID )
		if source == client and ( not isPedDead( source ) or not isLoggedIn( source ) ) then
			local userID = p[ source ] and p[ source ].userID
			if tonumber( userID ) and tonumber( charID ) then
				-- if the player is logged in, save him
				savePlayer( source )
				if p[ source ].charID then
					triggerEvent( "onCharacterLogout", source )
					p[ source ].charID = nil
					p[ source ].money = nil
				end
				
				--
				local char = exports.sql:query_assoc_single( "SELECT * FROM characters WHERE userID = " .. tonumber( userID ) .. " AND characterID = " .. tonumber( charID ) )
				if char then
					local mtaCharName = char.characterName:gsub( " ", "_" )
					local otherPlayer = getPlayerFromName( mtaCharName )
					if otherPlayer and otherPlayer ~= source then
						kickPlayer( otherPlayer )
					end
					setPlayerName( source, mtaCharName )
					setPlayerNametagText( source, "[" .. getID( source ) .. "] " .. char.characterName )
					local nametagColor = { 255, 255, 255, priority = 0 }
					for key, value in ipairs( p[ source ].groups ) do
						if value.nametagColor then
							if value.nametagColor.priority > nametagColor.priority then
								nametagColor = value.nametagColor
							end
						end
					end
					setPlayerNametagColor( source, unpack( nametagColor ) )
					
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
					
					p[ source ].money = char.money
					setPlayerMoney( source, char.money )
					
					p[ source ].charID = tonumber( charID )
					
					triggerClientEvent( source, getResourceName( resource ) .. ":onSpawn", source )
					triggerEvent( "onCharacterLogin", source )
					
					showCursor( source, false )
					
					-- set last login to now
					exports.sql:query_free( "UPDATE characters SET lastLogin = NOW() WHERE characterID = " .. tonumber( charID ) )
				end
			end
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

-- money functions
function setMoney( player, amount )
	amount = tonumber( amount )
	if amount >= 0 and isLoggedIn( player ) then
		if exports.sql:query_free( "UPDATE characters SET money = " .. amount .. " WHERE characterID = " .. p[ player ].charID ) then
			p[ player ].money = amount
			setPlayerMoney( player, amount )
			return true
		end
	end
	return false
end

function giveMoney( player, amount )
	return isLoggedIn( player ) and setMoney( player, p[ player ].money + amount )
end

function takeMoney( player, amount )
	return isLoggedIn( player ) and setMoney( player, p[ player ].money - amount )
end

function getMoney( player, amount )
	return isLoggedIn( player ) and p[ player ].money
end

--

function updateCharacters( player )
	if player and p[ player ].userID then
		local chars = exports.sql:query_assoc( "SELECT characterID, characterName, skin FROM characters WHERE userID = " .. p[ player ].userID .. " ORDER BY lastLogin DESC" )
		triggerClientEvent( player, getResourceName( resource ) .. ":characters", player, chars, false )
		return true
	end
	return false
end

function createCharacter( player, name )
	if player and p[ player ].userID then
		if exports.sql:query_assoc_single( "SELECT characterID FROM characters WHERE characterName = '%s'", name ) then
			triggerClientEvent( player, "players:characterCreationResult", player, 1 )
		elseif exports.sql:query_free( "INSERT INTO characters (characterName, userID, x, y, z, interior, dimension, skin, rotation) VALUES ('%s', " .. p[ player ].userID .. ", -1984.5, 138, 27.7, 0, 0, 0, 90)", name ) then
			updateCharacters( player )
			triggerClientEvent( player, "players:characterCreationResult", player, 0 )
		end
	end
end
