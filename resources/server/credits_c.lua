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

local function showCredits( )
	outputChatBox( " " )
	outputChatBox( "MTA:Paradise " .. getVersion( ), 0, 255, 255 )
	outputChatBox( "  Marcus Bauer <mabako@gmail.com>", 193, 255, 255 )
	outputChatBox( "  Calvin Wong Loi Sing <jumba990@gmail.com>", 193, 255, 255 )
	outputChatBox( " " )
end
addCommandHandler( "credits", showCredits )
addCommandHandler( "about", showCredits )
addCommandHandler( "authors", showCredits )
