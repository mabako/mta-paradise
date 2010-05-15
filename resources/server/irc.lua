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
if sockOpen then
	-- now let's fetch all irc config we have to take care of
	local config_bots = get( 'irc-bots' )
	
	-- if no irc configuration is available, screw it
	if config_bots then
		local bots = { }
		
		local function ircRaw( bot, message )
			assert( type( bot ) == "table" and bot.socket ) -- bad, bad, didn't pass a valid bot.
			sockWrite( bot.socket, message .. "\r\n" )
		end
		
		local function ircConnect( server, port, nickname, connectedCommands )
			assert( server )
			assert( port )
			assert( nickname )
			
			if type( connectedCommands ) ~= "table" then
				connectedCommands = { }
			end
			
			table.insert( connectedCommands, 1, "USER " .. nickname .. " * * :MTA: Paradise " .. getVersion( ) )
			table.insert( connectedCommands, 2, "NICK " .. nickname ) -- handle nick in use errors. some time.
			
			-- save the bot
			table.insert( bots, { socket = sockOpen( server, port ), connected = false, queue = connectedCommands } )
		end
		
		local function ircDisconnect( bot )
			assert( type( bot ) == "table" and bot.socket ) -- bad, bad, still didn't pass a bot
			if bot.connected then
				ircRaw( bot, "QUIT :MTA Paradise " .. getVersion( ) )
			end
			sockClose( bot.socket )
			bot.socket = nil
			bot.connected = nil
		end
		
		local function ircMessage( bot, channel, message )
			-- if no bot is given, chose a random time
			if not bot then
				local connected = { }
				for key, value in pairs( bots ) do
					if value.connected then
						table.insert( connected, value )
					end
				end
				
				if #connected == 0 then
					return
				else
					bot = connected[ math.random( 1, #connected ) ]
				end
			else
				assert( type( bot ) == "table" and bot.socket )
			end
			
			ircRaw( bot, "PRIVMSG " .. channel .. " :" .. message )
		end
		
		addEventHandler( "onSockOpened", resourceRoot,
			function( socket )
				for key, value in pairs( bots ) do
					if value.socket == socket then
						value.connected = true
						
						-- spam dozens
						for _, command in ipairs( value.queue ) do
							ircRaw( value, command )
						end
						break
					end
				end
			end
		)
		
		--
		
		local config_channels = get( 'irc-channels' ) -- first channel is our echo channel, rest is meh.
		local config_server = get( 'irc-server' )
		local config_port = tonumber( get( 'irc-port' ) or 6667 )
		local config_nickserv_password = get( 'irc-nickserv-password' )
		
		-- sanity checks
		assert( config_bots and #config_bots > 0 )
		assert( config_channels and #config_channels > 0 )
		assert( config_server and type( config_server ) == "string" and #config_server > 0 )
		assert( config_port and config_port >= 1024 and config_port <= 65535 )
		
		-- do this cause we want to stay connected
		local function trim( str )
			return str:gsub("^%s*(.-)%s*$", "%1")
		end

		addEventHandler( "onSockData", resourceRoot,
			function( socket, chunk )
				-- if interested parse more data.
				if chunk:sub( 1, 4 ) == "PING" then
					sockWrite( socket, "PONG" .. chunk:sub( 5 ) .. "\r\n" )
				else
					chunk = chunk:sub( 2 )
					local parts = split( chunk, 32 ) -- split at ' '
					if #parts >= 4 then
						if parts[2] == "PRIVMSG" and parts[3]:lower() == config_channels[1]:lower() then
							-- get the name part
							local name = split( parts[1], string.byte( '!' ) )[1]
							
							-- get the message: first 3 parts are name, command, target
							for i = 1, 3 do
								table.remove( parts, 1 )
							end
							parts[1] = parts[1]:sub( 2 ) -- message starts with :
							local message = trim( table.concat( parts, " " ):gsub( "\003%d%d", "" ):gsub( "\003%d", "" ):gsub( "\002", "" ) ) -- strip some formatting
							
							-- finally send it.
							outputChatBox( "(( " .. name .. " @ IRC: " .. message .. " ))", root, 196, 255, 255 )
						end
					end
				end
			end
		)
		
		-- initalize stuff needed, connect bots, stuff
		addEventHandler( "onResourceStart", resourceRoot,
			function( )
				for key, value in ipairs( config_bots ) do
					local connectedCommands = { }
					if config_nickserv_password then
						table.insert( connectedCommands, "NS IDENTIFY " .. config_nickserv_password )
					end
					
					for key, value in ipairs( config_channels ) do
						table.insert( connectedCommands, "JOIN " .. value )
					end
					
					ircConnect( config_server, config_port, value, connectedCommands )
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
			ircMessage( nil, config_channels[1], message:gsub( "%%C", "\003" ):gsub( "%%B", "\002" ) )
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
