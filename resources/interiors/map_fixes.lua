function createObject2( model, x, y, z, rx, ry, rz, interior )
	local object = createObject( model, x, y, z, rx, ry, rz )
	setElementAlpha( object, 0 )
	setElementInterior( object, interior )
	
	local colShape = createColSphere( x,y,z,100)
	addEventHandler( "onClientColShapeHit", colShape,
		function( element )
			if element == getLocalPlayer( ) then
				if getElementInterior( element ) == interior then
					setElementDimension( t, getElementDimension( element ) )
				else
					setElementDimension( t, getElementDimension( element ) + 1 )
				end
			end
		end
	)
end

createObject2(8171,9.66,-27.4,1002.5,0,90,0,10) -- fix for a 24/7 wall that can be walked through
