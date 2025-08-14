--!strict

game.Workspace.sandbox:Destroy()

local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ExplosionsInterface = require(script.Remotes.ExplosionsInterface)
local BuildInterface = require(script.Remotes.BuildInterface)
local PlayerData = require(script.PlayerData)

local remotes = ReplicatedStorage.remotes
local toolTemplate = ServerStorage.ToolTemplate

if RunService:IsStudio() then
	remotes.explodeAtPosition.OnServerEvent:Connect(ExplosionsInterface.onExplodeAtPosition)
end
remotes.shootRocketAtPosition.OnServerEvent:Connect(ExplosionsInterface.onShootRocketAtPosition)
remotes.build.OnServerInvoke = BuildInterface.onBuild

local function createTool(name: string): Tool
	local tool = toolTemplate:Clone()
	tool.Name = name
	tool.server.Enabled = true

	if not ReplicatedStorage.modules.game.tools:FindFirstChild(name) then
		tool.client:Destroy()
	end

	return tool
end

local function checkAttributeKill(char: Model)
	local taggedByUserId = char:GetAttribute("lastTaggedBy") :: number?
	local taggedAtTime = char:GetAttribute("taggedAtTime") :: number?
	if not (taggedAtTime and taggedByUserId) then
		return
	end

	if time() - taggedAtTime > 10 then
		return
	end

	local taggingPlayer = Players:GetPlayerByUserId(taggedByUserId)
	if not taggingPlayer then
		return
	end

	PlayerData.addKO(taggingPlayer)

	local team = taggingPlayer.Team
	local score = team and team:GetAttribute("score")
	if team and score then
		team:SetAttribute("score", score + 1)
	end
end

local function onPlayerAdded(player: Player)
	if RunService:IsStudio() then
		player.CanLoadCharacterAppearance = false
	end

	local playerData = PlayerData.loadPlayerData(player)
	if not playerData then
		return
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local kosValue = Instance.new("IntValue")
	kosValue.Value = playerData.KOs
	kosValue.Name = "KO's"
	kosValue.Parent = leaderstats
	PlayerData.onKOsChanged(player, function(kos)
		kosValue.Value = kos
	end)

	local studsValue = Instance.new("IntValue")
	studsValue.Value = playerData.Studs
	studsValue.Name = "Points"
	studsValue.Parent = leaderstats
	PlayerData.onStudsChanged(player, function(studs)
		studsValue.Value = studs
	end)

	local winsValue = Instance.new("IntValue")
	winsValue.Value = playerData.Wins
	winsValue.Name = "Wins"
	winsValue.Parent = leaderstats
	PlayerData.onWinsChanged(player, function(studs)
		winsValue.Value = studs
	end)

	leaderstats.Parent = player

	local function onNewBackpack(backpack)
		if RunService:IsStudio() then
			ServerStorage.Build:Clone().Parent = backpack
			ServerStorage.Explode:Clone().Parent = backpack
		end

		createTool("Rocket Launcher").Parent = backpack
		createTool("Sword").Parent = backpack
		createTool("Bomb").Parent = backpack
		createTool("Build").Parent = backpack
	end

	if player.Backpack then
		onNewBackpack(player.Backpack)
	end

	player.CharacterAdded:Connect(function(char: any)
		local humanoid: Humanoid = char.Humanoid
		humanoid.WalkSpeed = if RunService:IsStudio() then 60 else 24
		humanoid.JumpHeight = 10
		humanoid.Died:Connect(function()
			checkAttributeKill(char)

			task.wait(3)
			char:Destroy()
			if player.Parent ~= Players then
				return
			end

			player:LoadCharacter()
		end)
		onNewBackpack(player.Backpack)
	end)

	player:LoadCharacter()
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, v in Players:GetPlayers() do
	task.spawn(onPlayerAdded, v)
end

Players.PlayerRemoving:Connect(function(player)
	PlayerData.unloadPlayerData(player)
end)

require(script.GameLoop)
