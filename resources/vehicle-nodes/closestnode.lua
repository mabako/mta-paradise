-- based 'traffic' by lil_toady and Flobu
-- from http://flobu.fl.funpic.de/MTA/traffic.rar

local function getAreaFromPos ( x, y, z )
	x = x + 3000
	y = y + 3000
	if ( ( 0 < x and x < 6000 ) and ( 0 < y and y < 6000 ) ) then
		return math.floor ( y / 375 ) * ( 6000 / 375 ) + math.floor ( x / 375 )
	end
	return false
end

local function pathsNodeFindClosest ( x, y, z )
	local areaID = getAreaFromPos ( x, y, z )
	local minDist, minNode
	local nodeX, nodeY, dist
	for id,node in pairs( AREA_PATHS[areaID] ) do
		nodeX, nodeY = node[1], node[2]
		dist = (x - nodeX)*(x - nodeX) + (y - nodeY)*(y - nodeY)
		if not minDist or dist < minDist then
			minDist = dist
			minNode = node
		end
	end
	return minNode
end

function findClosest( ... )
	return unpack( pathsNodeFindClosest( ... ) )
end
