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

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		for key, value in ipairs( getElementsByType( "player" ) ) do
			if exports.players:isLoggedIn( value ) then
				setPlayerBlurLevel( value, exports.players:getOption( value, "blur" ) and 38 or 0 )
			end
		end
	end
)

addEventHandler( "onCharacterLogin", root,
	function( )
		setPlayerBlurLevel( source, exports.players:getOption( source, "blur" ) and 38 or 0 )
	end
)

addCommandHandler( "toggleblur",
	function( player )
		local blur = exports.players:getOption( player, "blur" ) ~= true and true or nil
		if exports.players:setOption( player, "blur", blur ) then
			outputChatBox( "Blur is " .. ( blur and "en" or "dis" ) .. "abled.", player, 0, 255, 0 )
			setPlayerBlurLevel( player, blur and 38 or 0 )
		end
	end
)
