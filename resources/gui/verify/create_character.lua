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

function verifyCharacterName( name )
	if not name then
		return "No name given."
	elseif #name < 5 then
		return "Name must be at least 5 chars."
	elseif #name >= 22 then
		return "Name must be at most 22 chars."
	else
		local foundSpace = false
		
		local lastChar = ' '
		local currentPart = ''
		
		for i = 1, #name do
			local currentChar = name:sub( i, i )
			if currentChar == ' ' then
				if i == 1 then
					return "Your name can't start with a space."
				elseif i == #name then
					return "Your name can't end with a space."
				elseif lastChar == ' ' then
					return "Your name has two following space chars."
				else
					foundSpace = true
					
					if #currentPart < 2 then
						return "All name-parts must be at least two chars."
					else
						currentPart = ""
					end
				end
			elseif lastChar == ' ' then -- need a capital letter at the start
				if currentChar < 'A' or currentChar > 'Z' then
					return "Invalid Name - Format: Firstname Lastname."
				end
				currentPart = currentPart .. currentChar
			elseif ( currentChar >= 'a' and currentChar <= 'z' ) or ( currentChar >= 'A' and currentChar <= 'Z' ) then
				currentPart = currentPart .. currentChar
			else
				return "Your name contains invalid characters."
			end
			lastChar = currentChar
		end
		
		if not foundSpace then
			return "Your name must have at least two parts."
		elseif #currentPart < 2 then
			return "All name-parts must be at least two chars."
		end
	end
end

function verifySkin( skin )
	if not skin then
		return "No Skin set."
	elseif not exports.players:isValidSkin( skin ) then
		return "Skin is invalid."
	end
end
