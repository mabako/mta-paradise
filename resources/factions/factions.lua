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

local p = { }
local factions = { }
local factionTypes = { police = 1 }
local maxRanks = 12

--

local function loadFaction( factionID, name, type, tag, groupID )
	if not tag or #tag == 0 then
		tag = ""
		-- create a tag from the first letter of each word
		local i = 0
		repeat
			i = i + 1
			local token = gettok( name, i, string.byte( ' ' ) )
			
			if not token then
				break
			else
				tag = tag .. token:sub( 1, 1 )
			end
		until false
	end
	
	-- load all ranks
	local ranks = { }
	local result = exports.sql:query_assoc( "SELECT factionRankName FROM faction_ranks WHERE factionID = " .. factionID .. " ORDER BY factionRankID ASC" )
	if result then
		for key, value in ipairs( result ) do
			table.insert( ranks, value.factionRankName )
		end
	end
	factions[ factionID ] = { name = name, type = type, tag = tag, group = groupID, ranks = ranks }
end

local function loadPlayer( player )
	local characterID = exports.players:getCharacterID( player )
	if characterID then
		p[ player ] = { factions = { }, rfactions = { }, types = { } }
		local result = exports.sql:query_assoc( "SELECT factionID, factionLeader FROM character_to_factions WHERE characterID = " .. characterID )
		for key, value in ipairs( result ) do
			local factionID = value.factionID
			if factions[ factionID ] then
				table.insert( p[ player ].factions, factionID )
				p[ player ].rfactions[ factionID ] = { leader = value.factionLeader, id = factionID }
				p[ player ].types[ factions[ factionID ].type ] = true
			else
				outputDebugString( "Faction " .. factionID .. " does not exist, removing players from it." )
				-- exports.sql:query_assoc( "DELETE FROM characters_to_factions WHERE factionID = " .. factionID )
			end
		end
	end
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		if not exports.sql:create_table( 'factions',
			{
				{ name = 'factionID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'groupID', type = 'int(10) unsigned' }, -- see wcf1_group
				{ name = 'factionType', type = 'tinyint(3) unsigned' }, -- we do NOT have hardcoded factions or names of those.
				{ name = 'factionTag', type = 'varchar(10)' },
			} ) then cancelEvent( ) return end
		
		if not exports.sql:create_table( 'character_to_factions',
			{
				{ name = 'characterID', type = 'int(10) unsigned', primary_key = true },
				{ name = 'factionID', type = 'int(10) unsigned', primary_key = true },
				{ name = 'factionLeader', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'factionRank', type = 'tinyint(3) unsigned', default = 1 },
			}
		) then cancelEvent( ) return end
		
		if not exports.sql:create_table( 'faction_ranks',
			{
				{ name = 'factionID', type = 'int(10) unsigned', primary_key = true },
				{ name = 'factionRankID', type = 'int(10) unsigned', primary_key = true },
				{ name = 'factionRankName', type = 'varchar(64)' },
			}
		) then cancelEvent( ) return end
		
		--
		
		local result = exports.sql:query_assoc( "SELECT f.*, g.groupName FROM factions f LEFT JOIN wcf1_group g ON f.groupID = g.groupID" )
		for key, value in ipairs( result ) do
			if value.groupName then
				loadFaction( value.factionID, value.groupName, value.factionType, value.factionTag, value.groupID )
			else
				outputDebugString( "Faction " .. value.factionID .. " has no valid group. Ignoring..." )
			end
		end
		
		--
		
		for key, value in ipairs( getElementsByType( "player" ) ) do
			if exports.players:isLoggedIn( value ) then
				loadPlayer( value )
			end
		end
	end
)

addEventHandler( "onCharacterLogin", root,
	function( )
		loadPlayer( source )
	end
)

addEventHandler( "onCharacterLogout", root,
	function( )
		p[ source ] = nil
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)

--

function getFactionName( factionID )
	return factions[ factionID ] and factions[ factionID ].name
end

function getFactionTag( factionID )
	return factions[ factionID ] and factions[ factionID ].tag
end

--

function getPlayerFactions( player )
	return p[ player ] and p[ player ].factions or false
end

function sendMessageToFaction( factionID, message, ... )
	if factions[ factionID ] then
		for key, value in pairs( p ) do
			if value.rfactions[ factionID ] then
				outputChatBox( message, key, ... )
			end
		end
		return true
	end
	return false
end

function isPlayerInFactionType( player, type )
	return factionTypes[ type ] and p[ player ] and p[ player ].types and p[ player ].types[ factionTypes[ type ] ] or false
end

--

addEvent( "faction:show", true )
addEventHandler( "faction:show", root,
	function( fnum )
		if source == client then
			local faction = fnum and fnum < 0 and p[ source ].rfactions[ -fnum ] and p[ source ].rfactions[ -fnum ].id or p[ source ].factions[ fnum or 1 ]
			if faction then
				local result = exports.sql:query_assoc( "SELECT c.characterName, cf.factionLeader, cf.factionRank, DATEDIFF(NOW(),c.lastLogin) AS days FROM character_to_factions cf LEFT JOIN characters c ON c.characterID = cf.characterID WHERE cf.factionID = " .. faction .. " ORDER BY cf.factionRank DESC, c.characterName ASC" )
				if result then
					local members = { }
					for key, value in ipairs( result ) do
						table.insert( members, { value.characterName, value.factionLeader, value.factionRank, exports.players:isLoggedIn( getPlayerFromName( value.characterName:gsub( " ", "_" ) ) ) and -1 or value.days } )
					end
					
					triggerClientEvent( source, "faction:show", source, faction, members, factions[ faction ].name, factions[ faction ].ranks )
				end
			end
		end
	end
)

--

local function joinFaction( inviter, player, faction )
	if exports.players:isLoggedIn( player ) and p[ player ] then
		if not p[ player ].rfactions[ faction ] then
			-- let's add him into the faction
			if exports.sql:query_free( "INSERT INTO character_to_factions (characterID, factionID) VALUES (" .. exports.players:getCharacterID( player ) .. ", " .. faction .. ")" ) then
				-- if he is the first user of this char, set him to the usergroup
				local result = exports.sql:query_assoc_single( "SELECT COUNT(*) AS number FROM character_to_factions cf LEFT JOIN characters c ON c.characterID = cf.characterID WHERE cf.factionID = " .. faction .. " AND c.userID = " .. exports.players:getUserID( player ) )
				if result.number == 1 then
					if not exports.sql:query_free( "INSERT INTO wcf1_user_to_groups (userID, groupID) VALUES (" .. exports.players:getUserID( player ) .. ", " .. factions[ faction ].group .. ")" ) then
						-- revert the faction assignment back
						exports.sql:query_free( "DELETE FROM character_to_factions WHERE characterID = " .. exports.players:getCharacterID( player ) .. " AND factionID = " .. faction .. " LIMIT 1" )
						
						outputChatBox( "(( MySQL-Error. ))", inviter, 255, 0, 0 )
						
						return false
					end
				end
				
				-- successful
				table.insert( p[ player ].factions, faction )
				p[ player ].rfactions[ faction ] = { leader = 0, id = faction }
				p[ player ].types[ factions[ faction ].type ] = true
				return true
			end
		else
			outputChatBox( "(( " .. getPlayerName( player ):gsub( "_", " " ) .. " is already in that faction. ))", inviter, 255, 0, 0 )
		end
	end
	return false
end

addEvent( "faction:join", true )
addEventHandler( "faction:join", root,
	function( faction )
		-- check for faction leader
		if client and client ~= source and p[ client ] and p[ client ].rfactions[ faction ] and p[ client ].rfactions[ faction ].leader >= 1 then
			if joinFaction( client, source, faction ) then
				outputChatBox( "(( " .. getPlayerName( client ):gsub( "_", " " ) .. " set you to faction " .. factions[ faction ].name .. ". ))", source, 0, 255, 0 )
				outputChatBox( "(( You set " .. getPlayerName( source ):gsub( "_", " " ) .. " to faction " .. factions[ faction ].name .. ". ))", client, 0, 255, 0 )
			end
		end
	end
)

addCommandHandler( "setfaction",
	function( player, commandName, other, faction )
		local faction = tonumber( faction )
		if other and faction then
			if factions[ faction ] then
				local other, name = exports.players:getFromName( player, other )
				if other then
					if joinFaction( player, other, faction ) then
						outputChatBox( "(( " .. getPlayerName( player ):gsub( "_", " " ) .. " set you to faction " .. factions[ faction ].name .. ". ))", other, 0, 255, 153 )
						if player ~= other then
							outputChatBox( "(( You set " .. getPlayerName( other ):gsub( "_", " " ) .. " to faction " .. factions[ faction ].name .. ". ))", player, 0, 255, 153 )
						end
					end
				end
			else
				outputChatBox( "This faction does not exist.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player] [faction]", player, 255, 255, 255 )
		end
	end,
	true
)

--

addEvent( "faction:leave", true )
addEventHandler( "faction:leave", root,
	function( faction )
		if source == client then
			if factions[ faction ] and p[ source ].rfactions[ faction ] then
				if exports.sql:query_free( "DELETE FROM character_to_factions WHERE characterID = " .. exports.players:getCharacterID( source ) .. " AND factionID = " .. faction .. " LIMIT 1" ) then
					sendMessageToFaction( faction, "(( " .. getPlayerName( source ):gsub( "_", " " ) .. " left the faction " .. factions[ faction ].name .. ". ))", 255, 127, 0 )
					
					-- remove him from the tables
					p[ source ].types = { }
					for i = #p[ source ].factions, 1 do
						if p[ source ].factions[ i ] == faction then
							table.remove( p[ source ].factions, i )
						else
							p[ source ].types[ factions[ i ].type ] = true
						end
					end
					p[ source ].rfactions[ faction ] = nil
					
					-- count other chars of this player in the same faction
					local result = exports.sql:query_assoc_single( "SELECT COUNT(*) AS number FROM character_to_factions cf LEFT JOIN characters c ON c.characterID = cf.characterID WHERE cf.factionID = " .. faction .. " AND c.userID = " .. exports.players:getUserID( source ) )
					if result.number == 0 then
						-- delete from the usergroup
						exports.sql:query_free( "DELETE FROM wcf1_user_to_groups WHERE userID = " .. exports.players:getUserID( source ) .. " AND groupID = " .. factions[ faction ].group )
					end
				end
			end
		end
	end
)

--

local rightNames = { "Leader", "Owner" }

addEvent( "faction:demoterights", true )
addEventHandler( "faction:demoterights", root,
	function( faction, name, new )
		-- Sanity Check
		if source == client and p[ source ].rfactions[ faction ] and p[ source ].rfactions[ faction ].leader == 2 and type( name ) == "string" then
			local player = getPlayerFromName( name:gsub( " ", "_" ) )
			if player ~= source then -- You can't change your own rights.
				if player and p[ player ] and not p[ player ].rfactions[ faction ] then
					-- player exists, but is not a member of the faction
					return
				end
				
				if exports.sql:query_affected_rows( "UPDATE character_to_factions cf, characters c SET cf.factionLeader = cf.factionLeader - 1 WHERE c.characterID = cf.characterID AND c.characterName = '%s' AND cf.factionLeader >= 0", name ) == 1 then
					sendMessageToFaction( faction, "(( " .. factions[ faction ].tag .. " - " .. getPlayerName( source ):gsub( "_", " " ) .. " demoted " .. name .. " to " .. ( rightNames[ new ] or "Member" ) .. ". ))", 255, 127, 0 )
					if player then
						p[ player ].rfactions[ faction ].leader = p[ player ].rfactions[ faction ].leader - 1
					end
				else
					outputChatBox( "(( MySQL-Error. ))", source, 255, 0, 0 )
				end
			end
		end
	end
)

addEvent( "faction:promoterights", true )
addEventHandler( "faction:promoterights", root,
	function( faction, name, new )
		-- Sanity Check
		if source == client and p[ source ].rfactions[ faction ] and p[ source ].rfactions[ faction ].leader == 2 and type( name ) == "string" then
			local player = getPlayerFromName( name:gsub( " ", "_" ) )
			if player ~= source then -- You can't change your own rights.
				if player and p[ player ] and not p[ player ].rfactions[ faction ] then
					-- player exists, but is not a member of the faction
					return
				end
				
				if exports.sql:query_affected_rows( "UPDATE character_to_factions cf, characters c SET cf.factionLeader = cf.factionLeader + 1 WHERE c.characterID = cf.characterID AND c.characterName = '%s' AND cf.factionLeader < 2", name ) == 1 then
					sendMessageToFaction( faction, "(( " .. factions[ faction ].tag .. " - " .. getPlayerName( source ):gsub( "_", " " ) .. " promoted " .. name .. " to " .. ( rightNames[ new ] or "Member" ) .. ". ))", 255, 127, 0 )
					if player then
						p[ player ].rfactions[ faction ].leader = p[ player ].rfactions[ faction ].leader + 1
					end
				else
					outputChatBox( "(( MySQL-Error. ))", source, 255, 0, 0 )
				end
			end
		end
	end
)

addEvent( "faction:demote", true )
addEventHandler( "faction:demote", root,
	function( faction, name, new )
		-- Sanity Check
		if source == client and p[ source ].rfactions[ faction ] and p[ source ].rfactions[ faction ].leader >= 1 and type( name ) == "string" then
			local player = getPlayerFromName( name:gsub( " ", "_" ) )
			if player and p[ player ] and not p[ player ].rfactions[ faction ] then
				-- player exists, but is not a member of the faction
				return
			end
			
			if factions[ faction ].ranks[ new ] then
				if exports.sql:query_affected_rows( "UPDATE character_to_factions cf, characters c SET cf.factionRank = cf.factionRank - 1 WHERE c.characterID = cf.characterID AND c.characterName = '%s' AND cf.factionRank > 1", name ) == 1 then
					sendMessageToFaction( faction, "(( " .. factions[ faction ].tag .. " - " .. getPlayerName( source ):gsub( "_", " " ) .. " demoted " .. name .. " to " .. ( factions[ faction ].ranks[ new ] or "?" ) .. ". ))", 255, 127, 0 )
				else
					outputChatBox( "(( MySQL-Error. ))", source, 255, 0, 0 )
				end
			end
		end
	end
)

addEvent( "faction:promote", true )
addEventHandler( "faction:promote", root,
	function( faction, name, new )
		-- Sanity Check
		if source == client and p[ source ].rfactions[ faction ] and p[ source ].rfactions[ faction ].leader >= 1 and type( name ) == "string" then
			local player = getPlayerFromName( name:gsub( " ", "_" ) )
			if player and p[ player ] and not p[ player ].rfactions[ faction ] then
				-- player exists, but is not a member of the faction
				return
			end
			
			if factions[ faction ].ranks[ new ] then
				if exports.sql:query_affected_rows( "UPDATE character_to_factions cf, characters c SET cf.factionRank = cf.factionRank + 1 WHERE c.characterID = cf.characterID AND c.characterName = '%s' AND cf.factionRank < " .. #factions[ faction ].ranks, name ) == 1 then
					sendMessageToFaction( faction, "(( " .. factions[ faction ].tag .. " - " .. getPlayerName( source ):gsub( "_", " " ) .. " promoted " .. name .. " to " .. ( factions[ faction ].ranks[ new ] or "?" ) .. ". ))", 255, 127, 0 )
				else
					outputChatBox( "(( MySQL-Error. ))", source, 255, 0, 0 )
				end
			end
		end
	end
)

addEvent( "faction:kick", true )
addEventHandler( "faction:kick", root,
	function( faction, name )
		-- Sanity Check
		if source == client and p[ source ].rfactions[ faction ] and p[ source ].rfactions[ faction ].leader >= 1 and type( name ) == "string" then
			local player = getPlayerFromName( name:gsub( " ", "_" ) )
			if player ~= source then -- You can't change your own rights.
				if player and p[ player ] and not p[ player ].rfactions[ faction ] then
					-- player exists, but is not a member of the faction
					return
				elseif player and p[ source ].rfactions[ faction ].leader < p[ player ].rfactions[ faction ].leader then
					-- we don't have enough rights to kick the player
					return
				end
				
				if exports.sql:query_affected_rows( "DELETE cf FROM character_to_factions cf LEFT JOIN characters c ON c.characterID = cf.characterID WHERE cf.factionID = 1 AND c.characterName = '%s' AND cf.factionLeader < " .. p[ source ].rfactions[ faction ].leader, name ) == 1 then
					sendMessageToFaction( faction, "(( " .. factions[ faction ].tag .. " - " .. getPlayerName( source ):gsub( "_", " " ) .. " kicked " .. name .. ". ))", 255, 127, 0 )
					if player then
						-- remove him from the tables
						p[ player ].types = { }
						for i = #p[ player ].factions, 1 do
							if p[ player ].factions[ i ] == faction then
								table.remove( p[ player ].factions, i )
							else
								p[ player ].types[ factions[ i ].type ] = true
							end
						end
						p[ player ].rfactions[ faction ] = nil
					end
					
					-- count other chars of this player in the same faction
					local user = exports.sql:query_assoc_single( "SELECT userID FROM characters WHERE characterName = '%s'", name )
					if user then
						local result = exports.sql:query_assoc_single( "SELECT COUNT(*) AS number FROM character_to_factions cf LEFT JOIN characters c ON c.characterID = cf.characterID WHERE cf.factionID = " .. faction .. " AND c.userID = " .. user.userID )
						if result.number == 0 then
							-- delete from the usergroup
							exports.sql:query_free( "DELETE FROM wcf1_user_to_groups WHERE userID = " .. user.userID .. " AND groupID = " .. factions[ faction ].group )
						end
					end
				else
					outputChatBox( "(( MySQL-Error. ))", source, 255, 0, 0 )
				end
			end
		end
	end
)

addEvent( "faction:updateranks", true )
addEventHandler( "faction:updateranks", root,
	function( faction, ranks )
		-- Sanity Check
		if source == client and p[ source ].rfactions[ faction ] and p[ source ].rfactions[ faction ].leader == 2 and type( ranks ) == "table" and #ranks <= maxRanks then
			-- we enforce 1 rank minimum either way.
			if #ranks > 0 then
				-- check if all names are <= 64 chars (not that it makes remotely sense to have so long names) --- TODO: Check to what to reduce this. See table definition above and client's maxlength field for ranks.
				for i = 1, #ranks do
					if type( ranks[i] ) ~= "string" or #ranks[i] > 64 then
						return
					end
				end
				
				local endCount = #ranks
				if #factions[ faction ].ranks > #ranks then -- too much ranks
					-- delete all ranks that do not exist anymore, set user to the highest existing rank
					exports.sql:query_free( "DELETE FROM faction_ranks WHERE factionID = " .. faction .. " AND factionRankID > " .. #ranks )
					exports.sql:query_free( "UPDATE character_to_factions SET factionRankID = " .. #ranks .. " WHERE factionID = " .. faction .. " AND factionRank > " .. #ranks )
				elseif #factions[ faction ].ranks < #ranks then -- not enough ranks
					-- we only save those ranks we didn't add later
					endCount = #factions[ faction ].ranks
					
					-- fill our new ranks in
					for i = endCount + 1, #ranks do
						exports.sql:query_free( "INSERT INTO faction_ranks (factionID, factionRankID, factionRankName) VALUES (" .. faction .. ", " .. i .. ", '%s')", ranks[i] )
					end
				end
				
				-- update all existing ranks
				for i = 1, endCount do
					if factions[ faction ].ranks[i] ~= ranks[i] then
						exports.sql:query_free( "UPDATE faction_ranks SET factionRankName = '%s' WHERE factionID = " .. faction .. " AND factionRankID = " .. i, ranks[i] )
					end
				end
				
				-- save our ranks
				factions[ faction ].ranks = ranks
				
				-- message
				sendMessageToFaction( faction, "(( " .. factions[ faction ].tag .. " - " .. getPlayerName( source ):gsub( "_", " " ) .. " updated the ranks. ))", 255, 127, 0 )
			end
		end
	end
)

--

-- Tricky thing ahead: we rely on groups to be created before we turn them into factions
addCommandHandler( "createfaction",
	function( player, commandName, type, ... )
		if type and (...) then
			if factionTypes[ type ] then
				local name = table.concat( { ... }, " " )
				local group = exports.sql:query_assoc_single( "SELECT groupID FROM wcf1_group WHERE groupName = '%s'", name )
				if group then
					-- we need no duplicates
					for key, value in pairs( factions ) do
						if value.group == group.groupID then
							outputChatBox( "This group is already a faction.", player, 255, 0, 0 )
							return
						end
					end
					
					-- go ahead
					local faction = exports.sql:query_insertid( "INSERT INTO factions (groupID, factionType, factionTag) VALUES (" .. group.groupID .. ", " .. factionTypes[ type ] .. ", '')" )
					if faction then
						loadFaction( faction, name, factionTypes[ type ], nil, group.groupID )
						outputChatBox( "Created Faction " .. name .. " (" .. faction .. ").", player, 0, 255, 153 )
					else
						outputChatBox( "MySQL-Error.", player, 255, 0, 0 )
					end
				end
			else
				local list = { }
				for type in pairs( factionTypes ) do
					list[ #list + 1 ] = type
				end
				outputChatBox( "Faction type must be one of the following:", player, 255, 255, 255 )
				outputChatBox( "  " .. table.concat( list, ", " ), player, 255, 255, 255 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [type] [name]", player, 255, 255, 255 )
		end
	end,
	true
)
