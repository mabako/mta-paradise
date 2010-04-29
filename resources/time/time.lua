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

local function syncTime( )
	local time = getRealTime( )
	setTime( time.hour, time.minute )
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		setMinuteDuration( 60000 )
		syncTime( )
		
		setTimer( syncTime, 300000, 0 ) -- adjust the time every 5 minutes
	end
)
