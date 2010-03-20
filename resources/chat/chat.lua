-- getPlayerName with spaces instead of _ for player names
local _getPlayerName = getPlayerName
local getPlayerName = function( x ) return _getPlayerName( x ):gsub( "_", " " ) end

-- addCommandHandler supporting arrays as command names (multiple commands with the same function)
local _addCommandHandler = addCommandHandler
local addCommandHandler = function( a, ... ) if type( a ) ~= "table" then a = { a } end for _, value in ipairs( a ) do addCommandHandler( value, ... ) end end

-- returns all players within <range> units away <from>
local function getPlayersInRange( from, range )
	local x, y, z = getElementPosition( from )
	local dimension = getElementDimension( from )
	local interior = getElementInterior( from )
	
	local t = { }
	for key, value in ipairs( getElementsByType( "player" ) ) do
		if getElementDimension( value ) == dimension and getElementInterior( value ) == interior then
			local distance = getDistanceBetweenPoints3D( x, y, z, getElementPosition( value ) )
			if distance < range then
				t[ value ] = range
			end
		end
	end
	return t
end

-- sends a ranged message
local function localMessage( from, message, r, g, b, range, r2, g2, b2 )
	range = range or 20
	r2 = r2 or r
	g2 = g2 or g
	b2 = b2 or b
	
	for player, distance in pairs( getPlayersInRange( from, range ) ) do
		outputChatBox( message, player, r2 + ( r - r2 ) * 1 - ( distance / range ), g2 + ( g - g2 ) * 1 - ( distance / range ), b2 + ( b - b2 ) * 1 - ( distance / range ) )
	end
end

-- overwrite MTA's default chat events
addEventHandler( "onPlayerChat", getRootElement( ),
	function( message, type )
		cancelEvent( )
		if exports.players:isLoggedIn( source ) then
			if type == 0 then
				localMessage( source, " " .. getPlayerName( source ) .. " says: " .. message, 230, 230, 230, false, 127, 127, 127 )
			elseif type == 1 then
				localMessage( source, " *" .. getPlayerName( source ) .. " " .. message, 255, 40, 80 )
			end
		end
	end
)

-- /do
addCommandHandler( "do", 
	function( thePlayer, commandName, ... )
		if exports.players:isLoggedIn( thePlayer ) then
			local message = table.concat( { ... }, " " )
			if #message > 0 then
				localMessage( thePlayer, " *" .. message .. " ((" .. getPlayerName( thePlayer ) .. "))", 255, 40, 80 )
			else
				outputChatBox( "Syntax: /" .. commandName .. " [in character text]", thePlayer, 255, 255, 255 )
			end
		end
	end
)

-- /b; bound to 'b' client-side
addCommandHandler( { "b", "LocalOOC" },
	function( thePlayer, commandName, ... )
		if exports.players:isLoggedIn( thePlayer ) then
			local message = table.concat( { ... }, " " )
			if #message > 0 then
				localMessage( thePlayer, getPlayerName( thePlayer ) ..  ": (( " .. message .. " ))", 196, 255, 255 )
			else
				outputChatBox( "Syntax: /" .. commandName .. " [local ooc text]", thePlayer, 255, 255, 255 )
			end
		end
	end
)

-- /o; bound to 'o' client-side
addCommandHandler( { "o", "GlobalOOC" },
	function( thePlayer, commandName, ... )
		if exports.players:isLoggedIn( thePlayer ) then
			local message = table.concat( { ... }, " " )
			if #message > 0 then
				outputChatBox( "(( " .. getPlayerName( thePlayer ) ..  ": " .. message .. " ))", root, 196, 255, 255 )
			else
				outputChatBox( "Syntax: /" .. commandName .. " [local ooc text]", thePlayer, 255, 255, 255 )
			end
		end
	end
)

-- /pm to message other players
local function pm( player, target, message )
	outputChatBox( "PM to " .. getPlayerName( target ) .. ": " .. message, player, 255, 255, 0 )
	outputChatBox( "PM from " .. getPlayerName( player ) .. ": " .. message, target, 255, 255, 0 )
end

addCommandHandler( "pm",
	function( thePlayer, commandName, otherPlayer, ... )
		if exports.players:isLoggedIn( thePlayer ) then
			if otherPlayer and ( ... ) then
				local message = table.concat( { ... }, " " )
				local player, name = exports.players:getFromName( thePlayer, otherPlayer )
				if player then
					pm( thePlayer, player, message )
				end
			else
				outputChatBox( "Syntax: /" .. commandName .. " [player] [ooc text]", thePlayer, 255, 255, 255 )
			end
		end
	end
)

addEventHandler( "onPlayerPrivateMessage", root,
	function( message, recipient )
		if exports.players:isLoggedIn( thePlayer ) and exports.players:isLoggedIn( recipient ) then
			pm( source, recipient, message )
		end
		cancelEvent( )
	end
)