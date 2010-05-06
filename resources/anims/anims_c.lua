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

local respawnKeys = { 'enter_exit', 'fire' }

--

local localPlayer = getLocalPlayer( )
local screenX, screenY = guiGetScreenSize( )

addEventHandler( "onClientRender", root,
	function( )
		if getPedAnimation( localPlayer ) and exports.players:isLoggedIn( ) and not guiGetInputEnabled( ) then
			-- draw the text
			local text = "Press 'space' to stop the animation"
			dxDrawText( text, 4, 4, screenX, screenY * 0.95, tocolor( 0, 0, 0, 255 ), 1, "pricedown", "center", "bottom", false, false, true )
			dxDrawText( text, 0, 0, screenX, screenY * 0.95, tocolor( 255, 255, 255, 255 ), 1, "pricedown", "center", "bottom", false, false, true )
		end
	end
)

bindKey( "space", "down",
	function( )
		if getPedAnimation( localPlayer ) and exports.players:isLoggedIn( ) then
			triggerServerEvent( "anims:reset", localPlayer )
		end
	end
)
