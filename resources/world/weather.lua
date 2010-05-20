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

local remoteAddress = get( 'weather' )

--

local weather =
{
	-- not all weathers make sense/look good at all times, this should prolly be fixed (alternative suggestion: make a table and make the weather occurences managable via admin/clicks (never - seldom - average - more than usual - often)
	sunny = { 0, 1, 10, 11, 17, 18 },
	clouds = { 2, 3, 4, 5, 6, 7 },
	fog = { 9 },
	stormy = { 8 },
	rainy = { 16 },
	dull = { 12, 13, 14, 15 },
}

--

local function setWeatherEx( str )
	setWeather( weather[str][ math.random( #weather[str] ) ] )
end

local function setWeatherFromRemote( w, e )
	if w == "ERROR" then
		outputDebugString( "Weather: " .. remoteAddress .. " returned an error: " .. e, 2 )
	elseif w == nil then
		outputDebugString( "Weather: " .. remoteAddress .. " returned no usable data.", 2 )
	else
		if w == 'sunny' or w == 'mostly sunny' or w == 'chance of storm' then
			setWeatherEx( 'sunny' )
		elseif w == 'partly cloudy' or w == 'mostly cloudy' or w == 'smoke' or w == 'cloudy' then
			setWeatherEx( 'clouds' )
		elseif w == 'showers' or w == 'rain' or w == 'chance of rain' then
			setWeatherEx( 'rainy' )
		elseif w == 'storm' or w == 'thunderstorm' or w == 'chance of tstorm' then
			setWeatherEx( 'stormy' )
		elseif w == 'fog' or w == 'icy' or w == 'snow' or w == 'chance of snow' or w == 'flurries' or w == 'sleet' or w == 'mist' then
			setWeatherEx( 'fog' )
		elseif w == 'dust' or w == 'haze' then
			setWeatherEx( 'dull' )
		end
	end
end

local function updateWeather( )
	-- find a new weather
	callRemote( remoteAddress, setWeatherFromRemote )
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		-- create an initial weather
		updateWeather( )
		
		-- change it after three hours
		setTimer( updateWeather, 180 * 60000, 0 )
	end
)
