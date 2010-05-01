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

windows.scoreboard =
{
	{
		type = "grid",
		columns =
		{
			{ name = "ID", width = 0.1, alignX = "center" },
			{ name = "Name", width = 0.7 },
			{ name = "Ping", width = 0.2, alignX = "center" }
		},
		content = function( )
				local t = { }
				for key, value in ipairs( getElementsByType( "player" ) ) do
					local name = getPlayerName( value )
					table.insert( t,
						{
							getElementData( value, "playerid" ),
							name and name:gsub( "_", " " ),
							getPlayerPing( value ),
							color = { getPlayerNametagColor( value ) },
						}
					)
				end
				table.sort( t, function( a, b ) return a[1] < b[1] end )
				return t
			end
	}
}
