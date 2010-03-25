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
		position = { -1965.24, 294.11, 35.46 },
		blip = 55,
		spots = 
		{
			-- Wang Cars, outside
			{ -1991.40, 243.30, 35.3, 0, 0, 300 },
			{ -1990.65, 249.45, 35.3, 0, 0, 300 },
			{ -1989.93, 255.52, 35.3, 0, 0, 300 },
			{ -1989.41, 261.57, 35.3, 0, 0, 300 },
			{ -1988.82, 267.85, 35.3, 0, 0, 300 },
			{ -1988.35, 274.13, 35.3, 0, 0, 300 },
			{ -1986.60, 304.27, 35.3, 0, 0, 250 }
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