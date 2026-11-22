-- Spawns stealable helicopters on the pads in Workspace.HeliSpawns.
-- Each pad has a "Rarity" attribute (Common ... Mythic): it only spawns helicopters of that rarity.
-- Helicopter models come from ServerStorage.HeliModels (one Model per helicopter Id).
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

local Config = require(RS:WaitForChild("Config"))
local MODELS = SS:WaitForChild("HeliModels")
local PADS = workspace:WaitForChild("HeliSpawns")

local LIFETIME = 120     -- seconds before an untouched helicopter despawns
local RESPAWN_DELAY = 5  -- seconds before a pad spawns a new one
local TAG = "StealableHelicopter"

local live = Instance.new("Folder")
live.Name = "SpawnedHelis"
live.Parent = workspace

-- helicopters of this rarity that actually have a model
local function candidates(rarityName)
	local list = {}
	for _, h in Config.Helicopters do
		if (rarityName == nil or h.Rarity == rarityName) and MODELS:FindFirstChild(h.Id) then
			table.insert(list, h)
		end
	end
	return list
end

local function label(parent, text, y, color, size)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, size + 4)
	l.Position = UDim2.fromOffset(0, y)
	l.Font = Enum.Font.GothamBold
	l.TextSize = size
	l.Text = text
	l.TextColor3 = color
	l.TextStrokeTransparency = 0.3
	l.Parent = parent
end

local function addBillboard(model, def)
	local rarity = Config.RarityByName[def.Rarity]
	local cf, size = model:GetBoundingBox()
	local anchor = Instance.new("Part")
	anchor.Name = "LabelAnchor"
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Position = cf.Position + Vector3.new(0, size.Y / 2 + 3, 0)
	anchor.Parent = model

	local gui = Instance.new("BillboardGui")
	gui.Adornee = anchor
	gui.Size = UDim2.fromOffset(240, 56)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 170
	gui.Parent = anchor
	label(gui, def.Name, 0, Color3.new(1, 1, 1), 20)
	label(gui, string.upper(def.Rarity) .. "  -  " .. def.Price .. " coins", 26, rarity and rarity.Color or Color3.new(1, 1, 1), 16)
end

local function spawnOn(pad)
	if not pad.Parent or pad:GetAttribute("Occupied") then return end
	local list = candidates(pad:GetAttribute("Rarity"))
	if #list == 0 then return end
	local def = list[math.random(#list)]
	pad:SetAttribute("Occupied", true)

	local model = MODELS[def.Id]:Clone()
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
			if d.Name:find("Rotor") or d.Name:find("Glass") then d.CanCollide = false end
		end
	end

	-- stand it on the pad with a random heading
	local padTop = pad.Position + Vector3.new(0, pad.Size.Y / 2, 0)
	model:PivotTo(CFrame.new(padTop) * CFrame.Angles(0, math.rad(math.random(0, 359)), 0))
	local cf, size = model:GetBoundingBox()
	model:PivotTo(model:GetPivot() + Vector3.new(0, padTop.Y - (cf.Position.Y - size.Y / 2), 0))

	model.Name = def.Id
	model:SetAttribute("HeliId", def.Id)
	model:SetAttribute("Spawned", true)
	addBillboard(model, def)
	model.Parent = live
	CollectionService:AddTag(model, TAG) -- Economy adds the Steal prompt

	local freed = false
	model.Destroying:Connect(function()
		if freed then return end
		freed = true
		pad:SetAttribute("Occupied", false)
		task.delay(RESPAWN_DELAY, function() spawnOn(pad) end)
	end)
	task.delay(LIFETIME, function()
		if model.Parent then model:Destroy() end
	end)
end

local i = 0
for _, pad in PADS:GetChildren() do
	if pad:IsA("BasePart") then
		i += 1
		local r = Config.RarityByName[pad:GetAttribute("Rarity")]
		if r then pad.Color = r.Color end
		task.delay(i * 0.3, function() spawnOn(pad) end)
	end
end
