--!strict

local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remotes = ReplicatedStorage.remotes

local generateModel: Model = game.Workspace.generate

local BRICK_SIZE = 5
local BRICK_SIZE_VECTOR = Vector3.new(BRICK_SIZE, BRICK_SIZE, 0)

local function weld(a: BasePart, b: BasePart)
	local w = Instance.new("Weld")
	w.Part0 = a
	w.Part1 = b
	w.C0 = a.CFrame:ToObjectSpace(b.CFrame)
	w.Parent = b
end

local function atomizePart(source: BasePart)
	source.Anchored = true
	source.CanCollide = false
	source.CanQuery = false
	source.CanTouch = false
	source.Transparency = 1

	local model = Instance.new("Model")
	model.Name = source.Name
	local origin = source.CFrame * CFrame.new((BRICK_SIZE_VECTOR - source.Size) / 2)
	local n = source.Size // BRICK_SIZE
	for x = 1, n.X do
		for y = 1, n.Y do
			local p = Vector3.new(x, y, 0)
			local part = Instance.new("Part")
			part.Name = `{x},{y}`
			part.CFrame = origin * CFrame.new((p - Vector3.one) * BRICK_SIZE)
			part.Size = BRICK_SIZE_VECTOR + Vector3.new(0, 0, 2)
			part.Color = Color3.fromHSV(0, 0, math.random())
			weld(source, part)
			part.Parent = model
		end
	end
	model.Parent = game.Workspace
end

for _, v in generateModel:GetChildren() do
	atomizePart(v :: BasePart)
end

remotes.explodeAt.OnServerEvent:Connect(function(_, pos: Vector3)
	local explosion = Instance.new("Explosion")
	explosion.Position = pos
	explosion.BlastRadius = 5
	explosion.Parent = game.Workspace
end)

local function onPlayerAdded(player: Player)
	local function onNewBackpack(backpack)
		if RunService:IsStudio() then
			ServerStorage.Build:Clone().Parent = backpack
			ServerStorage.Explode:Clone().Parent = backpack
		end
	end

	if player:FindFirstChild("Backpack") then
		onNewBackpack(player)
	end
	player.CharacterAdded:Connect(function(char)
		onNewBackpack(player.Backpack)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, v in Players:GetPlayers() do
	task.spawn(onPlayerAdded, v)
end
