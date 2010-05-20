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

--

local team = createTeam( "MTA: Paradise" ) -- this is used as a dummy team. We need this for faction chat to work.
local p = { }

-- Import Groups
local groups = {
	{ groupName = "MTA Moderators", groupID = false, aclGroup = "Moderator", displayName = "Moderator", nametagColor = { 255, 255, 191 }, priority = 5 },
	{ groupName = "MTA Administrators", groupID = false, aclGroup = "Admin", displayName = "Administrator", nametagColor = { 255, 255, 91 }, priority = 10, defaultForFirstUser = true },
	{ groupName = "Developers", groupID = false, aclGroup = "Developer", displayName = "Developer", nametagColor = { 191, 255, 191 }, priority = 20, defaultForFirstUser = true },
}

local function updateNametagColor( player )
	local nametagColor = { 255, 255, 255, priority = 0 }
	if p[ player ] then
		for key, value in ipairs( groups ) do
			if isObjectInACLGroup( "user." .. p[ player ].username, aclGetGroup( value.aclGroup ) ) and value.nametagColor then
				if value.priority > nametagColor.priority then
					nametagColor = value.nametagColor
					nametagColor.priority = value.priority
				end
			end
		end
	end
	setPlayerNametagColor( player, unpack( nametagColor ) )
end

function getGroups( player )
	local g = { }
	if p[ player ] then
		for key, value in ipairs( groups ) do
			if isObjectInACLGroup( "user." .. p[ player ].username, aclGetGroup( value.aclGroup ) ) then
				table.insert( g, value )
			end
		end
		table.sort( g, function( a, b ) return a.priority > b.priority end )
	end
	return g
end

local function aclUpdate( player, saveAclIfChanged )
	local saveAcl = false
	
	if player then
		local info = p[ player ]
		if info and info.username then
			local shouldHaveAccount = false
			local account = getAccount( info.username )
			local groupinfo = exports.sql:query_assoc( "SELECT groupID FROM wcf1_user_to_groups WHERE userID = " .. info.userID )
			if groupinfo then
				-- loop through all retrieved groups
				for key, group in ipairs( groupinfo ) do
					for key2, group2 in ipairs( groups ) do
						-- we have a acl group of interest
						if group.groupID == group2.groupID then
							-- mark as person to have an account
							shouldHaveAccount = true
							
							-- add an account if it doesn't exist
							if not account then
								outputServerLog( tostring( info.username ) .. " " .. tostring( info.mtasalt ) )
								account = addAccount( info.username, info.mtasalt ) -- due to MTA's limitations, the password can't be longer than 30 chars
								if not account then
									outputDebugString( "Account Error for " .. info.username .. " - addAccount failed.", 1 )
								else
									outputDebugString( "Added account " .. info.username, 3 )
								end
							end
							
							if account then
								-- if the player has a different account password, change it
								if not getAccount( info.username, info.mtasalt ) then
									setAccountPassword( account, info.mtasalt )
								end
								
								if isGuestAccount( getPlayerAccount( player ) ) and not logIn( player, account, info.mtasalt ) then
									-- something went wrong here
									outputDebugString( "Account Error for " .. info.username .. " - login failed.", 1 )
								else
									-- show him a message
									outputChatBox( "You are now logged in as " .. group2.displayName .. ".", player, 0, 255, 0 )
									if aclGroupAddObject( aclGetGroup( group2.aclGroup ), "user." .. info.username ) then
										saveAcl = true
										outputDebugString( "Added account " .. info.username .. " to " .. group2.aclGroup .. " ACL", 3 )
									end
								end
							end
						end
					end
				end
			end
			if not shouldHaveAccount and account then
				-- remove account from all ACL groups we use
				for key, value in ipairs( groups ) do
					if aclGroupRemoveObject( aclGetGroup( value.aclGroup ), "user." .. info.username ) then
						saveAcl = true
						outputDebugString( "Removed account " .. info.username .. " from " .. value.aclGroup .. " ACL", 3 )
						outputChatBox( "You are no longer logged in as " .. group.displayName .. ".", player, 255, 0, 0 )
					end
				end
				
				-- remove the account
				removeAccount( account )
				outputDebugString( "Removed account " .. info.username, 3 )
			end
			
			if saveAcl then
				updateNametagColor( player )
			end
		end
	else
		-- verify all accounts and remove invalid ones
		local checkedPlayers = { }
		local accounts = getAccounts( )
		for key, account in ipairs( accounts ) do
			local accountName = getAccountName( account )
			local player = getAccountPlayer( account )
			if player then
				checkedPlayers[ player ] = true
			end
			if accountName ~= "Console" then -- console may exist untouched
				local user = exports.sql:query_assoc_single( "SELECT userID FROM wcf1_user WHERE username = '%s'", accountName )
				if user then
					-- account should be deleted if no group is found
					local shouldBeDeleted = true
					local userChanged = false
					
					if user.userID then -- if this doesn't exist, the user does not exist in the db
						-- fetch all of his groups groups
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
											outputDebugString( "Added account " .. accountName .. " to ACL " .. group.aclGroup, 3 )
											saveAcl = true
											userChanged = true
											if player then
												outputChatBox( "You are now logged in as " .. group.displayName .. ".", player, 0, 255, 0 )
											end
										end
									end
								end
								
								-- doesn't have it
								if not hasGroup then
									-- make sure acl rights are removed
									if aclGroupRemoveObject( aclGetGroup( group.aclGroup ), "user." .. accountName ) then
										outputDebugString( "Removed account " .. accountName .. " from ACL " .. group.aclGroup, 3 )
										saveAcl = true
										userChanged = true
										
										if player then
											outputChatBox( "You are no longer logged in as " .. group.displayName .. ".", player, 255, 0, 0 )
										end
									end
								end
							end
						end
					end
					
					-- has no relevant group, thus we don't need the MTA account
					if shouldBeDeleted then
						if player then
							logOut( player )
						end
						outputDebugString( "Removed account " .. accountName, 3 )
						removeAccount( account )
					elseif player and isGuestAccount( getPlayerAccount( player ) ) and not logIn( player, account, p[ player ].mtasalt ) then
						-- something went wrong here
						outputDebugString( "Account Error for " .. p[ player ].username .. " - login failed.", 1 )
					end
					
					-- update the color since we have none
					if player and ( shouldBeDeleted or userChanged ) then
						updateNametagColor( player )
					end
				else
					-- Invalid user
					
					-- remove account from all ACL groups we use
					for key, value in ipairs( groups ) do
						if aclGroupRemoveObject( aclGetGroup( value.aclGroup ), "user." .. p[ player ].username ) then
							saveAcl = true
							outputDebugString( "Removed account " .. p[ player ].username .. " from " .. value.aclGroup .. " ACL", 3 )
							
							if player then
								outputChatBox( "You are no longer logged in as " .. group.displayName .. ".", player, 255, 0, 0 )
							end
						end
					end
					
					-- remove the account
					if player then
						logOut( player )
					end
					removeAccount( account )
					outputDebugString( "Removed account " .. p[ player ].username, 3 )
				end
			end
		end
		
		-- check all players not found by this for whetever they now have an account
		for key, value in ipairs( getElementsByType( "player" ) ) do
			if not checkedPlayers[ value ] then
				local success, needsAclUpdate = aclUpdate( value, false )
				if needsAclUpdate then
					saveAcl = true
				end
			end
		end
	end
	-- if we should save the acl, do it (permissions changed)
	if saveAclIfChanged and saveAcl then
		aclSave( )
	end
	return true, saveAcl
end

addCommandHandler( "reloadpermissions",
	function( player )
		if aclUpdate( nil, true ) then
			outputServerLog( "Permissions have been reloaded. (Requested by " .. ( not player and "Console" or getAccountName( getPlayerAccount( player ) ) or getPlayerName(player) ) .. ")" )
			if player then
				outputChatBox( "Permissions have been reloaded.", player, 0, 255, 0 )
			end
		else
			outputServerLog( "Permissions reload failed. (Requested by " .. ( not player and "Console" or getAccountName( getPlayerAccount( player ) ) or getPlayerName(player) ) .. ")" )
			if player then
				outputChatBox( "Permissions reload failed.", player, 255, 0, 0 )
			end
		end
	end,
	true
)

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
				{ name = 'interior', type = 'tinyint(3) unsigned' },
				{ name = 'dimension', type = 'int(10) unsigned' },
				{ name = 'skin', type = 'int(10) unsigned' },
				{ name = 'rotation', type = 'float' },
				{ name = 'health', type = 'tinyint(3) unsigned', default = 100 },
				{ name = 'armor', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'money', type = 'bigint(20) unsigned', default = 100 },
				{ name = 'created', type = 'timestamp', default = 'CURRENT_TIMESTAMP' },
				{ name = 'lastLogin', type = 'timestamp', default = '0000-00-00 00:00:00' },
				{ name = 'weapons', type = 'varchar(255)', default = 100 },
			} ) then cancelEvent( ) return end
		
		if not exports.sql:create_table( 'wcf1_user',
			{
				{ name = 'userID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'username', type = 'varchar(255)' },
				{ name = 'password', type = 'varchar(40)' },
				{ name = 'salt', type = 'varchar(40)' },
				{ name = 'banned', type = 'tinyint(1) unsigned', default = 0 },
				{ name = 'activationCode', type = 'int(10) unsigned', default = 0 },
				{ name = 'banReason', type = 'mediumtext', null = true },
				{ name = 'banUser', type = 'int(10) unsigned', null = true },
				{ name = 'lastIP', type = 'varchar(15)', null = true },
				{ name = 'lastSerial', type = 'varchar(32)', null = true },
			} ) then cancelEvent( ) return end
		
		local success, didCreateTable = exports.sql:create_table( 'wcf1_group',
			{
				{ name = 'groupID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'groupName', type = 'varchar(255)', default = '' },
				{ name = 'canBeFactioned', type = 'tinyint(1) unsigned', default = 1 }, -- if this is set to 0, you can't make a faction from this group.
			} )
		if not success then cancelEvent( ) return end
		if didCreateTable then
			-- add default groups
			for key, value in ipairs( groups ) do
				value.groupID = exports.sql:query_insertid( "INSERT INTO wcf1_group (groupName, canBeFactioned) VALUES ('%s', 0)", value.groupName )
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
		
		aclUpdate( nil, true )
	end
)
--

local function showLoginScreen( player, screenX, screenY, token, ip )
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
	
	-- check for ip/serial bans
	if exports.sql:query_assoc_single( "SELECT * FROM wcf1_user WHERE banned = 1 AND ( lastIP = '%s' OR lastSerial = '%s' )", getPlayerIP( player ), getPlayerSerial( player ) ) then
		showChat( player, false )
		setTimer( triggerClientEvent, 300, 1, player, getResourceName( resource ) .. ":loginResult", player, 2 ) -- Banned
		return false
	end
	
	triggerClientEvent( player, getResourceName( resource ) .. ":spawnscreen", player )
	if token and #token > 0 then
		performLogin( source, token, false, ip )
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

local loginAttempts = { }
local triedTokenAuth = { }

local function getPlayerHash( player, remoteIP )
	local ip = getPlayerIP( player ) or "255.255.255.0"
	if ip == "127.0.0.1" and remoteIP then -- we don't really care about a provided ip unless we want to connect from localhost
		ip = exports.sql:escape_string( remoteIP )
	end
	return ip:sub(ip:find("%d+%.%d+%.")) .. ( getPlayerSerial( player ) or "R0FLR0FLR0FLR0FLR0FLR0FLR0FLR0FL" )
end

addEvent( getResourceName( resource ) .. ":login", true )
addEventHandler( getResourceName( resource ) .. ":login", root,
	function( username, password )
		if source == client then
			triedTokenAuth[ source ] = true
			if username and password and #username > 0 and #password > 0 then
				local info = exports.sql:query_assoc_single( "SELECT CONCAT(SHA1(CONCAT(username, '%s')),SHA1(CONCAT(salt, SHA1(CONCAT('%s',SHA1(CONCAT(salt, SHA1(CONCAT(username, SHA1(password)))))))))) AS token FROM wcf1_user WHERE `username` = '%s' AND password = SHA1(CONCAT(salt, SHA1(CONCAT(salt, '" .. sha1(password) .. "'))))", getPlayerHash( source ), getPlayerHash( source ), username )
				p[ source ] = nil
				if not info then
					triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 1 ) -- Wrong username/password
					loginAttempts[ source ] = ( loginAttempts[ source ] or 0 ) + 1
					if loginAttempts[ source ] >= 5 then
						-- ban for 15 minutes
						local serial = getPlayerSerial( source )
						
						banPlayer( source, true, false, false, root, "Too many login attempts.", 900 )
						if serial then
							addBan( nil, nil, serial, root, "Too many login attempts.", 900 )
						end
					end
				else
					loginAttempts[ source ] = nil
					performLogin( source, info.token, true )
				end
			end
		end
	end
)

function performLogin( source, token, isPasswordAuth, ip )
	if source and ( isPasswordAuth or not triedTokenAuth[ source ] ) then
		triedTokenAuth[ source ] = true
		if token then
			if #token == 80 then
				local info = exports.sql:query_assoc_single( "SELECT userID, username, banned, activationCode, SUBSTRING(LOWER(SHA1(CONCAT(userName,SHA1(CONCAT(password,salt))))),1,30) AS salts FROM wcf1_user WHERE CONCAT(SHA1(CONCAT(username, '%s')),SHA1(CONCAT(salt, SHA1(CONCAT('%s',SHA1(CONCAT(salt, SHA1(CONCAT(username, SHA1(password)))))))))) = '%s' LIMIT 1", getPlayerHash( source, ip ), getPlayerHash( source, ip ), token )
				p[ source ] = nil
				if not info then
					if isPasswordAuth then
						triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 1 ) -- Wrong username/password
					end
					return false
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
						p[ source ] = { userID = info.userID, username = username, mtasalt = info.salts }
						
						-- check for admin rights
						aclUpdate( source, true )
						
						-- show characters
						local chars = exports.sql:query_assoc( "SELECT characterID, characterName, skin FROM characters WHERE userID = " .. info.userID .. " ORDER BY lastLogin DESC" )
						if isPasswordAuth then
							triggerClientEvent( source, getResourceName( resource ) .. ":characters", source, chars, true, token, getPlayerIP( source ) ~= "127.0.0.1" and getPlayerIP( source ) )
						else
							triggerClientEvent( source, getResourceName( resource ) .. ":characters", source, chars, true )
						end
						
						outputServerLog( "PARADISE LOGIN: " .. getPlayerName( source ) .. " logged in as " .. info.username .. " (IP: " .. getPlayerIP( source ) .. ", Serial: " .. getPlayerSerial( source ) .. ")" )
						exports.server:message( "%C04[" .. getID( source ) .. "]%C %B" .. info.username .. "%B logged in (Nick: %B" .. getPlayerName( source ):gsub( "_", " " ) .. "%B)." )
						exports.sql:query_free( "UPDATE wcf1_user SET lastIP = '%s', lastSerial = '%s' WHERE userID = " .. tonumber( info.userID ), getPlayerIP( source ), getPlayerSerial( source ) )
						
						return true
					end
				end
			end
		end
	end
	return false
end

local function getWeaponString( player )
	local weapons = { }
	local hasAnyWeapons = false
	for slot = 0, 12 do
		local weapon = getPedWeapon( player, slot )
		if weapon > 0 then
			local ammo = getPedTotalAmmo( player, slot )
			if ammo > 0 then
				weapons[weapon] = ammo
				hasAnyWeapons = true
			end
		end
	end
	if hasAnyWeapons then
		return "'" .. exports.sql:escape_string( toJSON( weapons ):gsub( " ", "" ) ) .. "'"
	else
		return "NULL"
	end
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
			exports.sql:query_free( "UPDATE characters SET x = " .. x .. ", y = " .. y .. ", z = " .. z .. ", dimension = " .. getElementDimension( player ) .. ", interior = " .. getElementInterior( player ) .. ", rotation = " .. getPedRotation( player ) .. ", health = " .. math.floor( getElementHealth( player ) ) .. ", armor = " .. math.floor( getPedArmor( player ) ) .. ", weapons = " .. getWeaponString( player ) .. ", lastLogin = NOW() WHERE characterID = " .. tonumber( getCharacterID( player ) ) )
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
				setPlayerTeam( source, nil )
				takeAllWeapons( source )
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
			loginAttempts[ source ] = nil
			triedTokenAuth[ source ] = nil
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
					setPlayerTeam( source, nil )
					takeAllWeapons( source )
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
					p[ source ].characterName = char.characterName
					updateNametag( source )
					
					-- restore weapons
					if char.weapons then
						local weapons = fromJSON( char.weapons )
						if weapons then
							for weapon, ammo in pairs( weapons ) do
								giveWeapon( source, weapon, ammo )
							end
						end
					end
					
					setPlayerTeam( source, team )
					triggerClientEvent( source, getResourceName( resource ) .. ":onSpawn", source )
					triggerEvent( "onCharacterLogin", source )
					
					showCursor( source, false )
					
					-- set last login to now
					exports.sql:query_free( "UPDATE characters SET lastLogin = NOW() WHERE characterID = " .. tonumber( charID ) )
					
					outputServerLog( "PARADISE CHARACTER: " .. p[ source ].username .. " is now playing as " .. char.characterName )
					exports.server:message( "%C04[" .. getID( source ) .. "]%C %B" .. p[ source ].username .. "%B is now playing in as %B" .. char.characterName .. "%B." )
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
	return player and p[ player ] and p[ player ].charID or false
end

function isLoggedIn( player )
	return getCharacterID( player ) and true or false
end

function getUserID( player )
	return player and p[ player ] and p[ player ].userID or false
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
	return false
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
	return setMoney( player, p[ player ].money + amount )
end

function takeMoney( player, amount )
	return setMoney( player, p[ player ].money - amount )
end

function getMoney( player, amount )
	return isLoggedIn( player ) and p[ player ].money or 0
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

function createCharacter( player, name, skin )
	if player and p[ player ].userID then
		if exports.sql:query_assoc_single( "SELECT characterID FROM characters WHERE characterName = '%s'", name ) then
			triggerClientEvent( player, "players:characterCreationResult", player, 1 )
		elseif exports.sql:query_free( "INSERT INTO characters (characterName, userID, x, y, z, interior, dimension, skin, rotation) VALUES ('%s', " .. p[ player ].userID .. ", 1688.6, 1448.5, 10.76, 0, 0, " .. tonumber( skin ) .. ", 270)", name ) then
			updateCharacters( player )
			triggerClientEvent( player, "players:characterCreationResult", player, 0 )
			
			exports.server:message( "%C04[" .. getID( player ) .. "]%C %B" .. p[ player ].username .. "%B created character %B" .. name .. "%B." )
			
			return true
		end
	end
	return false
end

--

function updateNametag( player )
	if player then
		local text = "[" .. getID( player ) .. "] "
		local vehicle = getPedOccupiedVehicle( player )
		if vehicle and exports.vehicles:hasTintedWindows( vehicle ) then
			text = text .. "? (Tinted Windows)"
		else
			text = text .. ( p[ player ].characterName or getPlayerName( player ):gsub( "_", " " ) )
		end
		
		setPlayerNametagText( player, tostring( text ) )
		updateNametagColor( player )
		return true
	end
	return false
end
