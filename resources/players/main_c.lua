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
local characters = false
local localIP = nil
local serverToken = nil

addEvent( getResourceName( resource ) .. ":spawnscreen", true )
addEventHandler( getResourceName( resource ) .. ":spawnscreen", localPlayer,
	function( )
		setTimer(
			function( )
				if not characters then
					if serverToken then
						local xml = xmlCreateFile( "login-" .. serverToken .. ".xml", "login" )
						if xml then
							xmlSaveFile( xml )
							xmlUnloadFile( xml )
						end
					end
					exports.gui:show( 'login', true )
				end
			end, 300, 1
		)
		
		fadeCamera( true, 1 )
		showChat( false )
		showPlayerHudComponent( "radar", false )
		showPlayerHudComponent( "area_name", false )
		loggedIn = false
		characters = false
	end
)

addEventHandler( "onClientResourceStart", getResourceRootElement( ),
	function( )
		triggerServerEvent( getResourceName( resource ) .. ":requestServerToken", localPlayer )
	end
)

addEvent( getResourceName( resource ) .. ":receiveServerToken", true )
addEventHandler( getResourceName( resource ) .. ":receiveServerToken", root,
	function( serverToken_ )
		serverToken = serverToken_
		local token = nil
		local ip = nil
		if serverToken then
			local xml = xmlLoadFile( "login-" .. serverToken .. ".xml" )
			if xml then
				token = xmlNodeGetValue( xml )
				ip = xmlNodeGetAttribute( xml, "ip" )
				localIP = ip
				xmlUnloadFile( xml )
				xml = nil
			end
		end
		triggerServerEvent( getResourceName( resource ) .. ":ready", localPlayer, screenX, screenY, token and #token > 0 and token, ip and #ip > 0 and ip )
	end
)

--

addCommandHandler( "changechar",
	function( )
		if loggedIn and not isPlayerDead( localPlayer ) then
			local window, forced = exports.gui:getShowing( )
			if not forced then
				if window == 'characters' then
					exports.gui:hide( )
				else
					exports.gui:show( 'characters', false, false, true )
				end
			end
		end
	end
)
bindKey( "pause", "down", "changechar" )

function selectCharacter( id, name )
	if id == -1 then
		-- new character
		exports.gui:show( 'create_character', true )
	elseif id == -2 then
		-- logout
		exports.gui:hide( )
		triggerServerEvent( getResourceName( resource ) .. ":logout", localPlayer )
	elseif loggedIn and name == getPlayerName( localPlayer ):gsub( "_", " " ) then
		exports.gui:hide( )
	else
		exports.gui:hide( )
		triggerServerEvent( getResourceName( resource ) .. ":spawn", localPlayer, id )
	end
end

addEvent( getResourceName( resource ) .. ":characters", true )
addEventHandler( getResourceName( resource ) .. ":characters", localPlayer,
	function( chars, spawn, token, ip )
		characters = chars
		exports.gui:updateCharacters( chars )
		isSpawnScreen = spawn
		if isSpawnScreen then
			exports.gui:show( 'characters', true, true, true )
			showChat( false )
			showPlayerHudComponent( "radar", false )
			showPlayerHudComponent( "area_name", false )
			loggedIn = false
		end
		
		-- auto-login
		if token and serverToken then
			local xml = xmlCreateFile( "login-" .. serverToken .. ".xml", "login" )
			if xml then
				xmlNodeSetValue( xml, token )
				if ip then
					xmlNodeSetAttribute( xml, "ip", ip )
					localIP = ip
				else
					xmlNodeSetAttribute( xml, "ip", localIP )
				end
				xmlSaveFile( xml )
				xmlUnloadFile( xml )
				xml = nil
			end
		end
	end
)

addEventHandler( "onClientResourceStart", root,
	function( res )
		if getResourceName( res ) == "gui" then
			setTimer(
				function( )
					if characters then
						exports.gui:updateCharacters( characters )
						if not loggedIn then
							exports.gui:show( 'characters', true, true, true )
						end
					else
						exports.gui:show( 'login', true )
					end
				end,
				50,
				1
			)
		end
	end
)

addEventHandler( "onClientResourceStop", root,
	function( res )
		exports[ getResourceName( res ) ] = nil
	end
)

addEvent( getResourceName( resource ) .. ":onSpawn", true )
addEventHandler( getResourceName( resource ) .. ":onSpawn", localPlayer,
	function( )
		exports.gui:hide( )
		
		showChat( true )
		showPlayerHudComponent( "radar", true )
		loggedIn = true
		exports.gui:updateCharacters( characters )
		
		outputChatBox( " " )
		outputChatBox( "You are now playing as " .. getPlayerName( localPlayer ):gsub( "_", " " ) .. ".", 0, 255, 0 )
		
		local xml = xmlLoadFile( "tutorial.xml" )
		if not xml then
			xml = xmlCreateFile( "tutorial.xml", "tutorial" )
			xmlSaveFile( xml )
			
			tutorial( )
		end
		xmlUnloadFile( xml )
	end
)

function isLoggedIn( )
	return loggedIn
end
