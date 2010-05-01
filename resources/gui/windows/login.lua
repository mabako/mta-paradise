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

setTimer(
	function( )
		local messageTimer
		local messageCount = 0
		local function setMessage( text )
			windows.login[#windows.login].text = text
			if messageTimer then
				killTimer( messageTimer )
			end
			messageCount = 0
			setTimer(
				function()
					messageCount = messageCount + 1
					if messageCount == 50 then
						windows.login[#windows.login].text = ""
						messageTimer = nil
					else
						windows.login[#windows.login].color = { 255, 255, 255, 5 * ( 50 - messageCount ) }
					end
				end, 100, 50
			)
		end

		local function tryLogin( key )
			if key ~= 2 and destroy and destroy['g:login:username'] and destroy['g:login:password'] then
				local u = guiGetText( destroy['g:login:username'] )
				local p = guiGetText( destroy['g:login:password'] )
				if u and p then
					if #u == 0 then
						setMessage( "Please enter a username." )
					elseif #p == 0 then
						setMessage( "Please enter a password." )
					else
						triggerServerEvent( "players:login", getLocalPlayer( ), u, p )
					end
				end
			end
		end

		windows.login =
		{
			{
				type = "label",
				text = "Welcome!",
				font = "bankgothic",
				alignX = "center",
			},
			{
				type = "label",
				text = "You need an account to play on this server.\nIf you already have an account, please login.",
				alignX = "center",
			},
			{
				type = "label",
				text = getElementData( getResourceRootElement( getResourceFromName( "players" ) ), "allowRegistration" ) and "Alternatively, you may register below." or getElementData( getResourceRootElement( getResourceFromName( "players" ) ), "registrationErrorMessage" ) or "Registration is currently disabled.",
				alignX = "center",
			},
			{
				type = "edit",
				text = "Username:",
				id = "g:login:username",
				onAccepted = tryLogin,
			},
			{
				type = "edit",
				text = "Password:",
				id = "g:login:password",
				masked = true,
				onAccepted = tryLogin,
			},
			{
				type = "button",
				text = "Login",
				onClick = tryLogin,
			}
		}

		if getElementData( getResourceRootElement( getResourceFromName( "players" ) ), "allowRegistration" ) then
			table.insert( windows.login,
				{
					type = "button",
					text = "Register",
					onClick = function( key )
							if key == 1 and destroy and destroy['g:login:username'] and destroy['g:login:password'] then
								local u = guiGetText( destroy['g:login:username'] )
								local p = guiGetText( destroy['g:login:password'] )
								if u and p then
									if #u < 3 then
										setMessage( "Your username needs to be at least 3 chars." )
									elseif #p < 8 then
										setMessage( "Your password needs to be at least 8 chars." )
									else
										triggerServerEvent( "players:register", getLocalPlayer( ), u, p )
									end
								end
							end
						end
				}
			)
		end

		table.insert( windows.login, { type = "label", text = "", alignX = "center" } )

		addEvent( "players:loginResult", true )
		addEventHandler( "players:loginResult", getLocalPlayer( ),
			function( code )
				if code == 1 then
					setMessage( "Wrong username or password." )
				elseif code == 2 then
					show( 'banned', true )
				elseif code == 3 then
					show( 'activation_required', true )
				elseif code == 4 then
					setMessage( "Unknown Error." )
				elseif code == 5 then
					setMessage( "Another user is currently\nlogged in under that account." )
				end
			end
		)

		addEvent( "players:registrationResult", true )
		addEventHandler( "players:registrationResult", getLocalPlayer( ),
			function( code, message )
				if code == 0 then
					tryLogin( )
				elseif code == 1 then
					setMessage( "Try later." )
				elseif code == 2 then
					setMessage( "Registration is disabled." )
				elseif code == 3 then
					setMessage( "This username already exists." )
				end
			end
		)

		windows.banned =
		{
			type = "label",
			text = "You are banned.",
			font = "bankgothic",
			color = { 255, 0, 0, 255 },
			alignX = "center",
		}

		windows.activation_required =
		{
			type = "label",
			text = "Please activate\nyour account.",
			font = "bankgothic",
			alignX = "center",
		}
	end,
	100,
	1
)