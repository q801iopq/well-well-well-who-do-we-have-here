-- ReplicatedStorage.Config (ModuleScript)
-- Price of a helicopter = exactly what it earns in PriceSeconds seconds (Income * 12).
local Config = {}

Config.StartCoins = 50
Config.PriceSeconds = 12

-- Income = coins per second. Ordered cheapest to most expensive.
local list = {
	{Id = "R22", Name = "Robinson R22", Income = 1},
	{Id = "R44", Name = "Robinson R44", Income = 2},
	{Id = "Bell206", Name = "Bell 206 JetRanger", Income = 3},
	{Id = "H125", Name = "Airbus H125", Income = 5},
	{Id = "MD500", Name = "MD Helicopters MD 500", Income = 8},
	{Id = "Bell407", Name = "Bell 407", Income = 12},
	{Id = "H135", Name = "Airbus H135", Income = 18},
	{Id = "Huey", Name = "Bell UH-1 Huey", Income = 27},
	{Id = "H145", Name = "Airbus H145", Income = 40},
	{Id = "Puma", Name = "Aerospatiale SA 330 Puma", Income = 60},
	{Id = "AW139", Name = "Leonardo AW139", Income = 90},
	{Id = "S76", Name = "Sikorsky S-76", Income = 135},
	{Id = "BlackHawk", Name = "Sikorsky UH-60 Black Hawk", Income = 200},
	{Id = "Cobra", Name = "Bell AH-1 Cobra", Income = 300},
	{Id = "Tiger", Name = "Eurocopter Tiger", Income = 450},
	{Id = "Ka52", Name = "Kamov Ka-52 Alligator", Income = 675},
	{Id = "Apache", Name = "Boeing AH-64 Apache", Income = 1000},
	{Id = "Hind", Name = "Mil Mi-24 Hind", Income = 1500},
	{Id = "Mi8", Name = "Mil Mi-8 Hip", Income = 2250},
	{Id = "Merlin", Name = "Leonardo AW101 Merlin", Income = 3400},
	{Id = "Chinook", Name = "Boeing CH-47 Chinook", Income = 5000},
	{Id = "KingStallion", Name = "Sikorsky CH-53K King Stallion", Income = 7500},
	{Id = "Skycrane", Name = "Sikorsky S-64 Skycrane", Income = 11000},
	{Id = "Mi26", Name = "Mil Mi-26 Halo", Income = 17000},
	{Id = "Mi12", Name = "Mil Mi-12 Homer", Income = 25000},
}

Config.ById = {}
for _, h in list do
	h.Price = h.Income * Config.PriceSeconds
	Config.ById[h.Id] = h
end
Config.Helicopters = list

return Config
