--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Cryo = require(ReplicatedStorage.modules.dependencies.Cryo)
local ProfileStore = require(ReplicatedStorage.modules.dependencies.ProfileStore)
local Signal = require(ReplicatedStorage.modules.dependencies.Signal)
local Leaderboards = require(ServerScriptService.main.Leaderboards)
local Levels = require(ReplicatedStorage.modules.game.Levels)
local Products = require(ReplicatedStorage.modules.game.Products)

local updateClientLevelsRemote = ReplicatedStorage.remotes.updateClientLevels
local updateClientPointsRemote = ReplicatedStorage.remotes.updateClientPoints

local POINTS_PER_DAMAGE = 0.5
local POINTS_PER_KO = 50
local POINTS_PER_WIN = 500
local POINTS_PER_PART_COLLECTED = 10

local function getInitialLevels(): { [string]: number }
	return Cryo.Dictionary.map(Levels.LEVELS, function(level, statId)
		return 1, tostring(statId)
	end)
end

local profileTemplate = {
	Damage = 0,
	PartsCollected = 0,
	KOs = 0,
	Wins = 0,
	Points = 0,
	Levels = getInitialLevels(),
}
type ProfileData = typeof(profileTemplate)

local PlayerStore = ProfileStore.New("PlayerStore", profileTemplate)

type Profile = typeof(PlayerStore:StartSessionAsync(nil :: any, nil :: any))
local Profiles: { [Player]: Profile } = {}
local dataSignals: {
	[Player]: {
		Damage: Signal.Signal<number>,
		PartsCollected: Signal.Signal<number>,
		KOs: Signal.Signal<number>,
		Wins: Signal.Signal<number>,
		Points: Signal.Signal<number>,
		Levels: Signal.Signal<number>,
	},
} =
	{}

local PlayerData = {}

function PlayerData.loadPlayerData(player: Player): ProfileData?
	dataSignals[player] = {
		Damage = Signal.new(),
		PartsCollected = Signal.new(),
		KOs = Signal.new(),
		Wins = Signal.new(),
		Points = Signal.new(),
		Levels = Signal.new(),
	}

	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if not profile then
		player:Kick(`Profile load fail - Please rejoin`)
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile.OnAfterSave:Connect(function(lastSavedData)
		Leaderboards.updatePlayerStanding(player, {
			wins = lastSavedData.Wins,
			damage = lastSavedData.Damage,
			partsCollected = lastSavedData.PartsCollected,
			KOs = lastSavedData.KOs,
		})
	end)

	profile.OnSessionEnd:Connect(function()
		Profiles[player] = nil
		player:Kick(`Profile session end - Please rejoin`)
	end)

	if player.Parent ~= Players then
		profile:EndSession()
		return
	end

	updateClientLevelsRemote:FireClient(player, profile.Data.Levels)
	updateClientPointsRemote:FireClient(player, profile.Data.Points)

	Profiles[player] = profile
	return profile.Data
end

function PlayerData.unloadPlayerData(player: Player)
	local signals = dataSignals[player]
	if signals then
		signals.Damage:Destroy()
		signals.KOs:Destroy()
		signals.Wins:Destroy()
		signals.Points:Destroy()
		signals.Levels:Destroy()
	end

	local profile = Profiles[player]
	if profile ~= nil then
		profile:EndSession()
	end
end

function PlayerData.getPlayerData(player: Player): ProfileData?
	local profile = Profiles[player]
	if not profile then
		return
	end

	return table.clone(profile.Data)
end

function PlayerData.addDamage(player: Player, delta: number)
	assert(delta > 0)

	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return
	end

	profile.Data.Damage += delta
	signals.Damage:Fire(profile.Data.Damage)
	PlayerData.addPoints(player, math.ceil(delta * POINTS_PER_DAMAGE))
end

function PlayerData.addPartCollected(player: Player)
	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return
	end

	profile.Data.PartsCollected += 1
	signals.PartsCollected:Fire(profile.Data.PartsCollected)
	PlayerData.addPoints(player, math.ceil(POINTS_PER_PART_COLLECTED))
end

function PlayerData.addKO(player: Player)
	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return
	end

	profile.Data.KOs += 1
	signals.KOs:Fire(profile.Data.KOs)
	PlayerData.addPoints(player, math.ceil(POINTS_PER_KO))
end

function PlayerData.addWin(player: Player)
	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return
	end

	profile.Data.Wins += 1
	signals.Wins:Fire(profile.Data.Wins)
	PlayerData.addPoints(player, math.ceil(POINTS_PER_WIN))
end

local function queuePointsUpdate(player: Player)
	if player:GetAttribute("updatePoints") then
		return
	end
	player:SetAttribute("updatePoints", true)

	task.defer(function()
		if player.Parent ~= Players then
			return
		end

		local profile = Profiles[player]
		if not profile then
			return
		end

		player:SetAttribute("updatePoints", false)
		updateClientPointsRemote:FireClient(player, profile.Data.Points)
	end)
end

function PlayerData.addPoints(player: Player, amount: number): boolean
	assert(amount > 0)
	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return false
	end

	if player:GetAttribute(Products.GamePasses.doubleBricks.attribute) then
		amount *= 2
	end

	profile.Data.Points += amount
	queuePointsUpdate(player)
	return true
end

function PlayerData.deductPoints(player: Player, amount: number)
	assert(amount > 0)
	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return
	end

	assert(profile.Data.Points >= amount)
	profile.Data.Points -= amount
	queuePointsUpdate(player)
end

function PlayerData.onDamageChanged(player: Player, callback: (number) -> ()): Signal.Connection?
	local signals = dataSignals[player]
	if not signals then
		return
	end

	return signals.Damage:Connect(callback)
end

function PlayerData.onPartsCollectedChanged(player: Player, callback: (number) -> ()): Signal.Connection?
	local signals = dataSignals[player]
	if not signals then
		return
	end

	return signals.PartsCollected:Connect(callback)
end

function PlayerData.onKOsChanged(player: Player, callback: (number) -> ()): Signal.Connection?
	local signals = dataSignals[player]
	if not signals then
		return
	end

	return signals.KOs:Connect(callback)
end

function PlayerData.onWinsChanged(player: Player, callback: (number) -> ()): Signal.Connection?
	local signals = dataSignals[player]
	if not signals then
		return
	end

	return signals.Wins:Connect(callback)
end

function PlayerData.onLevelsChanged(player: Player, callback: (number) -> ()): Signal.Connection?
	local signals = dataSignals[player]
	if not signals then
		return
	end

	return signals.Levels:Connect(callback)
end

function PlayerData.getStatLevel(player: Player, statId: number): number?
	local profile = Profiles[player]
	if not profile then
		return
	end

	return profile.Data.Levels[tostring(statId)]
end

function PlayerData.getPoints(player: Player): number?
	local profile = Profiles[player]
	if not profile then
		return
	end

	return profile.Data.Points
end

function PlayerData.upgradeStat(player: Player, statId: number)
	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return
	end

	local maxLevel = #Levels.LEVELS[statId]
	local strId = tostring(statId)
	assert(profile.Data.Levels[strId] < maxLevel)
	profile.Data.Levels[strId] += 1
	updateClientLevelsRemote:FireClient(player, { [strId] = profile.Data.Levels[strId] })
	signals.Levels:Fire(statId)
end

function PlayerData.getStat(player: Player?, statId: number): Levels.StatLevel
	local myLevel = player and PlayerData.getStatLevel(player, statId)
	return Levels.LEVELS[statId][myLevel or 1]
end

function PlayerData.waitForProfile(player: Player): boolean
	local profile = Profiles[player]
	while profile == nil and player.Parent == Players do
		profile = Profiles[player]
		if profile ~= nil then
			break
		end
		task.wait()
	end

	return profile ~= nil and profile:IsActive()
end

updateClientLevelsRemote.OnServerEvent:Connect(function(player: Player)
	local profile = Profiles[player]
	if not profile then
		return
	end

	updateClientLevelsRemote:FireClient(player, profile.Data.Levels)
end)

updateClientPointsRemote.OnServerEvent:Connect(function(player: Player)
	local profile = Profiles[player]
	if not profile then
		return
	end

	updateClientPointsRemote:FireClient(player, profile.Data.Points)
end)

return PlayerData
