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

local closeButton =
{
	type = "button",
	text = "Close",
	onClick = function( key )
			if key == 1 then
				hide( )
				
				windows.bank_selection = { closeButton }
			end
		end,
}

windows.bank_selection = { closeButton }

function updateBankSelection( accounts, canOpenAccount, canDeposit )
	-- scrap what we had before
	windows.bank_selection = {
		onClose = function( )
				triggerServerEvent( "bank:close", getLocalPlayer( ) )
				windows.bank_selection = { closeButton }
			end,
		{
			type = "label",
			text = "Bank of San Andreas",
			font = "bankgothic",
			alignX = "center",
		},
		{
			type = "pane",
			panes = { }
		}
	}
	
	-- let's add all items
	if #accounts == 0 then
		if canOpenAccount == nil then -- this is an ATM
			table.insert( windows.bank_selection[2].panes,
				{
					image = ":players/images/skins/-1.png",
					title = "No account.",
					text = "You do not have any account.\nHead over to the bank to set one up.",
					wordBreak = true,
				}
			)
		end
	else
		for k, value in ipairs( accounts ) do
			table.insert( windows.bank_selection[2].panes,
				{
					image = ":players/images/skins/-1.png",
					title = "Debit Card",
					text = "You can withdraw " .. ( canDeposit and "and deposit from/to" or "from" ) .. " account #" .. value[2] .. ".",
					onHover = function( cursor, pos )
							dxDrawRectangle( pos[1], pos[2], pos[3] - pos[1], pos[4] - pos[2], tocolor( unpack( { 0, 255, 0, 31 } ) ) )
						end,
					onClick = function( key )
							if key == 1 then
								triggerServerEvent( "bank:select", getLocalPlayer( ), k )
							end
						end,
					wordBreak = true,
				}
			)
		end
	end
	if canOpenAccount == true then -- at the bank, can open another account
		table.insert( windows.bank_selection[2].panes,
			{
				image = ":players/images/skins/-1.png",
				title = "New account",
				text = "Set up a new bank account.",
				onHover = function( cursor, pos )
						dxDrawRectangle( pos[1], pos[2], pos[3] - pos[1], pos[4] - pos[2], tocolor( unpack( { 255, 255, 0, 31 } ) ) )
					end,
				onClick = function( key )
						if key == 1 then
							triggerServerEvent( "bank:select", getLocalPlayer( ), -1 )
						end
					end,
				wordBreak = true,
			}
		)
	end
	
	-- add a close button as well
	table.insert( windows.bank_selection, closeButton )
end

--

local function tryPIN( key )
	if key ~= 2 and destroy and destroy['g:bank:pin'] then
		local pin = tonumber( guiGetText( destroy['g:bank:pin'] ) )
		if pin then
			triggerServerEvent( "bank:select", getLocalPlayer( ), nil, pin )
		end
	end
end

windows.bank_prompt_pin =
{
	onClose = function( )
			triggerServerEvent( "bank:close", getLocalPlayer( ) )
			windows.bank_selection = { closeButton }
		end,
	{
		type = "label",
		text = "Bank of San Andreas",
		font = "bankgothic",
		alignX = "center",
	},
	{
		type = "label",
		text = "You need to enter your PIN before you can continue.",
		alignX = "center",
	},
	{
		type = "edit",
		text = "PIN:",
		id = "g:bank:pin",
		onAccepted = tryPIN,
	},
	{
		type = "button",
		text = "Continue",
		onClick = tryPIN,
	},
	{
		type = "button",
		text = "Cancel",
		onClick = function( ) hide( ) end,
	}
}

--

local _balance = 0

local function deposit( key )
	if key ~= 2 and destroy and destroy['g:bank:amount'] then
		local amount = tonumber( guiGetText( destroy['g:bank:amount'] ) )
		if amount then
			amount = math.ceil( amount )
			if amount <= 0 then
				outputChatBox( "Please enter an amount greater than 0.", 255, 0, 0 )
			elseif amount > getPlayerMoney( ) then
				outputChatBox( "You do not have so much money with you.", 255, 0, 0 )
			else
				triggerServerEvent( "bank:updateaccount", getLocalPlayer( ), amount )
				_balance = _balance + amount
				windows.bank_single[2].text = "Your account balance: $" .. _balance .. "."
			end
		end
	end
end

local function withdraw( key )
	if key ~= 2 and destroy and destroy['g:bank:amount'] then
		local amount = tonumber( guiGetText( destroy['g:bank:amount'] ) )
		if amount then
			amount = math.ceil( amount )
			if amount <= 0 then
				outputChatBox( "Please enter an amount greater than 0.", 255, 0, 0 )
			elseif amount > _balance then
				outputChatBox( "You do not have so much money on your account.", 255, 0, 0 )
			else
				triggerServerEvent( "bank:updateaccount", getLocalPlayer( ), -amount )
				_balance = _balance - amount
				windows.bank_single[2].text = "Your account balance: $" .. _balance .. "."
			end
		end
	end
end

function updateBankSingle( balance, canDeposit )
	_balance = balance
	
	windows.bank_single = {
		onClose = function( )
			triggerServerEvent( "bank:close", getLocalPlayer( ) )
			windows.bank_single = { }
		end,
		{
			type = "label",
			text = "Bank of San Andreas",
			font = "bankgothic",
			alignX = "center",
		},
		{
			type = "label",
			text = "Your account balance: $" .. balance .. ".",
			alignX = "center",
		},
		{
			type = "edit",
			text = "Amount:",
			id = "g:bank:amount",
		},
		{
			type = "button",
			text = "Withdraw",
			onClick = withdraw,
		}
	}
	
	if canDeposit then
		table.insert( windows.bank_single,
			{
				type = "button",
				text = "Deposit",
				onClick = deposit,
			}
		)
	end
	
	table.insert( windows.bank_single,
		{
			type = "button",
			text = "Done",
			onClick = function( ) hide( ) end,
		}
	)
end

windows.bank_single = { }
