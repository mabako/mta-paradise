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

-- Interior positions of all interios we can create
-- TODO: Add all remaining interiors
interiorPositions =
{
	-- houses -- TODO: should be renamed to [cagegory][num], low1, etc.
	house1  = { x =   235.25, y =  1186.68, z = 1080.26, interior = 3 }, -- two floors
	house2  = { x =   226.79, y =  1240.02, z = 1082.14, interior = 2 },
	house3  = { x =   223.07, y =  1287.09, z = 1082.14, interior = 1 },
	house4  = { x =   327.94, y =  1477.73, z = 1084.44, interior = 15 },
	house5  = { x =  2468.84, y = -1698.29, z = 1013.51, interior = 2 }, -- ryder's house
	-- house6  = { x =  2535.83, y = -1674.32, z = 1015.50, interior = 1 }, -- sweet's house
	house7  = { x =   387.23, y =  1471.79, z = 1080.19, interior = 15 },
	house8  = { x =   225.79, y =  1021.46, z = 1084.02, interior = 7 }, -- two floors
	house9  = { x =   295.16, y =  1472.26, z = 1080.26, interior = 15 },
	house10 = { x =  2807.58, y = -1174.75, z = 1025.57, interior = 8 },
	house12 = { x =  2270.42, y = -1210.52, z = 1047.56, interior = 10 },
	house13 = { x =  2496.02, y = -1692.08, z = 1014.74, interior = 3 }, -- CJ's house
	house14 = { x =  2259.38, y = -1135.84, z = 1050.64, interior = 10 },
	house15 = { x =  2365.21, y = -1135.60, z = 1050.88, interior = 8 },
	
	madddogg = { x = 1298.95, y = -797.01, z = 1084.01, interior = 5 },
	
	-- business
	['24/7-1'] = { x = -25.89, y = -188.24, z = 1003.54, interior = 17 },
	['24/7-2'] = { x =   6.11, y =  -31.75, z = 1003.54, interior = 10 },
	['24/7-3'] = { x = -25.89, y = -188.24, z = 1003.54, interior = 17 },
	['24/7-4'] = { x = -25.77, y = -141.55, z = 1003.55, interior = 16 },
	['24/7-5'] = { x = -27.30, y =  -31.76, z = 1003.56, interior = 4 },
	['24/7-6'] = { x = -27.34, y =  -58.26, z = 1003.55, interior = 6 },
	ammunation1 = { x = 285.50, y =  -41.80, z = 1001.52, interior = 1, blip = 6 },
	ammunation2 = { x = 285.87, y =  -86.78, z = 1001.52, interior = 4, blip = 6 }, 
	ammunation3 = { x = 296.84, y = -112.06, z = 1001.52, interior = 6, blip = 6 },
	ammunation4 = { x = 315.70, y = -143.66, z =  999.60, interior = 7, blip = 6 },
	ammunation5 = { x = 316.32, y = -170.30, z =  999.60, interior = 6, blip = 6 },
	atrium = { x = 1727.04, y = -1637.84, z = 20.22, interior = 18 },
	bar =        { x = 501.99, y =  -67.56, z =  998.75, interior = 11, blip = 49 },
	bar2 =       { x = -229.3, y = 1401.28, z =   27.76, interior = 18, blip = 49 },
	burgershot = { x = 362.84, y =  -75.13, z = 1001.50, interior = 10, blip = 10 },
	clothes1 =   { x = 207.63, y = -111.26, z = 1005.13, interior = 15, blip = 45 }, -- Binco
	clothes2 =   { x = 204.32, y = -168.85, z = 1000.52, interior = 14, blip = 45 }, -- Pro Laps
	clothes3 =   { x = 207.07, y = -140.37, z = 1003.51, interior = 3, blip = 45 }, -- Didier Sachs
	clothes4 =   { x = 203.81, y =  -50.66, z = 1001.80, interior = 1, blip = 45 }, -- Suburban
	clothes5 =   { x = 227.56, y =   -8.06, z = 1002.21, interior = 5, blip = 45 }, -- Victim
	clothes6 =   { x = 161.37, y =  -97.11, z = 1001.80, interior = 18, blip = 45 }, -- Zip
	club =       { x = 493.50, y =  -24.95, z = 1000.67, interior = 17, blip = 48 },
	cluckinbell = { x = 364.98, y = -11.84, z = 1001.85, interior = 9, blip = 14 },
	electronics = { x = -2240.77, y = 137.20, z = 1035.41, interior = 6 }, -- Zero's RC
	meatfactory = { x = 964.93, y = 2160.09, z = 1011.03, interior = 1 },
	office1 = { x =   390.76, y =   173.79, z = 1008.38, interior = 3 }, -- City Planning Department
	office2 = { x = -2026.86, y =  -103.60, z = 1035.18, interior = 3 }, -- Driving School
	office3 = { x =  1494.36, y =  1303.57, z = 1093.28, interior = 3 }, -- Bike School
	pizza =   { x =   372.33, y =  -133.52, z = 1001.49, interior = 5, blip = 29 },
	sexshop = { x =  -100.34, y =   -25.03, z = 1000.72, interior = 3 },
	
	-- police departments
	lspd = { x = 246.75, y =  62.32, z = 1003.64, interior = 6 },
	sfpd = { x = 246.35, y = 107.30, z = 1003.22, interior = 10 },
	lvpd = { x = 238.72, y = 138.62, z = 1003.02, interior = 3 },
}
