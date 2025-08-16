--!strict

game.Workspace.sandbox:Destroy()

local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BadgeService = game:GetService("BadgeService")
local MarketPlaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Levels = require(ReplicatedStorage.modules.game.Levels)
local Util = require(ServerScriptService.Util)
local Products = require(ReplicatedStorage.modules.game.Products)

local ExplosionsInterface = require(script.Remotes.ExplosionsInterface)
local StatsInterface = require(script.Remotes.StatsInterface)
local BuildInterface = require(script.Remotes.BuildInterface)
local PlayerData = require(script.PlayerData)

local remotes = ReplicatedStorage.remotes

MarketPlaceService.ProcessReceipt = require(script.ProcessReceipt)

if RunService:IsStudio() then
	remotes.explodeAtPosition.OnServerEvent:Connect(ExplosionsInterface.onExplodeAtPosition)
else
	remotes.explodeAtPosition:Destroy()
end
remotes.shootRocketAtPosition.OnServerInvoke = ExplosionsInterface.onShootRocketAtPosition
remotes.build.OnServerInvoke = BuildInterface.onBuild
remotes.upgradeStat.OnServerInvoke = StatsInterface.onUpgradeStat

local ToolNames = {
	RocketLauncher = "Rocket Launcher",
	TripleRocketLauncher = "Triple Rocket Launcher",
	Sword = "Sword",
	Bomb = "Bomb",
	Build = "Build",
}

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
	print(player.Name)
	task.spawn(function()
		if not BadgeService:UserHasBadgeAsync(player.UserId, 340455814621683) then
			BadgeService:AwardBadge(player.UserId, 3404558146216830)
		end
	end)

	task.spawn(function()
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

		local damageValue = Instance.new("IntValue")
		damageValue.Value = playerData.Damage
		damageValue.Name = "Damage"
		damageValue.Parent = leaderstats
		PlayerData.onDamageChanged(player, function(damage)
			damageValue.Value = damage
		end)

		local winsValue = Instance.new("IntValue")
		winsValue.Value = playerData.Wins
		winsValue.Name = "Wins"
		winsValue.Parent = leaderstats
		PlayerData.onWinsChanged(player, function(wins)
			winsValue.Value = wins
		end)

		leaderstats.Parent = player
	end)

	task.delay(5, function()
		if player.Parent ~= Players then
			return
		end

		if player.Character then
			return
		end

		player:LoadCharacter()
	end)

	xpcall(function()
		player:SetAttribute(
			Products.GamePasses.tripleRocketLauncher.attribute,
			MarketPlaceService:UserOwnsGamePassAsync(player.UserId, Products.GamePasses.tripleRocketLauncher.id)
		)
	end, warn)

	local function onNewBackpack(backpack)
		if RunService:IsStudio() then
			ServerStorage.Build:Clone().Parent = backpack
			ServerStorage.Explode:Clone().Parent = backpack
		end

		Util.createTool(ToolNames.Sword).Parent = backpack
		local ownsTripleRocket = player:GetAttribute(Products.GamePasses.tripleRocketLauncher.attribute)
		if ownsTripleRocket then
			Util.createTool(ToolNames.TripleRocketLauncher).Parent = backpack
		else
			Util.createTool(ToolNames.RocketLauncher).Parent = backpack
		end
		Util.createTool(ToolNames.Bomb).Parent = backpack
		Util.createTool(ToolNames.Build).Parent = backpack
		if ownsTripleRocket then
			Util.createTool(ToolNames.RocketLauncher).Parent = backpack
		end
	end

	player:GetAttributeChangedSignal(Products.GamePasses.tripleRocketLauncher.attribute):Connect(function()
		if not player:GetAttribute(Products.GamePasses.tripleRocketLauncher.attribute) then
			return
		end

		local char = player.Character
		if not char or char:FindFirstChild(ToolNames.TripleRocketLauncher) then
			return
		end

		local backpack = player.Backpack
		if backpack:FindFirstChild(ToolNames.TripleRocketLauncher) then
			return
		end

		Util.createTool(ToolNames.TripleRocketLauncher).Parent = backpack
	end)

	if player.Backpack then
		onNewBackpack(player.Backpack)
	end

	player.CharacterAdded:Connect(function(char: any)
		local humanoid: Humanoid = char.Humanoid
		local function updateHumanoidStats()
			humanoid.WalkSpeed = if RunService:IsStudio()
				then 60
				else PlayerData.getStat(player, Levels.STAT_IDs.Character_WalkSpeed).value
			humanoid.JumpHeight = PlayerData.getStat(player, Levels.STAT_IDs.Character_JumpHeight).value
		end
		updateHumanoidStats()

		local connection = PlayerData.onLevelsChanged(player, function(levelId)
			if levelId == Levels.STAT_IDs.Character_WalkSpeed or levelId == Levels.STAT_IDs.Character_JumpHeight then
				updateHumanoidStats()
			end
		end)

		humanoid.Died:Connect(function()
			if connection then
				connection:Disconnect()
			end

			checkAttributeKill(char)

			task.wait(3)
			char:Destroy()
			if player.Parent ~= Players then
				return
			end

			player:LoadCharacter()
		end)
		onNewBackpack(player.Backpack)

		char.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(player.UserId))
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
