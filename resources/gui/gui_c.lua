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
local width = 300
local height = 0
local x = ( screenX - width ) / 2
local line_height = 16
local max_lines = 31
local max_height = line_height * max_lines
local max_panes = math.floor( max_height / 66 )
local clicked = { }
destroy = { }

local window = nil
local windowName = nil

local function cache( window )
	local size = 0
	if window.type == "grid" then
		-- content generation either via a function or table
		local content = type( window.content ) == "function" and window.content( ) or window.content
		
		local max_lines = max_lines - 1
		if #content > max_lines then
			if not window.scrollpos then
				window.scrollpos = 1
			else
				-- use up/down scrolling
				if clicked.mouse_wheel_up then
					window.scrollpos = math.max( 1, window.scrollpos - math.ceil( max_lines / 2 ) )
				elseif clicked.mouse_wheel_down then
					window.scrollpos = math.min( #content - max_lines + 1, window.scrollpos + math.ceil( max_lines / 2 ) )
				end
			end
			
			window.cachedcontent = { }
			for i = window.scrollpos, math.min( #content, window.scrollpos + max_lines - 1 ) do
				if content[i] then
					table.insert( window.cachedcontent, content[i] )
				end
			end
		else
			window.cachedcontent = content
		end
		size = size + ( #window.cachedcontent + 1 ) * line_height
	elseif window.type == "label" or window.type == "edit" then
		window.cachedtext = type( window.text ) == "function" and window.text( ) or window.text
		window.cachedlines = type( window.lines ) == "function" and window.lines( ) or window.lines or (function( ) _, count = window.cachedtext:gsub( "\n", "\n" ) return count + 1 end)()
		size = size + dxGetFontHeight( window.scale or 1, window.font or "default" ) * math.max( window.type == "edit" and 2 or 1, window.cachedlines )
	elseif window.type == "button" then
		size = size + line_height * 2
	elseif window.type == "pane" then
		local panes = window.panes
		
		-- let's see how far we can go
		if #panes > max_panes then
			if not window.scrollpos then
				window.scrollpos = 1
			else
				-- use up/down scrolling
				if clicked.mouse_wheel_up then
					window.scrollpos = math.max( 1, window.scrollpos - math.ceil( max_panes / 2 ) )
				elseif clicked.mouse_wheel_down then
					window.scrollpos = math.min( #panes - max_panes + 1, window.scrollpos + math.ceil( max_panes / 2 ) )
				end
			end
			
			window.cachedpanes = { }
			for i = window.scrollpos, math.min( #panes, window.scrollpos + max_panes - 1 ) do
				if panes[i] then
					table.insert( window.cachedpanes, panes[i] )
				end
			end
		else
			window.cachedpanes = panes
		end
		
		size = size + ( #window.cachedpanes * 66 )
	end
	
	for k, v in ipairs( window ) do
		size = size + cache( v )
	end
	
	return size
end

local function draw( window, y )
	if window.type == "grid" then
		-- get the column positions
		if window.columns[1] and not window.columns[1].pos then
			local lastwidth = 0
			for k, v in ipairs( window.columns ) do
				v.pos = { _start = x + lastwidth * width, _end = x + ( lastwidth + v.width ) * width }
				lastwidth = lastwidth + v.width
			end
		end
		
		-- draw column headers
		for k, v in ipairs( window.columns ) do
			-- actually draw the text
			dxDrawText( tostring( v.name ), v.pos._start, y, v.pos._end, y + line_height, v.color and tocolor( unpack( v.color ) ) or tocolor( 255, 255, 255, 255 ), 1, v.font or "default-bold", v.alignX or "left", v.alignY or "center", true, false, true )
		end
		
		-- go to the next line
		y = y + line_height
		
		-- draw the content
		for key, value in ipairs( window.cachedcontent ) do
			-- check for hover/click
			if cursorX >= x and cursorX <= x + width and cursorY >= y and cursorY <= y + line_height then
				if value.onHover then
					value.onHover( { cursorX, cursorY }, { x, y, x + width, y + line_height } )
				end
				
				if value.onClick then
					if clicked.mouse1 then
						value.onClick( 1, { cursorX, cursorY }, { x, y, x + width, y + line_height } )
					end
					if clicked.mouse2 then
						value.onClick( 2, { cursorX, cursorY }, { x, y, x + width, y + line_height } )
					end
				end
			end
			
			-- draw the single columns
			for k, text in ipairs( value ) do
				-- check if this is meant to have a special color
				local color = value.color
				if type( text ) == "table" then
					color = text.color
					text = text.text
				end
				
				-- draw it
				local v = window.columns[k]
				dxDrawText( tostring( text ), v.pos._start, y, v.pos._end, y + line_height, color and tocolor( unpack( color ) ) or v.color and tocolor( unpack( v.color ) ) or tocolor( 255, 255, 255, 255 ), 1, v.font or "default-bold", v.alignX or "left", v.alignY or "center", true, false, true )
			end
			
			-- go to the next line
			y = y + line_height
		end
	elseif window.type == "label" or window.type == "edit" then
		local line_height = dxGetFontHeight( window.scale or 1, window.font or "default" ) * math.max( window.type == "edit" and 2 or 1, window.cachedlines )
		dxDrawText( tostring( window.cachedtext ), x, y, x + width / ( window.type == "edit" and 2.7 or 1 ), y + line_height, window.color and tocolor( unpack( window.color ) ) or tocolor( 255, 255, 255, 255 ), window.scale or 1, window.font or "default", window.alignX or window.type == "edit" and "right" or "left", window.alignY or "center", true, false, true )
		
		if window.type == "edit" then
			if not window.edit then
				window.edit = guiCreateEdit( x + width / 2.6, y + 3, width / 2 - 20, line_height - 8, "", false )
				
				if window.masked then
					guiEditSetMasked( window.edit, true )
				end
				
				addEventHandler( "onClientElementDestroy", window.edit, function( ) window.edit = nil end, false )
				if window.onAccepted then
					addEventHandler( "onClientGUIAccepted", window.edit, function( ) window.onAccepted( ) end, false )
				end
				
				if window.id then
					destroy[ window.id ] = window.edit
				else
					table.insert( destroy, window.edit )
				end
			else
				local bx, by = guiGetPosition( window.button, false )
				if by ~= y + 3 then
					guiSetPosition( window.button, bx, y + 3, false )
				end
			end
		end
		
		y = y + line_height
	elseif window.type == "button" then
		local line_height = line_height * 2 - 4
		if not window.button then
			window.button = guiCreateButton( x + width / 4, y + 3, width / 2, line_height - 4, tostring( window.text ), false )
			
			if window.masked then
				guiEditSetMasked( window.button, true )
			end
			
			addEventHandler( "onClientElementDestroy", window.button, function( ) window.button = nil end, false )
			if window.onClick then
				addEventHandler( "onClientGUIClick", window.button,
					function( button, state )
						if state == "up" then
							if button == "left" then
								window.onClick( 1 )
							elseif button == "right" then
								window.onClick( 2 )
							end
						end
					end,
					false
				)
			end
			
			if window.id then
				destroy[ window.id ] = window.button
			else
				table.insert( destroy, window.button )
			end
		else
			local bx, by = guiGetPosition( window.button, false )
			if by ~= y + 3 then
				guiSetPosition( window.button, bx, y + 3, false )
			end
		end
		
		y = y + line_height
	elseif window.type == "pane" then
		for key, value in ipairs( window.cachedpanes ) do
			y = y + 1
			
			-- check for hover/click
			if cursorX >= x and cursorX <= x + width and cursorY >= y and cursorY <= y + 64 then
				if value.onHover then
					value.onHover( { cursorX, cursorY }, { x, y, x + width, y + 64 } )
				end
				
				if value.onClick then
					if clicked.mouse1 then
						value.onClick( 1, { cursorX, cursorY }, { x, y, x + width, y + 64 } )
					end
					if clicked.mouse2 then
						value.onClick( 2, { cursorX, cursorY }, { x, y, x + width, y + 64 } )
					end
				end
			end
			
			-- draw the pane
			dxDrawImage( x, y, 64, 64, value.image, 0, 0, 0, tocolor( 255, 255, 255, 255 ), true )
			dxDrawText( value.title, x + 65, y, x + width, y + 18, tocolor( 255, 255, 255, 255 ), 0.6, "bankgothic", "left", "top", true, false, true )
			dxDrawText( tostring( type( value.text ) == "function" and value.text( ) or value.text ), x + 70, y + 18, x + width, y + 64, tocolor( 255, 255, 255, 255 ), 1, "default", "left", "top", true, value.wordBreak or false, true )
			y = y + 65
		end
	end
	
	-- run all child drawings
	for k, v in ipairs( window ) do
		y = draw( v, y )
	end
	
	return y
end

local changeableWindows = { 'scoreboard', 'characters' }
local function isChangeableWindow( windowName )
	for key, value in ipairs( changeableWindows ) do
		if value == windowName then
			return key
		end
	end
	return false
end
addEventHandler( "onClientRender", root,
	function( )
		if window then
			-- save the cursor position
			cursorX, cursorY = getCursorPosition( )
			if cursorX then
				cursorX = cursorX * screenX
				cursorY = cursorY * screenY
			else
				cursorX = -1
				cursorY = -1
			end
			
			height = math.min( max_height, cache( window ) )
			local y = ( screenY - height ) / 2
			dxDrawRectangle( x - 5, y - 5, width + 10, height + 10, tocolor( 0, 0, 0, 127 ) )
			draw( window, y )
			
			-- draw left/right if it's the scoreboard/char selection and is not forced
			if not forcedWindow then
				local key = isChangeableWindow( windowName )
				if key then
					dxDrawRectangle( x - 35, screenY / 2 - 15, 30, 30, tocolor( 0, 0, 0, 127 ) )
					dxDrawText( "<", x - 35, screenY / 2 - 15, x - 5, screenY / 2 + 15, tocolor( 255, 255, 255, 255 ), 1, "bankgothic", "center", "center", true, false, true )
					if clicked.mouse1 and cursorX >= x - 35 and cursorX <= x - 5 and cursorY >= screenY / 2 - 15 and cursorY <= screenY / 2 + 15 then
						if key == 1 then
							key = #changeableWindows
						else
							key = key - 1
						end
						show( changeableWindows[ key ], false, false, showMouse )
					end
					
					dxDrawRectangle( x + width + 5, screenY / 2 - 15, 30, 30, tocolor( 0, 0, 0, 127 ) )
					dxDrawText( ">", x + width + 5, screenY / 2 - 15, x + width + 35, screenY / 2 + 15, tocolor( 255, 255, 255, 255 ), 1, "bankgothic", "center", "center", true, false, true )
					if clicked.mouse1 and cursorX >= x + width + 5 and cursorX <= x + width + 35 and cursorY >= screenY / 2 - 15 and cursorY <= screenY / 2 + 15 then
						if key == #changeableWindows then
							key = 1
						else
							key = key + 1
						end
						show( changeableWindows[ key ], false, false, showMouse )
					end
				end
			end
		end
		clicked = { }
	end
)

bindKey( 'tab', 'both',
	function( key, state )
		if not forcedWindow then
			if state == 'down' then
				if window == windows.scoreboard then
					hide( )
				else
					show( 'scoreboard' )
					scoreboardTick = getTickCount( )
				end
			else
				if getTickCount( ) - scoreboardTick > 200 then
					hide( )
				end
			end
		end
	end
)

addEventHandler( "onClientMouseWheel", root,
	function( direction )
		outputChatBox( tostring( direction ) )
		if direction > 0 then
			clicked.mouse_wheel_up = true
		else
			clicked.mouse_wheel_down = true
		end
	end
)

addEventHandler( "onClientClick", root,
	function( button, state )
		if state == 'down' then
			if button == 'left' then
				clicked.mouse1 = true
			elseif button == 'right' then
				clicked.mouse2 = true
			end
		end
	end
)
bindKey( 'mouse_wheel_up', 'down', function( ) clicked.mouse_wheel_up = true end )
bindKey( 'mouse_wheel_down', 'down', function( ) clicked.mouse_wheel_down = true end )

addEventHandler( "onClientPlayerRadioSwitch", root,
	function( )
		if window then
			cancelEvent( )
		end
	end
)

--

function getShowing( )
	return windowName, forcedWindow
end

function show( name, forced, dontEnableInput, mouse )
	-- destroy old window if we have one
	if window then
		hide( )
	end
	
	if windows[name] then
		window = windows[name]
		windowName = name
		if forced then
			forcedWindow = true
			showCursor( true )
			if not dontEnableInput then
				guiSetInputEnabled( true )
			end
		elseif mouse then
			showCursor( true )
			showMouse = true
		end
	end
end

function hide( )
	if window then
		if window.onClose then
			window.onClose( )
		end
		window = nil
		windowName = nil
		showCursor( false )
		if forcedWindow then
			guiSetInputEnabled( false )
		end
		forcedWindow = nil
		for key, value in pairs( destroy ) do
			destroyElement( value )
		end
		destroy = { }
	end
end

addEventHandler( "onClientResourceStop", resourceRoot,
	function( )
		hide( )
	end
)
