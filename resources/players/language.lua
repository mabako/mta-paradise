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

function saveLanguages( player, languages )
	local characterID = getCharacterID( player )
	if characterID then
		if exports.sql:query_free( "UPDATE characters SET languages = '%s' WHERE characterID = " .. characterID, toJSON( languages ) ) then
			return true
		end
	end
	return false
end

function getCurrentLanguage( player )
	if isLoggedIn( player ) then
		for key, value in pairs( p[ player ].languages ) do
			if value.current then
				return key
			end
		end
	end
end

addEvent( "players:selectLanguage", true )
addEventHandler( "players:selectLanguage", root,
	function( flag )
		if source == client then
			if isLoggedIn( source ) and isValidLanguage( flag ) then
				-- it's valid, if not ignore it
				if p[ source ].languages[ flag ] then
					-- player has the language, if not ignore it
					if getCurrentLanguage( source ) == flag then
						outputChatBox( "You are currently speaking " .. getLanguageName( flag ) .. ".", source, 0, 255, 0 )
					else
						for key, value in pairs( p[ source ].languages ) do
							if key == flag then
								value.current = true
							else
								value.current = nil
							end
						end
						
						if saveLanguages( source, p[ source ].languages ) then
							triggerClientEvent( source, getResourceName( resource ) .. ":languages", source, p[ source ].languages )
							outputChatBox( "You are now speaking " .. getLanguageName( flag ) .. ".", source, 0, 255, 0 )
						end
					end
				end
			end
		end
	end
)
