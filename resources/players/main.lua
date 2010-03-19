local function showLoginScreen( player )
	-- hide the current view (will be faded in client-side)
	fadeCamera( player, false, 0 )
	toggleAllControls( player, false, true, false )
	
	-- spawn the player etc.
	spawnPlayer( source, 2000.6, 1577.6, 16.5 )
	setPedFrozen( source, true )
	setElementAlpha( source, 0 )
	
	setElementInterior( source, 0 )
	setCameraInterior( source, 0 )
	setElementDimension( source, 1 )
	
	setCameraMatrix( source, 1999.8, 1580.95, 17.6, 2000, 1580, 17.5 )
	
	triggerClientEvent( player, getResourceName( resource ) .. ":spawnscreen", player, get( 'registration_error' ) )
end

addEvent( getResourceName( resource ) .. ":ready", true )
addEventHandler( getResourceName( resource ) .. ":ready", root,
	function( )
		if source == client then
			showLoginScreen( source )
		end
	end
)

addEvent( getResourceName( resource ) .. ":login", true )
addEventHandler( getResourceName( resource ) .. ":login", root,
	function( username, password )
		if source == client then
			if username and password and #username > 0 and #password > 0 then
				local info = exports.sql:query_assoc_single( "SELECT userID, banned, activationCode FROM wcf1_user WHERE `username` = '%s' AND password = SHA1(CONCAT(salt, SHA1(CONCAT(salt, SHA1('%s'))))) LIMIT 1", username, password )
				
				if not info then
					triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 1 ) -- Wrong username/password
				else
					if info.banned == 1 then
						triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 2 ) -- Banned
					elseif info.activationCode > 0 then
						triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 3 ) -- Requires activation
					else
						triggerClientEvent( source, getResourceName( resource ) .. ":loginResult", source, 4 )
						-- login successful, do something!
					end
				end
			end
		end
	end
)