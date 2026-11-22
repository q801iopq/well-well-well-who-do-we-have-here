-- Makes spawned helicopters hover: a gentle up/down bob plus a slight sway (visual only, client side).
local RunService = game:GetService("RunService")

local live = workspace:WaitForChild("SpawnedHelis")
local AMPLITUDE = 0.7 -- studs
local SPEED = 1.6

local items = {} -- model -> {base, phase}

local function track(model)
	if not model:IsA("Model") then return end
	items[model] = {base = model:GetPivot(), phase = math.random() * math.pi * 2}
end

for _, m in live:GetChildren() do track(m) end
live.ChildAdded:Connect(function(m) task.defer(track, m) end)
live.ChildRemoved:Connect(function(m) items[m] = nil end)

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for model, d in items do
		if not model.Parent then items[model] = nil continue end
		local a = t * SPEED + d.phase
		model:PivotTo(d.base * CFrame.new(0, math.sin(a) * AMPLITUDE, 0) * CFrame.Angles(math.sin(a * 0.7) * 0.02, 0, math.cos(a * 0.9) * 0.02))
	end
end)
