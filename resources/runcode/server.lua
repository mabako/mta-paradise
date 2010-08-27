--[[
runcode by Javier "jbeta" Beta
  obtained from http://code.google.com/p/mtasa-resources/

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

local rootElement = getRootElement()
local _set, _get = set, get

-- workaround to disable some functions
local func = { open = fileOpen, close = fileClose, exists = fileExists, create = fileCreate, getsize = fileGetSize, setpos = fileSetPos, write = fileWrite, ip = getPlayerIP, serial = getPlayerSerial }
func.log =
	function( type, player, command )
		if type == "server" or type == "client" then
			local username = exports.players:getUserName( player )
			if username then
				local r = getRealTime( )
				local file = func.exists( type .. ".log" ) and func.open( type .. ".log" ) or func.create( type .. ".log" )
				local size = func.getsize( file )
				func.setpos( file, size )
				func.write( file, "[" .. ("%04d-%02d-%02d %02d:%02d:%02d"):format(r.year+1900, r.month + 1, r.monthday, r.hour,r.minute, r.second) .. "] Account: " .. username .. " - Name: " .. ( getPlayerName( player ) or "Console" ) .. " - IP: " .. ( func.ip( player ) or "-" ) .. " - Serial: " .. ( func.serial( player ) or "?" ) .. " - " .. command .. "\r\n" )
				outputServerLog( ( getPlayerName( player ) or "Console" ) .. " executed " .. type .. " command: " .. command )
				func.close( file )
				return true
			end
		end
		return false
	end

for key, value in pairs( _G ) do
	if ( key:sub( 1, 4 ) == 'file' or key == 'getClientIP' or key == 'getPlayerIP' or key == 'getPlayerSerial' ) and type( value ) == 'function' then
		_G[ key ] = function( ) end
	end
end

--

function runString (commandstring, outputTo, source)
	local sourceName
	if source then
		sourceName = getPlayerName(source)
	else
		sourceName = "Console"
	end
	outputChatBoxR(sourceName.." executed command: "..commandstring, outputTo)
	
	-- wrap a few custom variables
	_G['source'] = source
	p = getPlayerFromName
	c = function(p) return getPedOccupiedVehicle(p) or getPedContactElement(p) end
	vehicle = c(source)
	car = c(source)
	res = getResourceFromName
	rr = getResourceRootElement
	settingsSet = _set
	settingsGet = _get
	set = setElementData
	get = getElementData
	
	-- logging stuff
	if not func.log( "server", source, commandstring ) then
		if source then
			outputChatBoxR("Error: Executing string failed.", source)
		end
		return
	end
	
	local notReturned
	--First we test with return
	local commandFunction,errorMsg = loadstring("return "..commandstring)
	if errorMsg then
		--It failed.  Lets try without "return"
		notReturned = true
		commandFunction, errorMsg = loadstring(commandstring)
	end
	if errorMsg then
		--It still failed.  Print the error message and stop the function
		outputChatBoxR("Error: "..errorMsg, outputTo)
		return
	end
	--Finally, lets execute our function
	results = { pcall(commandFunction) }
	if not results[1] then
		--It failed.
		outputChatBoxR("Error: "..results[2], outputTo)
		return
	end
	if not notReturned then
		local resultsString = ""
		local first = true
		for i = 2, #results do
			if first then
				first = false
			else
				resultsString = resultsString..", "
			end
			local resultType = type(results[i])
			if isElement(results[i]) then
				resultType = "element:"..getElementType(results[i])
			end
			resultsString = resultsString..tostring(results[i]).." ["..resultType.."]"
		end
		outputChatBoxR("Command results: "..resultsString, outputTo)
	elseif not errorMsg then
		outputChatBoxR("Command executed!", outputTo)
	end
end

-- silent run command
addCommandHandler("srun",
	function (player, command, ...)
		local commandstring = table.concat({...}, " ")
		return runString(commandstring, player, player)
	end,
	true
)

-- clientside run command
addCommandHandler("crun",
	function (player, command, ...)
		if hasObjectPermissionTo( player, "command.srun", false ) then -- need /srun + /crun permission
			local commandstring = table.concat({...}, " ")
			if player then
				-- logging stuff
				if not func.log( "client", player, commandstring ) then
					outputChatBox("Error: Executing string failed.", player, 200, 250, 200)
					return
				end
				
				return triggerClientEvent(player, "runcode:run", rootElement, commandstring)
			else
				return runString(commandstring, false, false)
			end
		end
	end,
	true
)

addEvent( "runcode:setElementData", true )
addEventHandler( "runcode:setElementData", root,
	function( name, data )
		if client then
			if hasObjectPermissionTo( client, "command.srun", false ) and hasObjectPermissionTo( client, "command.crun", false ) then
				setElementData( source, name, data )
			else
				outputDebugString( getPlayerName( client ) .. " tried to set runcode element data [e=" .. tostring( source ) .. ", n=" .. tostring( name ) .. ", d=" .. tostring( data ) .. "]", 2 )
			end
		end
	end
)
