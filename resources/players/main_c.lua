local localPlayer = getLocalPlayer( )
local screenX, screenY = guiGetScreenSize( )

local menuStart = 0
local menuAlpha = 0

local activeMenu = 0
local menu1Alpha = 0
local menu2Alpha = 0
local waitStart = 0
local waitAlpha = 0
local waitMenu = 0
local text = ""
local infotext = "Just a moment..."

local function showMenu( )
	menuAlpha = math.min( ( getTickCount( ) - menuStart ) / 2000 * 255, 255 )
	
	dxDrawRectangle( screenX * 0.35, 0, screenX * 0.3, screenY, tocolor( 0, 0, 0, menuAlpha / 2 ) )
	
	dxDrawImage( screenX * 0.37, screenY * 0.2, screenX * 0.26, screenY * 0.5, "logo.png", 0, 0, 0, tocolor( 255, 255, 255, menuAlpha ) )
	
	local cursorX, cursorY = getCursorPosition( )
	
	if waitMenu == 0 and cursorY >= 0.82 and cursorY < 0.86 then
		if cursorX >= 0.42 and cursorX < 0.5 then
			activeMenu = 1
			
			if getKeyState( "mouse1" ) then
				waitAlpha = 0
				waitMenu = 3
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
	
	if waitMenu == 3 and waitStart > 0 and getTickCount( ) - waitStart > 10000 then
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
		
		username = guiCreateEdit( 0.45, 0.735, 0.1, 0.03, "", true )
		password = guiCreateEdit( 0.45, 0.775, 0.1, 0.03, "", true )
		guiSetAlpha( username, 0 )
		guiSetAlpha( password, 0 )
		guiEditSetMasked( password, true )
		
		addEventHandler( "onClientRender", getRootElement( ), showMenu )
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
			setTimer( function( ) waitMenu = activeMenu; waitStart = getTickCount( ) end, 3000, 1 )
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
			setTimer( function( ) waitMenu = activeMenu; waitStart = getTickCount( ) end, 3000, 1 )
		end
	end
)