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

local xmlFile = nil
local xmlNode = nil
local yearday, hour

--

local function openFile( )
	local time = getRealTime( )
	yearday = time.yearday
	hour = time.hour
	local fileName = ( "%04d-%02d-%02d/%02d.html" ):format( time.year + 1900, time.month + 1, time.monthday, time.hour )
	
	xmlFile = xmlLoadFile( fileName )
	if not xmlFile then
		-- create the basic layout
		xmlFile = xmlCreateFile( fileName, "html" )
		local head = xmlCreateChild( xmlFile, "head" )
		local title = xmlCreateChild( head, "title" )
		xmlNodeSetValue( title, ( "Optical-Gaming: Roleplay :: %04d-%02d-%02d" ):format( time.year + 1900, time.month + 1, time.monthday ) )
		
		local style = xmlCreateChild( head, "style" )
		xmlNodeSetAttribute( style, "type", "text/css" )
		xmlNodeSetValue( style, "body { font-family: Tahoma; font-size: 0.8em; background: #000000; }  p { padding: 0; margin: 0; } .v1 { color: #AAAAAA; } .v2 { color: #DDDDDD; } .v3 { white-space:pre; }" )
		
		--
		
		xmlNode = xmlCreateChild( xmlFile, "body" )
		xmlSaveFile( xmlFile )
	else
		xmlNode = xmlFindChild( xmlFile, "body", 0 )
	end
end

local function closeFile( )
	if xmlFile then
		xmlUnloadFile( xmlFile )
		xmlFile = nil
		xmlNode = nil
	end
end

local function xmlNodeSetValueIfNotEmpty( a, b )
	if b:match "^%s*(.-)%s*$" == "" then
		return xmlDestroyNode( a )
	else
		return xmlNodeSetValue( a, b )
	end
end

addEventHandler( "onClientChatMessage", root,
	function( message, r, g, b )
		local time = getRealTime( )
		if not xmlFile or not xmlNode then
			openFile( )
		elseif time.yearday ~= yearday or time.hour ~= hour then
			closeFile( )
			openFile( )
		end
		
		-- create a new 'line'
		local node = xmlCreateChild( xmlNode, "p" )
		
		-- add the date
		local nodeDate = xmlCreateChild( node, "span" )
		xmlNodeSetValue( nodeDate, ( "%04d-%02d-%02d" ):format( time.year + 1900, time.month + 1, time.monthday ) )
		xmlNodeSetAttribute( nodeDate, "class", "v1" )
		
		-- add the time
		local nodeTime = xmlCreateChild( node, "span" )
		xmlNodeSetValue( nodeTime, ( "%02d:%02d:%02d" ):format( time.hour, time.minute, time.second ) )
		xmlNodeSetAttribute( nodeTime, "class", "v2" )
		
		-- create a correctly color-encoded rgb message
		local t = { }
		local prevcolor = ("#%02x%02x%02x"):format( r, g, b )
		while true do
			local a, b = message:find("#%x%x%x%x%x%x")
			local t = xmlCreateChild( node, "span" )
			xmlNodeSetAttribute( t, "class", "v3" )
			if a and b then
				xmlNodeSetAttribute( t, "style", "color:" .. prevcolor )
				xmlNodeSetValueIfNotEmpty( t, message:sub( 1, a - 1 ) )
				prevcolor = message:sub( a, b )
				message = message:sub( b + 1 )
			else
				xmlNodeSetAttribute( t, "style", "color:" .. prevcolor )
				xmlNodeSetValueIfNotEmpty( t, message )
				break
			end
		end
		
		xmlSaveFile( xmlFile )
	end
)

addEventHandler( "onClientResourceStop", resourceRoot,
	function( )
		closeFile( )
	end
)
