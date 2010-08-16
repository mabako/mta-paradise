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

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		setGameType( "Roleplay" )
		setRuleValue( "author", "mabako, Jumba, Maccer, sun" )
		setRuleValue( "homepage", "http://paradisegaming.net" )
		setRuleValue( "forum", "http://forum.paradisegaming.net" )
		setRuleValue( "license", "GPL Version 3" )
		setRuleValue( "source", "http://github.com/mabako/mta-paradise" )
		setRuleValue( "git-url", "git://github.com/mabako/mta-paradise.git" )
		setRuleValue( "version", getVersion( ) )
		setMapName( "San Fierro" )
		
		setTimer( 
			function( )
				outputServerLog( "              _                                    _ _" )
				outputServerLog( "             | |                                  | (_)" )
				outputServerLog( "    _ __ ___ | |_ __ _   _ __   __ _ _ __ __ _  __| |_ ___  ___" )
				outputServerLog( "   | '_ ` _ \\| __/ _` | | '_ \\ / _` | '__/ _` |/ _` | / __|/ _ \\" )
				outputServerLog( "   | | | | | | || (_| | | |_) | (_| | | | (_| | (_| | \\__ \\  __/" )
				outputServerLog( "   |_| |_| |_|\\__\\__,_| | .__/ \\__,_|_|  \\__,_|\\__,_|_|___/\\___|" )
				outputServerLog( "                        | |" )
				outputServerLog( "                        |_| v" .. getVersion( ) )
			end, 50, 1
		)
	end
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		removeRuleValue( "author" )
		removeRuleValue( "homepage" )
		removeRuleValue( "forum" )
		removeRuleValue( "license" )
		removeRuleValue( "source" )
		removeRuleValue( "git-url" )
		removeRuleValue( "version" )
	end
)
