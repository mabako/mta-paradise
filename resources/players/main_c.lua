local localPlayer = getLocalPlayer( )
local loggedIn = false
local screenX, screenY = guiGetScreenSize( )

local menuStart = 0
local menuAlpha = 0
local menuEnd = 0

local activeMenu = 0
local menu1Alpha = 0
local menu2Alpha = 0
local waitStart = 0
local waitAlpha = 0
local waitMenu = 0
local text = ""
local infotext = "Just a moment..."

local function showMenu( )
	menuAlpha = math.min( ( menuEnd == 0 and ( getTickCount( ) - menuStart ) or ( menuEnd - getTickCount( ) ) ) / 2000 * 255, 255 )
	
	dxDrawRectangle( screenX * 0.35, 0, screenX * 0.3, screenY, tocolor( 0, 0, 0, menuAlpha / 2 ) )
	
	dxDrawImage( screenX * 0.37, screenY * 0.2, screenX * 0.26, screenY * 0.5, "logo.png", 0, 0, 0, tocolor( 255, 255, 255, menuAlpha ) )
	
	local cursorX, cursorY = getCursorPosition( )
	
	if waitMenu == 0 and cursorY >= 0.82 and cursorY < 0.86 then
		if cursorX >= 0.42 and cursorX < 0.5 then
			activeMenu = 1
			
			if getKeyState( "mouse1" ) then
				waitAlpha = 0
				waitMenu = 1
				waitStart = getTickCount( )
				infotext = "Create an account at\nforum.paradisegaming.net"
			end
		elseif cursorX >= 0.5 and cursorX <= 0.58 then
			activeMenu = 2
			
			if getKeyState( "mouse1" ) then
				local u = guiGetText( username )
				local p = guiGetText( password )
				if u and p and #u > 0 and #p > 0 then
					triggerServerEvent( getResourceName( resource ) .. ":login", localPlayer, u, p )
					guiSetEnabled( username, false )
					guiSetEnabled( password, false )
					waitAlpha = 0
					waitMenu = activeMenu
					waitStart = getTickCount( )
					infotext = "Logging in..."
				end
			end
		else
			activeMenu = 0
		end
	else
		activeMenu = 0
	end
	
	if waitMenu == 1 and waitStart > 0 and getTickCount( ) - waitStart > 10000 then
		waitStart = getTickCount( ) + 2000
		waitMenu = 0
		activeMenu = 0
	elseif waitMenu == 0 and getTickCount( ) - waitStart > 2000 then
		waitStart = 0
	end
	
	if menu1Alpha > 0 and activeMenu ~= 1 then
		menu1Alpha = menu1Alpha - 10
	elseif menu1Alpha < 250 and activeMenu == 1 then
		menu1Alpha = menu1Alpha + 10
	end
	
	if menu2Alpha > 0 and activeMenu ~= 2 then
		menu2Alpha = menu2Alpha - 10
	elseif menu2Alpha < 250 and activeMenu == 2 then
		menu2Alpha = menu2Alpha + 10
	end
	
	waitAlpha = waitStart > 0 and math.min( 255, math.max( 0, ( waitMenu == 0 and waitStart - getTickCount( ) or getTickCount( ) - waitStart ) / 2000 * 255 ) ) or 0
	
	dxDrawText( "Register", screenX * 0.42, screenY * 0.82, screenX * 0.5, screenY * 0.86, tocolor( 255 - menu1Alpha, 255, 255, menuAlpha - waitAlpha ), 2, "default", "center", "center" )
	dxDrawText( "Login", screenX * 0.5, screenY * 0.82, screenX * 0.58, screenY * 0.86, tocolor( 255 - menu2Alpha, 255, 255, menuAlpha - waitAlpha ), 2, "default", "center", "center" )
	
	dxDrawText( infotext, screenX * 0.42, screenY * 0.82, screenX * 0.58, screenY * 0.86, tocolor( 255, 255, 255, waitAlpha ), 2, "default", "center", "center" )
	
	guiSetAlpha( username, menuAlpha / 255 )
	guiSetAlpha( password, menuAlpha / 255 )
end

addEvent( getResourceName( resource ) .. ":spawnscreen", true )
addEventHandler( getResourceName( resource ) .. ":spawnscreen", localPlayer,
	function( )
		fadeCamera( true, 1 )
		showChat( false )
		showPlayerHudComponent( "radar", false )
		showPlayerHudComponent( "area_name", false )
		showCursor( true )
		guiSetInputEnabled( true )
		
		menuAlpha = 0
		menuStart = getTickCount( )
		menuEnd = 0
		
		waitStart = 0
		waitAlpha = 0
		waitMenu = 0
		
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
		
		username = guiCreateEdit( 0.45, 0.735, 0.1, 0.03, "", true )
		password = guiCreateEdit( 0.45, 0.775, 0.1, 0.03, "", true )
		guiSetAlpha( username, 0 )
		guiSetAlpha( password, 0 )
		guiEditSetMasked( password, true )
		
		loggedIn = false
		
		addEventHandler( "onClientRender", root, showMenu )
	end
)

addEventHandler( "onClientResourceStart", getResourceRootElement( ),
	function( )
		triggerServerEvent( getResourceName( resource ) .. ":ready", localPlayer )
	end
)

addEvent( getResourceName( resource ) .. ":loginResult", true )
addEventHandler( getResourceName( resource ) .. ":loginResult", localPlayer,
	function( code )
		if code == 1 then
			infotext = "Wrong username\nor password."
			guiSetEnabled( username, true )
			guiSetEnabled( password, true )
			
			-- fade it out
			setTimer( function( ) waitMenu = 0; waitStart = getTickCount( ) + 2000 end, 3000, 1 )
		elseif code == 2 then
			infotext = "You are banned."
			guiSetVisible( username, false )
			guiSetVisible( password, false )
		elseif code == 3 then
			infotext = "Please activate\nyour account."
			guiSetVisible( username, false )
			guiSetVisible( password, false )
		elseif code == 4 then
			infotext = "Unknown Error."
			guiSetEnabled( username, true )
			guiSetEnabled( password, true )
			
			-- fade it out
			setTimer( function( ) waitMenu = 0; waitStart = getTickCount( ) + 2000 end, 3000, 1 )
		elseif code == 5 then
			infotext = "Another player\nuses that account."
			guiSetEnabled( username, true )
			guiSetEnabled( password, true )
			
			-- fade it out
			setTimer( function( ) waitMenu = 0; waitStart = getTickCount( ) + 2000 end, 3000, 1 )
		end
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

addCommandHandler( "changechar",
	function( )
		if loggedIn and charEnd == 0 then
			if charSelectionActive then
				charEnd = getTickCount( ) + 2000
				setTimer(
					function( )
						removeEventHandler( "onClientRender", root, showCharacters )
						charEnd = 0
						charSelectionActive = false
					end, 2000, 1
				)
			else
				charStart = getTickCount( )
				charSelectionActive = true
				addEventHandler( "onClientRender", root, showCharacters )
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
		triggerServerEvent( getResourceName( resource ) .. ":logout", localPlayer )
	elseif loggedIn and name == getPlayerName( localPlayer ):gsub( "_", " " ) then
		charEnd = getTickCount( ) + 2000
		setTimer(
			function( )
				removeEventHandler( "onClientRender", root, showCharacters )
				charEnd = 0
				charSelectionActive = false
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
	elseif not isMTAWindowActive( ) and charEnd == 0 then
		if getKeyState( 'arrow_u' ) and hoverChar > 1 then
			keyTime = getTickCount( )
			oldHoverChar = hoverChar
			gotoChar = hoverChar - 1
		elseif getKeyState( 'arrow_d' )and hoverChar < #characters then
			keyTime = getTickCount( )
			oldHoverChar = hoverChar
			gotoChar = hoverChar + 1
		elseif getKeyState( 'enter' ) or getKeyState( 'num_enter' ) then
			selectChar( characters[ hoverChar ].characterID, characters[ hoverChar ].characterName )
		end
	end
	
	local height = screenX * 0.09
	for key, value in ipairs( characters ) do
		local y = screenY / 2 + screenX * 0.095 * ( key - hoverChar )
		
		
		local t = 0
		if key == hoverChar then
			t = 255
		elseif key == gotoChar then
			t = 255 * ( 1 - math.abs( hoverChar - gotoChar ) )
		elseif key == oldHoverChar then
			t = 255 * ( 1 - math.abs( hoverChar - oldHoverChar ) )
		end
		
		dxDrawRectangle( screenX * 0.005, y, height, height, tocolor( 255 - t, 255, 255, charAlpha / 5 ) )
		dxDrawImage( screenX * 0.005 + 2, y + 2, height - 4, height - 4, "images/skins/" .. characters[ key ].skin .. ".png", 0, 0, 0, tocolor( 255, 255, 255, charAlpha ) )
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
			showCursor( true )
			guiSetInputEnabled( true )
			
			menuAlpha = 0
			menuStart = 0
			menuEnd = getTickCount( ) + 2000
			infotext = ""
			
			setTimer( 
				function( )
					if username then
						destroyElement( username )
					end
					if password then
						destroyElement( password )
					end
					
					removeEventHandler( "onClientRender", root, showMenu )
				end,
				2000,
				1
			)
			
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
		showChat( true )
		showPlayerHudComponent( "radar", true )
		showPlayerHudComponent( "area_name", true )
		showCursor( false )
		guiSetInputEnabled( false )
		
		charEnd = getTickCount( ) + 2000
		setTimer(
			function( )
				removeEventHandler( "onClientRender", root, showCharacters )
				charEnd = 0
				charSelectionActive = false
				loggedIn = true
			end, 2000, 1
		)
	end
)