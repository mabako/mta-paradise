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

local texts =
{
	{ "Welcome", "Welcome to Optical-Gaming Roleplay - let us just introduce the server, it won't take long!", 1 },
	{ "The Rules", "You can access the rules at any time by just pressing 'F1', we recommend you to look at it as soon as possible to avoid any problems.", 2 },
	{ "The Setting", "This server is set in Las Venturas surrounded by a few small towns in the Desert. The current year is " .. ( getRealTime().year ) .. " - present time.", 1 },
	{ "Vehicles", "A number of freely accessible Vehicles (Civilian, as they do not have an owner) is placed around the city, you can buy your own Vehicle at any time.", 1 },
	{ "Legal Jobs", "Okay, everyone wants to make some money. A good idea to get started is to get a Job from City Hall. Press 'F11', see the Yellow Marker.", 1 },
	{ "Factions I", "There's a few factions around town, the most important one being the Police Department, among that a handful of legal and illegal ones.", 1 }, 
	{ "Factions II", "If you're interested to roleplay with and eventually in a faction, have a look at their forum for more details.", 1 },
	{ "The End", "Now though that wasn't much, that's the end of our few tips. If you have any remaining questions or want to contact an admin, press 'F2' or type /report.", 1 },
}

function tutorial( )
	for key, value in ipairs( texts ) do
		setTimer( function( ... ) exports.gui:hint( ... ) end, 50 + 7000 * ( key - 1 ), 1, unpack( value ) )
	end
end

addCommandHandler( "tut", tutorial )
