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

local fuelRoot = createElement( "fuelpoint" )

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		if not exports.sql:create_table( 'fuelpoints', 
			{
				{ name = 'fuelpointID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'posX', type = 'float' },
				{ name = 'posY', type = 'float' },
				{ name = 'posZ', type = 'float' },
				{ name = 'name', type = 'varchar(5)' },
			} ) then cancelEvent( ) return end
		
		--
		
		local result = exports.sql:query_assoc( "SELECT * FROM fuelpoints ORDER BY fuelpointID ASC" )
		if result then
			for key, data in ipairs( result ) do
				local colshape = createColSphere( data.posX, data.posY, data.posZ, 2 )
				setElementParent( colshape, fuelRoot )
				setElementData( colshape, "name", tonumber( data.name ) or data.name )
			end
		end
	end
)

addCommandHandler( "createfuelpoint",
	function( player, commandName, ... )
		if ( ... ) then
			local name = table.concat( { ... }, " " )
			local x, y, z = getElementPosition( player )
			if exports.sql:query_free( "INSERT INTO fuelpoints (posX, posY, posZ, name) VALUES(" .. table.concat( { x, y, z, '"%s"' }, ", " ) .. ")", name ) then
				local colshape = createColSphere( x, y, z, 2 )
				setElementParent( colshape, fuelRoot )
				setElementData( colshape, "name", tonumber( name ) or name )
				outputChatBox( "Created fuelpoint '" .. name .. "'.", player, 0, 255, 0 )
			else
				outputChatBox( "Fuelpoint creation failed.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [name]", player, 255, 255, 255 )
		end
	end,
	true
)

addEvent( "vehicles:fill", true )
addEventHandler( "vehicles:fill", fuelRoot,
	function( amount )
		if client and isElementWithinColShape( client, source ) and type( amount ) == 'number' and amount == math.ceil( amount ) and amount > 0 then
			local vehicle = getPedOccupiedVehicle( client )
			if vehicle and getVehicleOccupant( vehicle ) == client and doesVehicleHaveFuel( vehicle ) and not getVehicleEngineState( vehicle ) then
				if exports.players:takeMoney( client, math.ceil( amount * 0.25 ) ) then
					increaseFuel( vehicle, amount )
				end
			end
		end
	end
)
