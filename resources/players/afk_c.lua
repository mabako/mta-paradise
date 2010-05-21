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

local afkTime = 0
timer = setTimer(
	function( )
		if isLoggedIn( ) then
			-- this runs once every 10 seconds, thus might not be completely accurate
			afkTime = afkTime + 10
			if afkTime > getElementData( resourceRoot, "afk_time" ) then
				killTimer( timer )
				triggerServerEvent( getResourceName( resource ) .. ":afk", getLocalPlayer( ) )
			end
		else
			afkTime = 0
		end
	end,
	10000,
	0
)

local function reset( )
	afkTime = 0
end

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		-- this is mostly triggered by moving the cursor and/or using the chatbox
		addEventHandler( "onClientCursorMove", root, reset )
		
		-- if the control state changes, the player is most likely there...
		local controls = { 'fire', 'next_weapon', 'previous_weapon', 'forwards', 'backwards', 'left', 'right', 'zoom_in', 'zoom_out', 'change_camera', 'jump', 'sprint', 'look_behind', 'crouch', 'walk', 'aim_weapon', 'enter_exit', 'vehicle_fire', 'vehicle_secondary_fire', 'vehicle_left', 'vehicle_right', 'steer_forward', 'steer_back', 'accelerate', 'brake_reverse', 'horn', 'sub_mission', 'vehicle_look_left', 'vehicle_look_right', 'vehicle_look_behind', 'vehicle_mouse_look', 'special_control_left', 'special_control_right', 'special_control_up', 'special_control_down' }
		for key, value in ipairs( controls ) do
			bindKey( value, "both", reset )
		end
		
		-- writing something in console is definitively worth a small notice
		addEventHandler( "onClientConsole", root, reset )
	end
)

