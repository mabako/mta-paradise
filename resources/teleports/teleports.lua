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
	
	-- check for alternative handlers, such as createinterior = createint
	for k, v in ipairs( commandName ) do
		if v:find( "teleport" ) then
			for key, value in pairs( { "tp" } ) do
				local newCommand = v:gsub( "teleport", value )
				if newCommand ~= v then
					-- add a second (replaced) command handler
					addCommandHandler_( newCommand,
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
	end
end

--

local colspheres = { }
local teleports = { }

local function loadTeleport( id, aX, aY, aZ, aInterior, aDimension, bX, bY, bZ, bInterior, bDimension )
	local a = createColSphere( aX, aY, aZ, 1 )
	setElementInterior( a, aInterior )
	setElementDimension( a, aDimension )
	
	local b = createColSphere( bX, bY, bZ, 1 )
	setElementInterior( b, bInterior )
	setElementDimension( b, bDimension )
	
	-- save for further reference
	colspheres[ a ] = { id = id, other = b }
	colspheres[ b ] = { id = id, other = a }
	teleports[ id ] = { a = a, b = b }
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		if not exports.sql:create_table( 'teleports',
		{
			{ name = 'teleportID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
			{ name = 'aX', type = 'float' },
			{ name = 'aY', type = 'float' },
			{ name = 'aZ', type = 'float' },
			{ name = 'aInterior', type = 'tinyint(3) unsigned' },
			{ name = 'aDimension', type = 'int(10) unsigned' },
			{ name = 'bX', type = 'float' },
			{ name = 'bY', type = 'float' },
			{ name = 'bZ', type = 'float' },
			{ name = 'bInterior', type = 'tinyint(3) unsigned' },
			{ name = 'bDimension', type = 'int(10) unsigned' },
			} ) then cancelEvent( ) return end
		
		--
		
		local result = exports.sql:query_assoc( "SELECT * FROM teleports" )
		for key, value in ipairs( result ) do
			loadTeleport( value.teleportID, value.aX, value.aY, value.aZ, value.aInterior, value.aDimension, value.bX, value.bY, value.bZ, value.bInterior, value.bDimension )
		end
	end
)

--

local p = { }

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)

addCommandHandler( "markteleport",
	function( player )
		-- this command only makes sense if used with /createteleport
		if hasObjectPermissionTo( player, "command.createteleport", false ) then
			-- get all properties we need
			local x, y, z = getElementPosition( player )
			x = math.ceil( x * 100 ) / 100
			y = math.ceil( y * 100 ) / 100
			z = math.ceil( z * 100 ) / 100
			local interior = getElementInterior( player )
			local dimension = getElementDimension( player )
			
			-- save them
			if not p[ player ] then
				p[ player ] = { }
			end
			p[ player ].mark = { x = x, y = y, z = z, interior = interior, dimension = dimension }
			
			--
			
			outputChatBox( "Marked teleport position. [" .. table.concat( { "x=" .. x, "y=" .. y, "z=" .. z, "i=" .. interior, "d=" .. dimension }, ", " ) .. "]", player, 0, 255, 153 )
		end
	end
)

addCommandHandler( "createteleport",
	function( player, commandName )
		local a = p[ player ] and p[ player ].mark
		if a then
			local x, y, z = getElementPosition( player )
			x = math.ceil( x * 100 ) / 100
			y = math.ceil( y * 100 ) / 100
			z = math.ceil( z * 100 ) / 100
			local interior = getElementInterior( player )
			local dimension = getElementDimension( player )
			
			local insertid, e = exports.sql:query_insertid( "INSERT INTO teleports (`aX`, `aY`, `aZ`, `aInterior`, `aDimension`, `bX`, `bY`, `bZ`, `bInterior`, `bDimension`) VALUES (" .. table.concat( { a.x, a.y, a.z, a.interior, a.dimension, x, y, z, interior, dimension }, ", " ) .. ")" )
			if insertid then
				loadTeleport( insertid, a.x, a.y, a.z, a.interior, a.dimension, x, y, z, interior, dimension)
				outputChatBox( "Teleport created. (ID " .. insertid .. ")", player, 0, 255, 0 )
				
				-- delete the marked position
				p[ player ].mark = nil
			else
				outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "You need to set the opposite spot with /markteleport first.", player, 255, 0, 0 )
		end
	end,
	true
)

addCommandHandler( { "deleteteleport", "delteleport" },
	function( player, commandName, teleportID )
		teleportID = tonumber( teleportID )
		if teleportID then
			local teleport = teleports[ teleportID ]
			if teleport then
				if exports.sql:query_free( "DELETE FROM teleports WHERE teleportID = " .. teleportID ) then
					outputChatBox( "You deleted teleport " .. teleportID .. ".", player, 0, 255, 153 )
					
					-- delete the markers
					colspheres[ teleport.a ] = nil
					destroyElement( teleport.a )
					colspheres[ teleport.b ] = nil
					destroyElement( teleport.b )
				else
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Teleport not found.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

--

local function useTeleport( player, key, state, colShape )
	local data = colspheres[ colShape ]
	if data then
		local other = data.other
		if other then
			triggerEvent( "onColShapeLeave", colShape, player, true )
			-- teleport the player
			setElementDimension( player, getElementDimension( other ) )
			setElementInterior( player, getElementInterior( other ) )
			setCameraInterior( player, getElementInterior( other ) )
			setElementPosition( player, getElementPosition( other ) )
			setCameraTarget( player, player )
			
			triggerEvent( "onColShapeHit", other, player, true )
		end
	end
end

addEventHandler( "onColShapeHit", resourceRoot,
	function( element, matching )
		if matching and getElementType( element ) == "player" then
			if not p[ element ] then
				p[ element ] = { }
			elseif p[ element ].tp then
				unbindKey( element, "enter_exit", "down", useTeleport, p[ element ].tp )
			end
			
			p[ element ].tp = source
			bindKey( element, "enter_exit", "down", useTeleport, p[ element ].tp )
			setElementData( element, "interiorMarker", true, false )
		end
	end
)

addEventHandler( "onColShapeLeave", resourceRoot,
	function( element, matching )
		if getElementType( element ) == "player" and p[ element ].tp then
			unbindKey( element, "enter_exit", "down", useTeleport, p[ element ].tp )
			removeElementData( element, "interiorMarker", true, false )
			p[ element ].tp = nil
		end
	end
)
