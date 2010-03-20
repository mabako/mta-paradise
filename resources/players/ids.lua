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
			match = getNameMatch ( targetName ) -- returns a table.
		end
		
		-- TODO: Search by partial name || Done - Jumba.
		
		if #match == 1 then
			if isLoggedIn( match[ 1 ] ) then
				outputChatBox ( getPlayerName ( match[1] ) ) 
				return match[ 1 ], getPlayerName( match[ 1 ] ):gsub( "_", " " ), getElementData( match[ 1 ], "playerid" )
			else
				-- not logged in error
				return nil
			end
		elseif #match == 0 then
			return nil -- no player
		else
			outputChatBox ( "Players matching your search are: ", player, 255, 255, 0 )
			for _, player in ipairs ( match ) do
				outputChatBox ( getPlayerName ( player ):gsub ( "_", " " ) .. " (" .. getElementData ( player, "playerid" ) .. ")", player, 245, 200, 0 )
			end	
			return nil -- more than one player. We list the player names + id.
		end
	end
end

function getNameMatch( targetName )
local matches = { }
	if ( targetName ) then
		for k, player in ipairs ( getElementsByType ( "player" ) ) do
			local player_n = getPlayerName ( player ):lower()
			local match = player_n:find( targetName:lower() )
			if ( match ) then
				if isLoggedIn ( player ) then
					matches[ #matches + 1 ] = player
				end
			end
		end
		return matches	
	end	
end