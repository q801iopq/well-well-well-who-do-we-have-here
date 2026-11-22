-- Missile turrets (the big boxes with holes in Workspace.Turrets).
-- Each turret has a "Level" attribute (1-5): higher = longer range, faster fire, faster & harder-hitting missiles.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local turrets = workspace:WaitForChild("Turrets")

local LEVELS = {
	[1] = {range = 70,  interval = 4.5, speed = 35,  damage = 8,  turn = 1.6},
	[2] = {range = 85,  interval = 3.8, speed = 50,  damage = 12, turn = 2.0},
	[3] = {range = 100, interval = 3.2, speed = 68,  damage = 18, turn = 2.4},
	[4] = {range = 115, interval = 2.5, speed = 88,  damage = 26, turn = 2.8},
	[5] = {range = 130, interval = 1.8, speed = 110, damage = 36, turn = 3.2},
}
local BLAST_RADIUS = 9
local MISSILE_LIFETIME = 6
local HIT_RADIUS = 4

-- Launchers only attack players standing in the Common area. Lobby and every other area is safe.
local zones = workspace:WaitForChild("AreaZones")
local function inDanger(pos)
	for _, z in zones:GetChildren() do
		if z:IsA("BasePart") and z:GetAttribute("Area") == "Common" then
			local rel = z.CFrame:PointToObjectSpace(pos)
			local h = z.Size / 2
			if math.abs(rel.X) <= h.X and math.abs(rel.Y) <= h.Y and math.abs(rel.Z) <= h.Z then return true end
		end
	end
	return false
end

local missileFolder = Instance.new("Folder")
missileFolder.Name = "Missiles"
missileFolder.Parent = workspace

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {turrets, missileFolder}

local missiles = {}

local function explode(pos, damage)
	local fx = Instance.new("Explosion")
	fx.Position = pos
	fx.BlastRadius = 0
	fx.BlastPressure = 0
	fx.DestroyJointRadiusPercent = 0
	fx.Parent = workspace
	for _, plr in Players:GetPlayers() do
		local char = plr.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if root and hum and hum.Health > 0 and (root.Position - pos).Magnitude <= BLAST_RADIUS and inDanger(root.Position) then
			hum:TakeDamage(damage)
		end
	end
end

local function fire(turret, hole, cfg, target)
	local p = Instance.new("Part")
	p.Name = "Missile"
	p.Size = Vector3.new(1, 1, 4)
	p.Color = Color3.fromRGB(255, 120, 30)
	p.Material = Enum.Material.Neon
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	local dir = hole.CFrame.LookVector -- launches along the tilted rack
	p.CFrame = CFrame.lookAt(hole.Position, hole.Position + dir)
	p.Parent = missileFolder
	table.insert(missiles, {part = p, dir = dir, target = target, cfg = cfg, born = os.clock()})
end

local state = {}
for _, t in turrets:GetChildren() do
	state[t] = {next = os.clock() + math.random() * 2, hole = 1}
end

local function nearestTarget(pos, range)
	local best, bestD = nil, range
	for _, plr in Players:GetPlayers() do
		local char = plr.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if root and hum and hum.Health > 0 and inDanger(root.Position) then
			local d = (root.Position - pos).Magnitude
			if d <= bestD then best, bestD = root, d end
		end
	end
	return best
end

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()

	for t, s in state do
		if not t.Parent then state[t] = nil continue end
		local cfg = LEVELS[t:GetAttribute("Level") or 1] or LEVELS[1]
		local body = t.PrimaryPart
		local target = nearestTarget(body.Position, cfg.range)
		if target then
			local flat = Vector3.new(target.Position.X, body.Position.Y, target.Position.Z)
			t:PivotTo(CFrame.lookAt(body.Position, flat))
			if now >= s.next then
				s.next = now + cfg.interval
				local hole = t:FindFirstChild("Hole" .. s.hole)
				s.hole = s.hole % 6 + 1
				if hole then fire(t, hole, cfg, target) end
			end
		end
	end

	for i = #missiles, 1, -1 do
		local m = missiles[i]
		local part = m.part
		local done = false
		if not part.Parent or now - m.born > MISSILE_LIFETIME then
			done = true
		else
			local pos = part.Position
			if m.target and m.target.Parent then
				local want = (m.target.Position - pos).Unit
				m.dir = m.dir:Lerp(want, math.min(1, m.cfg.turn * dt)).Unit
			end
			local step = m.dir * m.cfg.speed * dt
			-- missiles fly through walls/floors; they only explode next to a player
			local newPos = pos + step
			local hit = false
			for _, plr in Players:GetPlayers() do
				local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
				if root and (root.Position - newPos).Magnitude <= HIT_RADIUS and inDanger(root.Position) then hit = true break end
			end
			if hit then
				explode(newPos, m.cfg.damage)
				done = true
			else
				part.CFrame = CFrame.lookAt(pos + step, pos + step + m.dir)
			end
		end
		if done then
			part:Destroy()
			table.remove(missiles, i)
		end
	end
end)
