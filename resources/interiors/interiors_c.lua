addEventHandler( "onClientRender", getRootElement( ),
	function( )
		-- get the camera matrix
		local cx, cy, cz = getCameraMatrix( )
		
		-- loop through all vehicles you can buy
		local dimension = getElementDimension( getLocalPlayer( ) )
		for key, colshape in ipairs ( getElementsByType( "colshape", resourceRoot ) ) do
			if isElement( colshape ) and getElementDimension( colshape ) == dimension and getElementData( colshape, "name" ) then
				local px, py, pz = getElementPosition( colshape )
				local distance = getDistanceBetweenPoints3D( px, py, pz, cx, cy, cz )
				if distance < 10 and isLineOfSightClear( cx, cy, cz, px, py, pz, true, true, true, true, false, false, true, colshape ) then
					local sx, sy = getScreenFromWorldPosition( px, py, pz )
					if sx and sy then
						-- name
						local text = getElementData( colshape, "name" )
						
						-- background
						local width = dxGetTextWidth( text )
						local height = dxGetFontHeight( )
						dxDrawRectangle( sx - width / 2 - 5, sy - height / 2 - 5, width + 10, height + 10, tocolor( 0, 0, 0, 200 ) )
						
						-- text
						dxDrawText( text, sx, sy, sx, sy, tocolor( 255, 255, 255, 255 ), 1, "default", "center", "center" )
					end
				end
			end
		end
	end
)