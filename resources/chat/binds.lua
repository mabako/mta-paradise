-- Bind to toggle the cursor from showing
addCommandHandler( "togglecursor",
	function( )
		showCursor( not isCursorShowing( ) )
	end
)
bindKey( "m", "down", "togglecursor" )

-- Local OOC bind
bindKey( "b", "down", "chatbox", "LocalOOC" )

-- Global OOC bind
bindKey( "o", "down", "chatbox", "GlobalOOC" )