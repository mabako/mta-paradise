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

local function loadFaction( factionID, name, type, tag, groupID )
	if not tag or #tag == 0 then
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
	
	factions[ factionID ] = { name = name, type = type, tag = tag, group = groupID }
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
				p[ player ].rfactions[ factionID ] = { leader = value.factionLeader }
				p[ player ].types[ factions[ factionID ].type ] = true
				outputDebugString( "Set " .. getPlayerName( player ):gsub( "_", " " ) .. " to " .. factions[ factionID ].name )
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
			{ name = 'characterID', type = 'int(10) unsigned', default = 0, primary_key = true },
			{ name = 'factionID', type = 'int(10) unsigned', default = 0, primary_key = true },
			{ name = 'factionLeader', type = 'tinyint(3) unsigned', default = 0 },
			{ name = 'factionRank', type = 'tinyint(3) unsigned', default = 1 },
			} ) then cancelEvent( ) return end
		
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
	return p[ player ] and p[ player ].types and p[ player ].types[ type ] or false
end

--

addEvent( "faction:show", true )
addEventHandler( "faction:show", root,
	function( fnum )
		if source == client then
			local faction = p[ source ].factions[ fnum or 1 ]
			if faction then
				local result = exports.sql:query_assoc( "SELECT c.characterName, cf.factionLeader, cf.factionRank, DATEDIFF(NOW(),c.lastLogin) AS days FROM character_to_factions cf LEFT JOIN characters c ON c.characterID = cf.characterID WHERE cf.factionID = " .. faction .. " ORDER BY cf.factionRank DESC, c.characterName ASC" )
				if result then
					local members = { }
					for key, value in ipairs( result ) do
						table.insert( members, { value.characterName, value.factionLeader, value.factionRank, exports.players:isLoggedIn( getPlayerFromName( value.characterName:gsub( " ", "_" ) ) ) and -1 or value.days } )
					end
					
					triggerClientEvent( source, "faction:show", source, faction, members, factions[ faction ].name )
				end
			end
		end
	end
)

--

addEvent( "faction:leave", true )
addEventHandler( "faction:leave", root,
	function( faction )
		if source == client then
			if factions[ faction ] and p[ source ].factions[ faction ] then
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
