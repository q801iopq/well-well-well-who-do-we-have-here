-- Coins, helicopter income and stealing. All checks happen on the server.
-- To make a helicopter stealable: tag a Model/Part "StealableHelicopter" and set
-- its attribute HeliId to an Id from ReplicatedStorage.Config (e.g. "Huey").
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Config = require(RS:WaitForChild("Config"))

local TAG = "StealableHelicopter"
local RESPAWN_SECONDS = 20
local PROMPT_DISTANCE = 12
local DISTANCE_SLACK = 8 -- extra server-side tolerance for lag

---------------------------------------------------------------- Players
local function setupPlayer(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = Config.StartCoins
	coins.Parent = stats
	stats.Parent = player

	local owned = Instance.new("Folder")
	owned.Name = "Helicopters"
	owned.Parent = player
	player:SetAttribute("Income", 0)
end

local function incomeOf(player)
	local owned = player:FindFirstChild("Helicopters")
	local total = 0
	if owned then
		for _, v in owned:GetChildren() do
			local def = Config.ById[v.Name]
			if def then total += def.Income * v.Value end
		end
	end
	return total
end

Players.PlayerAdded:Connect(setupPlayer)
for _, p in Players:GetPlayers() do setupPlayer(p) end

-- Income: every second each player earns the sum of their helicopters' income.
task.spawn(function()
	while true do
		task.wait(1)
		for _, player in Players:GetPlayers() do
			local stats = player:FindFirstChild("leaderstats")
			local owned = player:FindFirstChild("Helicopters")
			if stats and owned then
				local total = incomeOf(player)
				player:SetAttribute("Income", total)
				if total > 0 then stats.Coins.Value += total end
			end
		end
	end
end)

---------------------------------------------------------------- Stealing
local function anchorPart(inst)
	if inst:IsA("BasePart") then return inst end
	if inst:IsA("Model") then
		return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
	end
end

local handled = setmetatable({}, {__mode = "k"}) -- re-parenting re-fires the tag signal

local function makeStealable(inst)
	if handled[inst] then return end
	handled[inst] = true
	local def = Config.ById[inst:GetAttribute("HeliId")]
	if not def then
		warn("Stealable helicopter has no valid HeliId:", inst:GetFullName())
		return
	end
	local part = anchorPart(inst)
	if not part then return end

	-- Big helicopters need a bigger reach so players can grab them from the side.
	local reach = PROMPT_DISTANCE
	if inst:IsA("Model") then
		local _, size = inst:GetBoundingBox()
		reach = math.max(PROMPT_DISTANCE, math.max(size.X, size.Z) / 2 + 4)
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Steal"
	prompt.ObjectText = def.Name .. " - " .. def.Price .. " coins"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = reach
	prompt.RequiresLineOfSight = false
	prompt.Parent = part

	local busy = false
	prompt.Triggered:Connect(function(player)
		if busy or not inst.Parent then return end

		-- Server-side checks: the client can't skip any of these.
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if (root.Position - part.Position).Magnitude > reach + DISTANCE_SLACK then return end
		local stats = player:FindFirstChild("leaderstats")
		local owned = player:FindFirstChild("Helicopters")
		if not stats or not owned then return end
		if stats.Coins.Value < def.Price then return end

		busy = true
		stats.Coins.Value -= def.Price
		local v = owned:FindFirstChild(def.Id)
		if not v then
			v = Instance.new("IntValue")
			v.Name = def.Id
			v.Parent = owned
		end
		v.Value += 1
		player:SetAttribute("Income", incomeOf(player))

		-- Spawned helicopters are removed; the spawner puts a new one on the pad later.
		if inst:GetAttribute("Spawned") then
			inst:Destroy()
			return
		end

		-- Hand-placed helicopters come back after a while.
		local parent = inst.Parent
		inst.Parent = nil
		task.delay(RESPAWN_SECONDS, function()
			inst.Parent = parent
			busy = false
		end)
	end)
end

for _, inst in CollectionService:GetTagged(TAG) do makeStealable(inst) end
CollectionService:GetInstanceAddedSignal(TAG):Connect(makeStealable)
