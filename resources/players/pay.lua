addCommandHandler( "pay"
	function( player, commandName, otherPlayer, amount )
		local amount = tonumber( amount )
		if otherPlayer and amount and math.ceil( amount ) == amount and amount > 0 then
			local other, name = exports.players:getFromName( player, otherPlayer )
			if other then
				if player ~= other then
					local x, y, z = getElementPosition( player )
					if getDistanceBetweenPoints3D( x, y, z, getElementPosition( other ) ) < 5 then
						if exports.players:takeMoney( player, amount ) then
							exports.players:giveMoney( other, amount )
							outputChatBox( "You gave " .. name .. " $" .. amount .. ".", player, 0, 255, 0 )
							outputChatBox( getPlayerName( player ):gsub( "_", " " ) .. " gave you $" .. amount .. ".", other, 0, 255, 0 )
						end
					else
						outputChatBox( "You are too far away from " .. name .. ".", player, 255, 0, 0 )
					end
				else
					outputChatBox( "You can't give yourself money.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player] [health]", player, 255, 255, 255 )
		end
	end
)