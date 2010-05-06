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

local maps = { }

--

local function addMap( name, id, dimension, protected )
	name = name:lower( )
	if not maps[ name ] then
		maps[ name ] = { id = id, objects = { }, dimension = dimension or 0, protected = protected or false }
		return true
	else
		return false
	end
end

local function addMapObject( mapName, objectID, object, interior, alpha )
	mapName = mapName:lower( )
	local map = maps[ mapName ]
	if map then
		-- create the actual object
		if isElement( object ) then
			setElementInterior( object, interior )
			setElementDimension( object, map.dimension )
			setElementAlpha( object, alpha )
			
			-- save a reference
			map.objects[ object ] = { id = objectID }
			
			return true
		else
			return false
		end
	else
		return false
	end
end

local function addMapObjectFromPosition( mapName, id, model, x, y, z, rx, ry, rz, ... )
	return addMapObject( mapName, id, createObject( model, x, y, z, rx, ry, rz ), ... )
end

local function removeMap( name )
	name = name:lower( )
	local map = maps[ name ]
	if map and not map.protected then
		-- delete all objects
		exports.sql:query_free( "DELETE FROM map_objects WHERE mapID = " .. map.id )
		for object in pairs( map.objects ) do
			destroyElement( object )
		end
		
		-- delete the map
		exports.sql:query_free( "DELETE FROM maps WHERE mapID = " .. map.id )
		
		maps[ name ] = nil
		return true
	else
		return false
	end
end

--

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		-- create all mysql tables
		if not exports.sql:create_table( 'maps',
			{
				{ name = 'mapID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'mapName', type = 'varchar(255)' },
				{ name = 'mapDimension', type = 'int(10) unsigned', default = 0 },
				{ name = 'protected', type = 'tinyint(3) unsigned', default = 0 }, -- if this is set to 1, this map can't be changed unless modified over the database
			} ) then cancelEvent( ) return end
		
		if not exports.sql:create_table( 'map_objects',
			{
				{ name = 'objectID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'mapID', type = 'int(10) unsigned' },
				{ name = 'model', type = 'int(10) unsigned' },
				{ name = 'x', type = 'float' },
				{ name = 'y', type = 'float' },
				{ name = 'z', type = 'float' },
				{ name = 'rx', type = 'float' },
				{ name = 'ry', type = 'float' },
				{ name = 'rz', type = 'float' },
				{ name = 'interior', type = 'tinyint(3) unsigned' },
				{ name = 'alpha', type = 'tinyint(3) unsigned', default = 255 },
			} ) then cancelEvent( ) return end
		
		-- load all maps
		local mapCounter = 0
		local objectCounter = 0
		local emptyMaps = { }
		local result = exports.sql:query_assoc( "SELECT * FROM maps ORDER BY mapID ASC" )
		if result then
			for key, data in ipairs( result ) do
				if addMap( data.mapName, data.mapID, data.mapDimension, data.protected == 1 ) then
					local mapObjects = 0
					mapCounter = mapCounter + 1
					
					-- load all objects within that map
					local result2 = exports.sql:query_assoc( "SELECT * FROM map_objects WHERE mapID = " .. data.mapID .. " ORDER BY objectID ASC" )
					if result2 then
						for k, o in ipairs( result2 ) do
							if addMapObjectFromPosition( data.mapName, o.objectID, o.model, o.x, o.y, o.z, o.rx, o.ry, o.rz, o.interior, o.alpha ) then
								objectCounter = objectCounter + 1
								mapObjects = mapObjects + 1
							end
						end
					end
					
					-- no maps in this map
					if mapObjects == 0 then
						outputDebugString( "Map " .. data.mapName .. " (ID " .. data.mapID .. ") has no objects.", 2 )
					end
				end
			end
		end
		
		outputDebugString( "Loaded " .. mapCounter .. " maps with " .. objectCounter .. " objects." )
	end
)

-- load map from file

addCommandHandler( "addmap",
	function( player, commandName, ... )
		local mapName = table.concat( { ... }, " " )
		if #mapName > 0 then
			local map = xmlLoadFile( "maps/" .. mapName .. ".map" )
			if map then
				mapName = mapName:lower( )
				if not maps[ mapName ] then
					local objects = { }
					local children = xmlNodeGetChildren( map )
					for key, value in ipairs( children ) do
						if xmlNodeGetName( value ) == "object" then
							table.insert( objects,
								{
									x = tonumber( xmlNodeGetAttribute( value, "posX" ) ),
									y = tonumber( xmlNodeGetAttribute( value, "posY" ) ),
									z = tonumber( xmlNodeGetAttribute( value, "posZ" ) ),
									rx = tonumber( xmlNodeGetAttribute( value, "rotX" ) ) or 0,
									ry = tonumber( xmlNodeGetAttribute( value, "rotY" ) ) or 0,
									rz = tonumber( xmlNodeGetAttribute( value, "rotZ" ) ) or 0,
									model = tonumber( xmlNodeGetAttribute( value, "model" ) ),
									interior = tonumber( xmlNodeGetAttribute( value, "interior" ) ) or 0,
									alpha = tonumber( xmlNodeGetAttribute( value, "alpha" ) ) or 255
								}
							)
						else
							outputDebugString( "loading map: " .. mapName .. " has an unsupported element: " .. xmlNodeGetName( value ), 2 )
						end
					end
					xmlUnloadFile( map )
					
					if #objects > 0 then
						local mapID = exports.sql:query_insertid( "INSERT INTO maps (mapName) VALUES ('%s')", mapName )
						if mapID then
							if addMap( mapName, mapID ) then
								local loaded = 0
								
								for key, value in ipairs( objects ) do
									if value.x and value.y and value.z and value.alpha >= 0 and value.alpha <= 255 and value.interior >= 0 and value.interior <= 255 then
										local object = createObject( value.model, value.x, value.y, value.z, value.rx, value.ry, value.rz )
										if object then
											-- insert into db
											local objectID = exports.sql:query_insertid( "INSERT INTO map_objects (mapID, model, x, y, z, rx, ry, rz, interior, alpha) VALUES(" .. table.concat( { mapID, value.model, value.x, value.y, value.z, value.rx, value.ry, value.rz, value.interior, value.alpha }, ", " ) .. ")" )
											if objectID then
												addMapObject( mapName, objectID, object, value.interior, value.alpha )
												loaded = loaded + 1
											end
										end
									end
								end
								
								if loaded > 0 then
									outputChatBox( "Added map '" .. mapName .. "' with " .. ( loaded == #objects and loaded or ( loaded .. "/" .. #objects ) ) .. " objects.", player, 0, 255, 153 )
								else
									removeMap( mapName )
									outputChatBox( "Ignoring map '" .. mapName .. "' - unable to load any objects.", player, 255, 0, 0 )
								end
							else
								exports.sql:query_free( "DELETE FROM maps WHERE mapID = " .. mapID )
								outputChatBox( "Map '" .. mapName .. "' could not be added.", player, 255, 0, 0 )
							end
						else
							outputChatBox( "Couldn't allocate an ID for map '" .. mapName .. "'.", player, 255, 0, 0 )
						end
					else
						outputChatBox( "Ignoring map '" .. mapName .. "' - it has no objects.", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Map '" .. mapName .. "' already exists.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Unable to load map '" .. mapName .. "'.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [map]", player, 255, 255, 255 )
		end
	end,
	true
)

-- remove map by name

addCommandHandler( "removemap",
	function( player, commandName, ... )
		local mapName = table.concat( { ... }, " " )
		if #mapName > 0 then
			local map = maps[ mapName:lower( ) ]
			if map then
				if not map.protected then
					if removeMap( mapName ) then
						outputChatBox( "Removed map '" .. mapName .. "'.", player, 0, 255, 153 )
					else
						outputChatBox( "Could not remove map '" .. mapName .. "'.", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Map '" .. mapName .. "' is marked as protected.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Map '" .. mapName .. "' does not exist.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [map]", player, 255, 255, 255 )
		end
	end,
	true
)

-- setting a map dimension (applies for all elements of that map)

addCommandHandler( "setmapdimension",
	function( player, commandName, ... )
		if ( ... ) and #{ ... } >= 2 then
			local arguments = { ... }
			local dimension = tonumber( arguments[ #arguments ] )
			if dimension >= 0 and dimension <= 65535 then
				arguments[ #arguments ] = nil
				local mapName = table.concat( arguments, " " )
				local map = maps[ mapName:lower( ) ]
				if map then
					if not map.protected then
						local oldDimension = -1
						for object in pairs( map.objects ) do
							oldDimension = getElementDimension( object )
							if oldDimension == dimension then
								outputChatBox( "Map '" .. mapName .. "' is already in that dimension.", player, 255, 0, 0 )
								return
							elseif not setElementDimension( object, dimension ) then
								outputChatBox( "Invalid dimension.", player, 255, 0, 0 )
								return
							end
						end
						
						-- update the database
						if exports.sql:query_free( "UPDATE maps SET mapDimension = " .. dimension .. " WHERE mapID = " .. map.id ) then
							map.dimension = dimension
							outputChatBox( "Map '" .. mapName .. "' was set to dimension " .. dimension .. ".", player, 0, 255, 153 )
						else
							-- revert our update as we failed at querying
							outputChatBox( "Map '" .. mapName .. "' could not be set to dimension " .. dimension .. ".", player, 255, 0, 0 )
							for object in pairs( map.objects ) do
								setElementDimension( object, oldDimension )
							end
						end
					else
						outputChatBox( "Map '" .. mapName .. "' is marked as protected.", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Map '" .. mapName .. "' does not exist.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Invalid dimension.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [dimension]", player, 255, 255, 255 )
		end
	end,
	true
)
