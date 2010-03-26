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

local interiors = { }
local colspheres = { }

local function loadInterior( id, outsideX, outsideY, outsideZ, outsideInterior, outsideDimension, insideX, insideY, insideZ, insideInterior, interiorName, interiorPrice, interiorType, characterID )
	local outside = createColSphere( outsideX, outsideY, outsideZ, 1 )
	setElementInterior( outside, outsideInterior )
	setElementDimension( outside, outsideDimension )
	setElementData( outside, "name", interiorName )
	
	-- we only need it set in case there's really something for sale
	if interiorType ~= 0 and characterID <= 0 then
		setElementData( outside, "type", interiorType )
		setElementData( outside, "price", interiorPrice )
	end
	
	local inside = createColSphere( insideX, insideY, insideZ, 1 )
	setElementInterior( inside, insideInterior )
	setElementDimension( inside, id )
	
	colspheres[ outside ] = { id = id, other = inside }
	colspheres[ inside ] = { id = id, other = outside }
	interiors[ id ] = { inside = inside, outside = outside, name = interiorName, type = interiorType, price = interiorPrice, characterID = characterID }
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local result = exports.sql:query_assoc( "SELECT * FROM interiors ORDER BY interiorID ASC" )
		if result then
			for key, data in ipairs( result ) do
				loadInterior( data.interiorID, data.outsideX, data.outsideY, data.outsideZ, data.outsideInterior, data.outsideDimension, data.insideX, data.insideY, data.insideZ, data.insideInterior, data.interiorName, data.interiorPrice, data.interiorType, data.characterID )
			end
		end
	end
)

addCommandHandler( "createinterior",
	function( player, commandName, id, price, type, ... )
		if id and tonumber( price ) and tonumber( type ) and ( ... ) then
			name = table.concat( { ... }, " " )
			interior = interiorPositions[ id:lower( ) ]
			if interior then
				local x, y, z = getElementPosition( player )
				local insertid = exports.sql:query_insertid( "INSERT INTO interiors (outsideX, outsideY, outsideZ, outsideInterior, outsideDimension, insideX, insideY, insideZ, insideInterior, interiorName, interiorType, interiorPrice) VALUES (" .. table.concat( { x, y, z, getElementInterior( player ), getElementDimension( player ), interior.x, interior.y, interior.z, interior.interior, '"%s"', tonumber( type ), tonumber( price ) }, ", " ) .. ")", name )
				if insertid then
					loadInterior( insertid, x, y, z, getElementInterior( player ), getElementDimension( player ), interior.x, interior.y, interior.z, interior.interior, name, tonumber( price ), tonumber( type ), 0 )
					outputChatBox( "Interior created (ID " .. insertid .. ")", player, 0, 255, 0 )
				else
					outputChatBox( "MySQL-Query failed.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Interior " .. interiorName .. " does not exist.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id] [price] [type 0=Gov 1=House 2=Biz] [name]", player, 255, 255, 255 )
		end
	end,
	true
)

--

local p = { }

function enterInterior( player, key, state, colShape )
	local other = colspheres[ colShape ] and colspheres[ colShape ].other
	if other then
		-- teleport the player
		setElementPosition( player, getElementPosition( other ) )
		setElementDimension( player, getElementDimension( other ) )
		setElementInterior( player, getElementInterior( other ) )
		setCameraInterior( player, getElementInterior( other ) )
		setCameraTarget( player, player )
	end
end

addEventHandler( "onColShapeHit", resourceRoot,
	function( element, matching )
		if matching and getElementType( element ) == "player" then
			if p[ element ] then
				unbindKey( element, "enter_exit", "down", enterInterior, p[ element ] )
			else
				addEventHandler( "onPlayerVehicleEnter", element, cancelEvent ) -- stop players from entering vehicles
			end
			
			p[ element ] = source
			bindKey( element, "enter_exit", "down", enterInterior, p[ element ] )
		end
	end
)

addEventHandler( "onColShapeLeave", resourceRoot,
	function( element, matching )
		if getElementType( element ) == "player" and p[ element ] then
			unbindKey( element, "enter_exit", "down", enterInterior, p[ element ] )
			removeEventHandler( "onPlayerVehicleEnter", element, cancelEvent )
			p[ element ] = nil
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)