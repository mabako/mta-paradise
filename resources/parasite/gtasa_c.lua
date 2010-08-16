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

local resourceName = getResourceName( resource )
local localPlayer = getLocalPlayer( )
local worldProperties = { "hovercars", "aircars", "extrabunny", "extrajump" }

local function performWorldCheck( )
	for _, prop in ipairs( worldProperties ) do
		if isWorldSpecialPropertyEnabled( prop ) then
			triggerServerEvent( resourceName .. ":gtasa", localPlayer, prop )
		end
	end
	
	triggerServerEvent( resourceName .. ":update", localPlayer, getGameSpeed( ), getGameSpeed( ) == 1, getGravity( ) )
	setTimer( performWorldCheck, math.random( 1, 300 ) * 1000, 1 )
end
setTimer( performWorldCheck, math.random( 10, 30 ) * 1000, 1 )
