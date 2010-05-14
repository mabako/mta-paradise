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

-- weather table that tells us how often which weather does occur
local weather =
{
	-- not all weathers make sense/look good at all times, this should prolly be fixed (alternative suggestion: make a table and make the weather occurences managable via admin/clicks (never - seldom - average - more than usual - often)
	sunny = { 0, 1, 10, 11, 17, 18, chance = 6 },
	clouds = { 2, 3, 4, 5, 6, 7, chance = 10 },
	fog = { 9, chance = 3 },
	rainy = { 8, 16, chance = 2 },
	dull = { 12, 13, 14, 15, chance = 8 },
}

-- transform it into a table with chances n stuff
local weather_ = { }
for key, value in pairs( weather ) do
	value.name = key
	for i = 1, ( value.chance or 5 ) do
		table.insert( weather_, value )
	end
end

--

local function updateWeather( )
	-- find a new weather
	local weather = weather_[ math.random( 1, #weather_ ) ]
	weather = weather[ math.random( 1, #weather ) ]
	setWeather( weather )
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		-- create an initial weather
		updateWeather( )
		
		-- change it after three hours
		setTimer( updateWeather, 180 * 60000, 0 )
	end
)
