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

local foodMap =
{
	mookidsmeal = "bs1",
	beeftowermeal = "bs2",
	meatstackmeal = "bs3",
	cluckinlittlemeal = "cluckin1",
	cluckinbigmeal = "cluckin2",
	cluckinhugemeal = "cluckin3",
	saladmeal = "salad",
	largesaladmeal = "salad",
	ramen = "ramen",
	buster = "pizza1",
	doubledluxe = "pizza2",
	fullrack = "pizza3",
	hotdog = "hotdog",
	icecreamstick = "icecream",
}

local drinkMap =
{
	sprunk = "sprunk"
}

--

local function img( id )
	return ":items/images/" .. id .. ".png"
end

local function getFoodImage( value, name )
	if name then
		name = name:lower( ):gsub( "'", " " ):gsub( " ", "" ):gsub( "-", "" )
		return img( foodMap[ name ] or 3 )
	end
	return img( 3 )
end

local function getDrinkImage( value, name )
	if name then
		name = name:lower( ):gsub( "'", " " ):gsub( " ", "" ):gsub( "-", "" )
		return img( drinkMap[ name ] or 4 )
	end
	return img( 4 )
end

--

item_list =
{
	{ name = "Vehicle Key", image = true },
	{ name = "House Key", image = true },
	{ name = "Food", image = getFoodImage },
	{ name = "Drink", image = getDrinkImage },
	{ name = "Clothes", image = function( value, name ) if value then return ":players/images/skins/" .. value .. ".png" end end },
	{ name = "Debit Card", image = true },
	{ name = "Phone", image = true },
	{ name = "Dictionary", image = function( value, name ) if value then return ":players/images/flags/" .. value .. ".png" end end },
}

--

function getName( id )
	return item_list[ id ] and item_list[ id ].name or ""
end

function getDescription( id )
	return item_list[ id ] and item_list[ id ].description or ""
end

function getImage( id, value, name )
	return item_list[ id ] and (
		type( item_list[ id ].image ) == "function" and item_list[ id ].image( value, name )  or
			item_list[ id ].image == true and img( id ) or
			item_list[ id ].image
	)
end
