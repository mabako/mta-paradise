local ids = { }

addEventHandler( "onPlayerJoin", root,
	function( )
		for i = 1, getMaxPlayers( ) do
			if not ids[ i ] then
				ids[ i ] = source
				setElementData( source, "playerid", i )
				break
			end
		end
	end
)

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		for i, source in ipairs( getElementsByType( "player" ) ) do
			ids[ i ] = source
			setElementData( source, "playerid", i )
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		for i = 1, getMaxPlayers( ) do
			if ids[ i ] == source then
				ids[ i ] = nil
				break
			end
		end
	end
)

local getElementsByType = function( ) return { getRandomPlayer( ), getRandomPlayer( ), getRandomPlayer( ) } end
function getFromName( player, targetName )
	if targetName then
		targetName = tostring( targetName )
		
		local match = { }
		if targetName == "*" then
			match = { player }
		elseif tonumber( targetName ) then
			match = { ids[ tonumber( targetName ) ] }
		elseif ( getPlayerFromName ( targetName ) ) then
			match = { getPlayerFromName ( targetName ) }
		else	
			for key, value in ipairs ( getElementsByType ( "player" ) ) do
				if getPlayerName ( player ):lower():find( targetName:lower() ) then
					match[ #match + 1 ] = player
				end
			end
		end
		
		if #match == 1 then
			if isLoggedIn( match[ 1 ] ) then
				return match[ 1 ], getPlayerName( match[ 1 ] ):gsub( "_", " " ), getElementData( match[ 1 ], "playerid" )
			else
				outputChatBox( getPlayerName( match[ 1 ] ):gsub( "_", " " ) .. " is not logged in.", player, 255, 0, 0 )
				return nil -- not logged in error
			end
		elseif #match == 0 then
			outputChatBox( "No player matches your search.", player, 255, 0, 0 )
			return nil -- no player
		elseif #match > 10 then
			outputChatBox( #match .. " players match your search.", player, 255, 204, 0 )
		else
			outputChatBox ( "Players matching your search are: ", player, 255, 204, 0 )
			for key, value in ipairs( match ) do
				outputChatBox( "  (" .. getElementData( value, "playerid" ) .. ") " .. getPlayerName( value ):gsub ( "_", " " ), player, 255, 255, 0 )
			end	
			return nil -- more than one player. We list the player names + id.
		end
	end
end

addCommandHandler( "id",
	function( player, commandName, target )
		if isLoggedIn( player ) then
			local target, targetName, id = getFromName( player, target )
			if target then
				outputChatBox( targetName .. "'s ID is " .. id .. ".", player, 255, 204, 0 )
			end
		end
	end
)