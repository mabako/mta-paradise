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

function streamIn( p )
	if p ~= getLocalPlayer( ) then
		return
	end
	
	local col = getElementData( source, 'collision' )
	local model = getElementData( source, 'model' )
	engineReplaceCOL( col, model )
end

function addColStream( col, model, x, y, z )
	local cs = createColSphere( x, y, z, 200 )
	setElementData( cs, 'collision', col )
	setElementData( cs, 'model', model )
	addEventHandler( 'onClientColShapeHit', cs, streamIn )
end

addEventHandler( 'onClientResourceStart', resourceRoot,
	function( )
		addColStream( engineLoadCOL( 'col/ggbrig_07_sfw.col' ), 9683, -2681.49, 1384.66, 33.2969 )
		addColStream( engineLoadCOL( 'col/ggbrig_02_sfw.col' ), 9685, -2681.49, 1529.11, 112.789 )
		addColStream( engineLoadCOL( 'col/ggbrig_05_sfw.col' ), 9689, -2681.49, 1684.46, 120.453 )
		addColStream( engineLoadCOL( 'col/ggbrig_03_sfw.col' ), 9693, -2681.49, 1847.93, 120.085 )
		addColStream( engineLoadCOL( 'col/ggbrig_04_sfw.col' ), 9696, -2681.49, 2042.15, 86.7187 )
	end
)

addEventHandler( 'onClientResourceStop', resourceRoot,
	function( )
		engineRestoreCOL( 9683 )
		engineRestoreCOL( 9685 )
		engineRestoreCOL( 9689 )
		engineRestoreCOL( 9693 )
		engineRestoreCOL( 9696 )
	end
)