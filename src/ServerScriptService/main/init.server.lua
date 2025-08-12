--!strict

local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remotes = ReplicatedStorage.remotes
local toolTemplate = ServerStorage.ToolTemplate

remotes.explodeAt.OnServerEvent:Connect(function(_, pos: Vector3)
	local explosion = Instance.new("Explosion")
	explosion.Position = pos
	explosion.BlastRadius = 5
	explosion.Parent = game.Workspace
end)

local function createTool(name: string): Tool
	local tool = toolTemplate:Clone()
	tool.Name = name
	tool.server.Enabled = true
	return tool
end

local function onPlayerAdded(player: Player)
	if RunService:IsStudio() then
		player.CanLoadCharacterAppearance = false
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	Instance.new("IntValue", leaderstats).Name = "KO's"
	Instance.new("IntValue", leaderstats).Name = "Points"

	leaderstats.Parent = player

	local function onNewBackpack(backpack)
		if RunService:IsStudio() then
			ServerStorage.Build:Clone().Parent = backpack
			ServerStorage.Explode:Clone().Parent = backpack
		end

		createTool("Rocket Launcher").Parent = backpack
	end

	if player.Backpack then
		onNewBackpack(player.Backpack)
	end
	player.CharacterAdded:Connect(function(char)
		if RunService:IsStudio() then
			local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
			if humanoid then
				humanoid.WalkSpeed = 60
			end
		end
		onNewBackpack(player.Backpack)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, v in Players:GetPlayers() do
	task.spawn(onPlayerAdded, v)
end

require(script.GameLoop)
