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

addEventHandler( "onPlayerDamage", root,
	function( attacker, weapon, bodypart, loss )
		if attacker then
			if bodypart == 9 and weapon >= 22 and weapon <= 38 then
				-- headshot
				setPedHeadless( source, true )
				killPed( source, attacker, weapon, bodypart )
			end
		end
	end
)

addEventHandler( "onPlayerSpawn", root,
	function( )
		if isPedHeadless( source ) then
			setPedHeadless( source, false )
		end
	end
)
