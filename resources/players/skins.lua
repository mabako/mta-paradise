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

local skins =
{
	male = { 
		black = { 0, 7, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 25, 28, 51, 66, 67, 79, 80, 83, 84, 102, 103, 104, 105, 106, 107, 134, 136, 142, 143, 144, 156, 163, 166, 168, 176, 180, 182, 183, 185, 220, 221, 222, 249, 253, 260, 262 },
		white = { 23, 26, 27, 29, 30, 32, 33, 34, 35, 36, 37, 43, 44, 45, 46, 47, 48, 49, 50, 52, 57, 58, 59, 60, 61, 62, 68, 70, 71, 72, 73, 78, 81, 82, 94, 95, 96, 97, 98, 99, 100, 101, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 120, 121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 135, 137, 146, 147, 153, 154, 155, 158, 159, 160, 161, 162, 164, 165, 167, 170, 171, 172, 173, 174, 175, 177, 179, 181, 184, 186, 187, 188, 189, 200, 202, 203, 204, 206, 209, 210, 212, 213, 217, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 247, 248, 250, 252, 254, 255, 258, 259, 261, 264 }
	},
	female =
	{
		black = { 9, 10, 11, 13, 63, 69, 76, 139, 148, 190, 195, 207, 215, 218, 219, 238, 244, 245, 256, },
		white = { 12, 31, 38, 39, 40, 41, 53, 54, 55, 56, 64, 75, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 140, 141, 145, 150, 151, 152, 157, 169, 178, 191, 192, 193, 194, 196, 197, 198, 199, 201, 205, 211, 214, 216, 224, 225, 226, 231, 232, 233, 237, 243, 246, 251, 257, 263 }
	}
}

local skins_ = { }
local skins__ = { }
for k, v in pairs( skins ) do
	for k2, v2 in pairs( v ) do
		for _, skin in ipairs( v2 ) do
			table.insert( skins_, skin )
			skins__[ skin ] = { gender = k, color = k2 }
		end
	end
end
table.sort( skins_ )

function getSkins( )
	return skins_
end

function isValidSkin( skin )
	return skin and skins__[ skin ] and true or false
end

function getSkinDetails( skin )
	return isValidSkin( skin ) and skins__[ skin ]
end
