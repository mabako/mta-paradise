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

local messageTimer
local messageCount = 0
local function setMessage( text )
	windows.create_character[#windows.create_character].text = text
	if messageTimer then
		killTimer( messageTimer )
	end
	messageCount = 0
	setTimer(
		function()
			messageCount = messageCount + 1
			if messageCount == 50 then
				windows.create_character[#windows.create_character].text = ""
				messageTimer = nil
			else
				windows.create_character[#windows.create_character].color = { 255, 255, 255, 5 * ( 50 - messageCount ) }
			end
		end, 100, 50
	)
end

local function tryCreate( key )
	local name = destroy["g:createcharacter:name"] and guiGetText( destroy["g:createcharacter:name"] )
	local error = verifyCharacterName( name )
	if not error then
		triggerServerEvent( "gui:createCharacter", getLocalPlayer( ), name )
	else
		setMessage( error )
	end
end

local function cancelCreate( )
	if exports.players:isLoggedIn( ) then
		hide( )
	else
		show( 'characters', true, true )
	end
end

windows.create_character =
{
	{
		type = "label",
		text = "New Character",
		font = "bankgothic",
		alignX = "center",
	},
	{
		type = "edit",
		text = "Name:",
		id = "g:createcharacter:name",
		onAccepted = tryCreate,
	},
	{
		type = "button",
		text = "Create",
		onClick = tryCreate,
	},
	{
		type = "button",
		text = "Cancel",
		onClick = cancelCreate,
	},
	{
		type = "label",
		text = "",
		alignX = "center",
	}
}

addEvent( "players:characterCreationResult", true )
addEventHandler( "players:characterCreationResult", getLocalPlayer( ),
	function( code )
		if code == 0 then
			if exports.players:isLoggedIn( ) then
				show( 'characters', false, false, true )
			else
				show( 'characters', true, true )
			end
		elseif code == 1 then
			setMessage( "A character with that name already exists." )
		end
	end
)
