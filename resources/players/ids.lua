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
		if tonumber( targetName ) then
			match = { ids[ tonumber( targetName ) ] }
		elseif getPlayerFromName( targetName ) then
			match = { getPlayerFromName( targetName ) }
		end
		
		-- TODO: Search by partial name
		
		if #match == 1 then
			if isLoggedIn( match[ 1 ] ) then
				return match[ 1 ], getPlayerName( match[ 1 ] ):gsub( "_", " " ), getElementData( match[ 1 ], "playerid" )
			else
				-- not logged in error
				return nil
			end
		elseif #match == 0 then
			return nil -- no player
		else
			return nil -- show a list of players
		end
	end
end