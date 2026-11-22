-- Shows which area the player is standing in on your Hud.Area label ("Common Area", ...).
-- Areas are the parts in Workspace.AreaZones; each has an "Area" attribute (a rarity name).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Config = require(RS:WaitForChild("Config"))
local player = Players.LocalPlayer
local zones = workspace:WaitForChild("AreaZones")

local current = nil

local function areaAt(pos)
	for _, z in zones:GetChildren() do
		if z:IsA("BasePart") then
			local rel = z.CFrame:PointToObjectSpace(pos)
			local h = z.Size / 2
			if math.abs(rel.X) <= h.X and math.abs(rel.Y) <= h.Y and math.abs(rel.Z) <= h.Z then
				return z:GetAttribute("Area")
			end
		end
	end
	return nil
end

local function show(name)
	local hud = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Hud")
	local lbl = hud and hud:FindFirstChild("Area")
	if not lbl then return end
	lbl.Text = name .. " Area"
	local r = Config.RarityByName[name]
	lbl.TextColor3 = r and r.Color or Color3.fromRGB(255, 255, 255)
end

while true do
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		current = areaAt(root.Position) or current or "Common"
		show(current)
	end
	task.wait(0.25)
end
