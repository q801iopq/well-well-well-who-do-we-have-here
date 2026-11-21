-- ReplicatedStorage.Config (ModuleScript)
-- Price of a helicopter = exactly what it earns in PriceSeconds seconds (Income * 12).
local Config = {}

Config.StartCoins = 50
Config.PriceSeconds = 12

-- Income = coins per second. Ordered cheapest to most expensive.
local list = {
	{Id = "R22",          Name = "Robinson R22",                 Income = 1},
	{Id = "Bell206",      Name = "Bell 206 JetRanger",           Income = 2},
	{Id = "H125",         Name = "Airbus H125",                  Income = 4},
	{Id = "Huey",         Name = "Bell UH-1 Huey",               Income = 8},
	{Id = "H145",         Name = "Airbus H145",                  Income = 15},
	{Id = "BlackHawk",    Name = "Sikorsky UH-60 Black Hawk",    Income = 30},
	{Id = "AW139",        Name = "Leonardo AW139",               Income = 55},
	{Id = "Apache",       Name = "Boeing AH-64 Apache",          Income = 100},
	{Id = "Hind",         Name = "Mil Mi-24 Hind",               Income = 180},
	{Id = "Chinook",      Name = "Boeing CH-47 Chinook",         Income = 320},
	{Id = "KingStallion", Name = "Sikorsky CH-53K King Stallion", Income = 600},
	{Id = "Mi26",         Name = "Mil Mi-26 Halo",               Income = 1100},
}

Config.ById = {}
for _, h in list do
	h.Price = h.Income * Config.PriceSeconds
	Config.ById[h.Id] = h
end
Config.Helicopters = list

return Config
