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

-- we don't want our shops to die, do we?
addEventHandler( "onClientPedDamage", resourceRoot, cancelEvent )

--

addEvent( "bank:open", true )
addEventHandler( "bank:open", resourceRoot,
	function( accounts, canOpenAccount, canDeposit )
		exports.gui:hide( )
		exports.gui:updateBankSelection( accounts, canOpenAccount, canDeposit )
		exports.gui:show( 'bank_selection' )
	end
)

addEvent( "bank:promptPIN", true )
addEventHandler( "bank:promptPIN", resourceRoot,
	function( )
		exports.gui:show( 'bank_prompt_pin', true )
	end
)

addEvent( "bank:single", true )
addEventHandler( "bank:single", resourceRoot,
	function( balance, canDeposit, withdrawFee )
		exports.gui:hide( )
		exports.gui:updateBankSingle( balance, canDeposit, withdrawFee )
		exports.gui:show( 'bank_single', true )
	end
)
