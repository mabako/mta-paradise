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

local languages =
{
	{ "Arabic", "ar" },
	{ "Cantonese", "cn" }, -- China
	{ "Dutch", "nl" },
	{ "English", "en" },
	{ "Finnish", "fi" },
	{ "French", "fr" },
	{ "German", "de" },
	{ "Greek", "gr" },
	{ "Hebrew", "il" },
	{ "Hindi", "in" }, -- India, Pakistan
	{ "Italian", "it" },
	{ "Japanese", "jp" },
	{ "Korean", "kr" },
	{ "Mandarin", "ma" }, -- China, Taiwan
	{ "Polish", "pl" },
	{ "Portugese", "pt" },
	{ "Russian", "ru" },
	{ "Spanish", "es" },
	{ "Swedish", "se" },
	{ "Vietnamnese", "vt" },
}

function getLanguageName( tag )
	for key, value in ipairs( languages ) do
		if value[2] == tag then
			return value[1]
		end
	end
	return false
end

function isValidLanguage( tag )
	return getLanguageName( tag ) ~= false
end
