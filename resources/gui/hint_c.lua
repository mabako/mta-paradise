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

local screenX, screenY = guiGetScreenSize( )
local cursorX, cursorY = -1, -1
local defaultWidth = 360
local width = defaultWidth
local height = 70
local x = ( screenX - width ) / 2
local y = screenY - height - 20
local line_height = 16

--

local title, text, icon, color, start, duration

--

addEventHandler( "onClientRender", root,
	function( )
		if start and duration then
			local tick = getTickCount( )
			if tick > start + duration then
				title = nil
				text = nil
				icon = nil
				color = nil
				start = nil
				duration = nil
			else
				local alpha = 1
				if start + duration / 2 < tick then
					alpha = ( start + duration - tick ) / duration * 2
				end
				
				dxDrawRectangle( x - 5, y - 5, width + 10, height + 10, tocolor( color[1], color[2], color[3], color[4] * alpha ), true )
				dxDrawImage( x, y + ( height - 64 ) / 2, 64, 64, "images/" .. icon .. ".png", 0, 0, 0, tocolor( 255, 255, 255, 255 * alpha ), true )
				dxDrawText( title, x + 65, y, x + width, y + 18, tocolor( 255, 255, 255, 255 * alpha ), 0.6, "bankgothic", "left", "top", true, false, true )
				dxDrawText( text, x + 70, y + 18, x + width, y + height, tocolor( 255, 255, 255, 255 * alpha ), 1, "default", "left", "top", true, true, true )
			end
		end
	end
)

--

function hint( ti, te, ic, dur )
	if ic == 1 then
		icon = "okay"
		color = { 0, 93, 0, 193 }
	elseif ic == 2 then
		icon = "warning"
		color = { 127, 97, 31, 193 }
	elseif ic == 3 then
		icon = "error"
		color = { 127, 31, 31, 193 }
	else
		icon = "info"
		color = { 31, 127, 127, 193 }
	end
	
	start = getTickCount( )
	if type( dur ) ~= "number" or dur < 500 then
		duration = 10000
	else
		duration = dur
	end
	
	title = ti
	text = te
	
	showPlayerHudComponent( "area_name", false )
	
	return true
end

addEvent( "gui:hint", true )
addEventHandler( "gui:hint", getLocalPlayer( ), hint )
