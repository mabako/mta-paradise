--[[
Copyright (c) 2010 MTA: Paradise

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
]]

local anims =
{
	sit =
	{
		{ block = "food", anim = "ff_Sit_eat1", time = -1 },
		{ block = "ped", anim = "seat_idle", time = -1 },
		{ block = "beach", anim = "parksit_m_loop", time = -1 },
		{ block = "beach", anim = "parksit_w_loop", time = -1 },
		{ block = "sunbathe", anim = "parksit_m_idlec", time = -1 },
		{ block = "sunbathe", anim = "parksit_w_idlea", time = -1 },
		{ { block = "attractors", anim = "stepsit_in", time = 1200 }, { block = "attractors", anim = "stepsit_loop", time = -1 } },
	},
}

--

-- plays a single animation from a table (see above)
local function setAnim( player, anim )
	-- ignore if the player ain't valid anymore or in a vehicle
	if isElement( player ) and anim and not isPedInVehicle( player ) then
		setPedAnimation( player, anim.block, anim.anim, anim.time or -1, anim.loop == nil and anim.time == -1 or anim.loop or false, anim.updatePosition or false, true )
	end
end

-- play an animation sequence
local function playAnim( player, anim )
	-- time spent on all anims till now
	local time = 0
	
	for key, value in ipairs( anim ) do
		if time == 0 then
			-- first anim, set it directly
			setAnim( player, value )
		else
			-- set the anim delayed
			setTimer( setAnim, time, 1, player, value )
		end
		
		if value.time == -1 then
			-- we got an infinite running anim, no point to check any further
			time = 0
			break
		else
			time = time + value.time
		end
	end
end

--

for key, value in pairs( anims ) do
	addCommandHandler( key,
		function( player, commandName, num )
			if exports.players:isLoggedIn( player ) then
				local anim = tonumber( num ) and value[ tonumber( num ) ] or value[ anim ] or #value == 0 and value or value[ 1 ]
				
				if #anim == 0 then
					anim = { anim }
				end
				
				playAnim( player, anim )
			end
		end
	)
end

--

local function stopAnim( player )
	if exports.players:isLoggedIn( player ) then
		setPedAnimation( player )
	end
end

-- remove a players's animation (equivalent to pressing 'space' on the client)
addCommandHandler( "stopanim", stopAnim )

-- triggered when pressing 'space' as client
addEvent( "anims:reset", true )
addEventHandler( "anims:reset", root,
	function( )
		if client == source then
			stopAnim( source )
		end
	end
)

--

-- runs a user-defined animation by block/name
addCommandHandler( "runanim",
	function( player, commandName, block, anim )
		if exports.players:isLoggedIn( player ) then
			if block and anim then
				setPedAnimation( player, block, anim, -1, false, true, true )
			else
				outputChatBox( "Syntax: /" .. commandName .. " [block] [anim]", player, 255, 255, 255 )
			end
		end
	end
)
