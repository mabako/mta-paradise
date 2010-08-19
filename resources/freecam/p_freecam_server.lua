--[[
freecam by Ed "eAi" Lyons, QA Team
  obtained from http://code.google.com/p/mtasa-resources/

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

local p = { }

function setPlayerFreecamEnabled(player, x, y, z, dontChangeFixedMode)
	if not isPlayerFreecamEnabled( player ) then
		p[ player ] = true
		setElementData(player, "collisionless", true)
		setElementAlpha(player, 0)
		return triggerClientEvent(player,"doSetFreecamEnabled", getRootElement(), x, y, z, dontChangeFixedMode)
	end
	return false
end


function setPlayerFreecamDisabled(player, dontChangeFixedMode)
	if isPlayerFreecamEnabled( player ) then
		p[ player ] = nil
		removeElementData(player, "collisionless")
		setElementAlpha(player, 255)
		return triggerClientEvent(player,"doSetFreecamDisabled", getRootElement(), dontChangeFixedMode)
	end
	return false
end


function setPlayerFreecamOption(player, theOption, value)
	return triggerClientEvent(player,"doSetFreecamOption", getRootElement(), theOption, value)
end


function isPlayerFreecamEnabled(player)
	return p[ player ]
end

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		for player in pairs( p ) do
			removeElementData(player, "collisionless")
			setElementAlpha(player, 255)
		end
	end
)
