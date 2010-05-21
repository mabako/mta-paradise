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

shops =
{
	{
		position = { 2199.55, 1391.80, 10.91 },
		blip = 55,
		spots = 
		{
			-- Autobahn near Come-A-Lot
			{ 2224, 1391.1, 10.9, 0, 0, 120 },
			{ 2217.5, 1391.1, 10.9, 0, 0, 140 },
			{ 2211, 1391.1, 10.9, 0, 0, 160 },
			{ 2190.5, 1391.1, 10.9, 0, 0, 200 },
			{ 2185, 1391.1, 10.9, 0, 0, 220 },
			{ 2178.5, 1391.1, 10.9, 0, 0, 240 },
		},
		prices =
		{
			{ model = "Admiral", price = 23000 },
			{ model = "Bravura", price = 19000 },
			{ model = "Bobcat", price = 27000 },
			{ model = "Cadrona", price = 19500 },
			{ model = "Clover", price = 17000 },
			{ model = "Elegant", price = 24000 },
			{ model = "Feltzer", price = 35000 },
			{ model = "Fortune", price = 24000 },
			{ model = "Greenwood", price = 18000 },
			{ model = "Intruder", price = 26500 },
			{ model = "Landstalker", price = 40000 },
			{ model = "Majestic", price = 16900 },
			{ model = "Picador", price = 24000 },
			{ model = "Premier", price = 27000 },
			{ model = "Previon", price = 24600 },
			{ model = "Primo", price = 22000 },
			{ model = "Rancher", price = 35000 },
			{ model = "Sentinel", price = 30000 },
			{ model = "Tampa", price = 16800 },
			{ model = "Stallion", price = 25000 },
			{ model = "Vincent", price = 22000 },
			{ model = "Virgo", price = 17500 },
			{ model = "Washington", price = 21000 },
			{ model = "Windsor", price = 22500 },
		}
	},
	{
		position = { 1947.40, 2068.58, 10.60 },
		blip = 55,
		spots = {
			-- Autobahn near the Sex Shop
			{ 1977.66, 2058.52, 10.54, 0, 0, 155 },
			{ 1982.66, 2058.52, 10.54, 0, 0, 150 },
			{ 1987.66, 2058.52, 10.54, 0, 0, 145 },
			{ 1992.66, 2058.52, 10.54, 0, 0, 140 },
			{ 1992.66, 2053.52, 10.54, 0, 0, 135 },
			{ 1992.66, 2048.52, 10.54, 0, 0, 130 },
			{ 1992.66, 2043.52, 10.54, 0, 0, 125 },
			{ 1992.66, 2038.52, 10.54, 0, 0, 120 },
			{ 1945.82, 2089.26, 10.54, 0, 0, 140 },
			{ 1945.82, 2081.26, 10.54, 0, 0, 140 },
			{ 1945.82, 2047.26, 10.54, 0, 0, 40 },
			{ 1945.82, 2055.26, 10.54, 0, 0, 40 },
		},
		prices =
		{
			{ model = "Buffalo", price = 75000 },
			{ model = "Phoenix", price = 50000 },
			{ model = "Elegy", price = 60900 },
			{ model = "Flash", price = 45000 },
			{ model = "Jester", price = 47000 },
			{ model = "Sultan", price = 70200 },
			{ model = "Uranus", price = 43000 },
			{ model = "ZR-350", price = 37900 },
		},
	}
}

-- create lookup table/convert model names to ids
for key, value in ipairs( shops ) do
	value.lookup = { }
	for k, v in ipairs( value.prices ) do
		v.model = getVehicleModelFromName( v.model )
		value.lookup[ v.model ] = v.price
	end
end

-- 

function getVehiclePrice( vehicle )
	local shop = shops[ getElementParent( vehicle ) ]
	return shop and shop.lookup[ getElementModel( vehicle ) ]
end
