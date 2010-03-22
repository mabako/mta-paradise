local function syncTime( )
	local time = getRealTime( )
	setTime( time.hour, time.minute )
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		setMinuteDuration( 60000 )
		syncTime( )
		
		setTimer( syncTime, 300000, 0 ) -- adjust the time every 5 minutes
	end
)