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

local localPlayer = getLocalPlayer( )
local loggedIn = false
local screenX, screenY = guiGetScreenSize( )

addEvent( getResourceName( resource ) .. ":spawnscreen", true )
addEventHandler( getResourceName( resource ) .. ":spawnscreen", localPlayer,
	function( )
		exports.gui:show( 'login', true )
		
		fadeCamera( true, 1 )
		showChat( false )
		showPlayerHudComponent( "radar", false )
		showPlayerHudComponent( "area_name", false )
		
		if charSelectionActive then
			charEnd = getTickCount( ) + 2000
			charSelectionActive = false
			setTimer(
				function( )
					removeEventHandler( "onClientRender", root, showCharacters )
					charEnd = 0
					hoverChar = 1 -- don't show the 'Logout' button again
				end, 2000, 1
			)
		end
		
		loggedIn = false
	end
)

addEventHandler( "onClientResourceStart", getResourceRootElement( ),
	function( )
		triggerServerEvent( getResourceName( resource ) .. ":ready", localPlayer, screenX, screenY )
	end
)

--

charSelectionActive = false
local characters = nil
local isSpawnScreen = false
hoverChar = 1
local oldHoverChar = nil
local gotoChar = nil
local keyTime = nil
local charStart = 0
charEnd = 0
local fadeTime = 500
local charSelectionWaiting = false

addCommandHandler( "changechar",
	function( )
		if loggedIn and charEnd == 0 and not isPlayerDead( localPlayer ) then
			if charSelectionActive then
				charEnd = getTickCount( ) + 2000
				setTimer(
					function( )
						removeEventHandler( "onClientRender", root, showCharacters )
						charEnd = 0
						charSelectionActive = false
						showChat( true )
						showPlayerHudComponent( "radar", true )
					end, 2000, 1
				)
			else
				charStart = getTickCount( )
				charSelectionActive = true
				charSelectionWaiting = false
				addEventHandler( "onClientRender", root, showCharacters )
				showChat( false )
				showPlayerHudComponent( "radar", false )
			end
		end
	end
)
bindKey( "pause", "down", "changechar" )

local function selectChar( id, name )
	if id == -1 then
		-- new character
	elseif id == -2 then
		-- logout
		charSelectionWaiting = true
		triggerServerEvent( getResourceName( resource ) .. ":logout", localPlayer )
	elseif loggedIn and name == getPlayerName( localPlayer ):gsub( "_", " " ) then
		charEnd = getTickCount( ) + 2000
		charSelectionWaiting = true
		setTimer(
			function( )
				removeEventHandler( "onClientRender", root, showCharacters )
				charEnd = 0
				charSelectionActive = false
				showChat( true )
				showPlayerHudComponent( "radar", false )
			end, 2000, 1
		)
	else
		triggerServerEvent( getResourceName( resource ) .. ":spawn", localPlayer, id )
	end
end

function showCharacters( )
	charAlpha = math.min( ( charEnd == 0 and ( getTickCount( ) - charStart ) or ( charEnd - getTickCount( ) ) ) / 2000 * 255, 255 )
	
	dxDrawRectangle( 0, 0, screenX * 0.1, screenY, tocolor( 0, 0, 0, charAlpha / 2 ) )
	if gotoChar then
		local diff = getTickCount( ) - keyTime
		if diff >= fadeTime then
			hoverChar = gotoChar
			oldHoverChar = 0
			gotoChar = nil
			if not loggedIn then
				if characters[ hoverChar ].skin >= 0 then
					setElementModel( localPlayer, characters[ hoverChar ].skin )
					setElementAlpha( localPlayer, 255 )
				end
			end
		else
			if not loggedIn then
				if diff < fadeTime / 2 then
					setElementAlpha( localPlayer, math.min( getElementAlpha( localPlayer ), 255 * ( 1 - diff / ( fadeTime / 2 ) ) ) )
				else
					if characters[ gotoChar ].skin >= 0 and getElementModel( localPlayer ) ~= characters[ gotoChar ].skin then
						setElementModel( localPlayer, characters[ gotoChar ].skin )
					end
					setElementAlpha( localPlayer, math.min( 255, 255 * ( diff - ( fadeTime / 2 ) ) / ( fadeTime / 2 ) ) )
				end
			end
			hoverChar = oldHoverChar + ( gotoChar - oldHoverChar ) * diff / fadeTime
		end
	elseif not isMTAWindowActive( ) and charEnd == 0 and not charSelectionWaiting then
		if getKeyState( 'arrow_u' ) and hoverChar > 1 then
			keyTime = getTickCount( )
			oldHoverChar = hoverChar
			gotoChar = hoverChar - 1
		elseif getKeyState( 'arrow_d' )and hoverChar < #characters then
			keyTime = getTickCount( )
			oldHoverChar = hoverChar
			gotoChar = hoverChar + 1
		elseif getKeyState( 'enter' ) then
			if not keyStateEnter then
				selectChar( characters[ hoverChar ].characterID, characters[ hoverChar ].characterName )
				keyStateEnter = true
			end
		elseif keyStateEnter then
			keyStateEnter = false
		end
	end
	
	local height = screenX * 0.09
	for key, value in ipairs( characters ) do
		local y = screenY / 2 + screenX * 0.095 * ( key - hoverChar )
		
		-- color the background panel
		local t, r, g, b = 0, 0, 0, 0
		if key == hoverChar then
			t = 255
		elseif key == gotoChar then
			t = 255 * ( 1 - math.abs( hoverChar - gotoChar ) )
		elseif key == oldHoverChar then
			t = 255 * ( 1 - math.abs( hoverChar - oldHoverChar ) )
		end
		if characters[ key ].skin == -1 then
			r, g, b = 255, 255, 255 - t
		elseif characters[ key ].skin == -2 then
			r, g, b = 255, 255 - t, 255 - t
		else
			r, g, b = 255 - t, 255, 255
		end
		
		dxDrawRectangle( screenX * 0.005, y, height, height, tocolor( r, g, b, charAlpha / 5 ) )
		if characters[ key ].skin < 0 then -- TODO: remove when we have all skins images
			dxDrawImage( screenX * 0.005 + 2, y + 2, height - 4, height - 4, "images/skins/" .. characters[ key ].skin .. ".png", 0, 0, 0, tocolor( 255, 255, 255, charAlpha ) )
		end
		dxDrawText( value.characterName, screenX * 0.11, y, screenX, y + height, tocolor( 255, 255, 255, ( charAlpha / 255 ) * math.max( t, 50 ) ), 2, "default", "left", "center" )
	end
end

addEvent( getResourceName( resource ) .. ":characters", true )
addEventHandler( getResourceName( resource ) .. ":characters", localPlayer,
	function( chars, spawn )
		isSpawnScreen = spawn
		if isSpawnScreen then
			showChat( false )
			showPlayerHudComponent( "radar", false )
			showPlayerHudComponent( "area_name", false )
			
			exports.gui:hide( )
			keyStateEnter = true
			
			showCursor( true )
			guiSetInputEnabled( true )
			
			if #chars >= 1 then
				setElementModel( localPlayer, chars[ 1 ].skin )
				local function fadeInChar( )
					local alpha = math.min( ( getTickCount( ) - charStart ) / 2000 * 255, 255 )
					setElementAlpha( localPlayer, alpha )
					
					if alpha == 255 then
						removeEventHandler( "onClientRender", root, fadeInChar )
					end
				end
				addEventHandler( "onClientRender", root, fadeInChar )
			end
			
			charStart = getTickCount( )
			charEnd = 0
			charSelectionWaiting = false
			
			loggedIn = false
			
			charSelectionActive = true
			addEventHandler( "onClientRender", root, showCharacters )
		end
		
		chars[ #chars + 1 ] = { characterName = "New Character", skin = -1, characterID = -1 }
		chars[ #chars + 1 ] = { characterName = "Logout", skin = -2, characterID = -2 }
		
		characters = chars
	end
)

addEvent( getResourceName( resource ) .. ":onSpawn", true )
addEventHandler( getResourceName( resource ) .. ":onSpawn", localPlayer,
	function( )
		showCursor( false )
		guiSetInputEnabled( false )
		
		charEnd = getTickCount( ) + 2000
		charSelectionWaiting = false
		setTimer(
			function( )
				removeEventHandler( "onClientRender", root, showCharacters )
				charEnd = 0
				charSelectionActive = false
				loggedIn = true
				showChat( true )
				showPlayerHudComponent( "radar", true )
				showPlayerHudComponent( "area_name", true )
			end, 2000, 1
		)
	end
)
