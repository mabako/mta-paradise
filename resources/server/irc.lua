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

-- tricky, tricky. If the module is not loaded, ignore everything
if ircInit then
	-- now let's fetch all irc config we have to take care of
	local config_bots = get( 'irc-bots' )
	
	-- if no irc configuration is available, screw it
	if config_bots then
		local config_channels = get( 'irc-channels' ) -- first channel is our echo channel, rest is meh.
		local config_server = get( 'irc-server' )
		local config_port = tonumber( get( 'irc-port' ) or 6667 )
		local config_nickserv_password = get( 'irc-nickserv-password' )
		
		-- sanity checks
		assert( config_bots and #config_bots > 0 )
		assert( config_channels and #config_channels > 0 )
		assert( config_server and type( config_server ) == "string" and #config_server > 0 )
		assert( config_port and config_port >= 1024 and config_port <= 65535 )
		
		-- initalize IRC
		local bots = { }
		
		-- initalize stuff needed, connect bots, stuff
		addEventHandler( "onResourceStart", resourceRoot,
			function( )
				ircInit( )
				
				for key, value in ipairs( config_bots ) do
					bots[ key ] = ircOpen( config_server, config_port, value, "" )
					if config_nickserv_password then
						setTimer(
							function( )
								ircRaw( bots[ key ], "NS IDENTIFY " .. config_nickserv_password )
								for _, value in ipairs( config_channels ) do
									ircJoin( bots[ key ], value )
								end
							end,
							500,
							1
						)
					end
				end
			end
		)
		
		addEventHandler( "onResourceStop", resourceRoot,
			function( )
				for key, value in ipairs( bots ) do
					ircDisconnect( value )
				end
			end
		)
		
		-- send a message to irc
		function message( message )
			ircMessage( bots[ math.random( 1, #bots ) ], config_channels[1], message:gsub( "%%C", "\003" ):gsub( "%%B", "\002" ) )
		end
		
		-- add some default handlers (a little delayed for anti-spam reasons when starting)
		setTimer(
			function( )
				addEventHandler( "onResourceStart", root,
					function( resource )
						message( "%C04[-!-]%C Resource %B" .. getResourceName( resource ) .. "%B has been started." )
					end
				)
				
				addEventHandler( "onResourceStop", root,
					function( resource )
						message( "%C04[-!-]%C Resource %B" .. getResourceName( resource ) .. "%B has been stopped." )
					end
				)
			end,
			50,
			1
		)
	end
end

if not message then
	-- well, if we don't have anything initalized, let's pretend we have functions
	function message( )
	end
end
