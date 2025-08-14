--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ProfileStore = require(ReplicatedStorage.modules.dependencies.ProfileStore)
local Signal = require(ReplicatedStorage.modules.dependencies.Signal)

local PROFILE_TEMPLATE = {
	Studs = 0,
	KOs = 0,
	Wins = 0,
}
type ProfileData = typeof(PROFILE_TEMPLATE)

local PlayerStore = ProfileStore.New("PlayerStore", PROFILE_TEMPLATE)

type Profile = typeof(PlayerStore:StartSessionAsync(nil :: any, nil :: any))
local Profiles: { [Player]: Profile } = {}
local dataSignals: { [Player]: {
	Studs: Signal.Signal<number>,
	KOs: Signal.Signal<number>,
	Wins: Signal.Signal<number>,
} } =
	{}

local PlayerData = {}

function PlayerData.loadPlayerData(player: Player): ProfileData?
	dataSignals[player] = {
		Studs = Signal.new(),
		KOs = Signal.new(),
		Wins = Signal.new(),
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

	profile.OnSessionEnd:Connect(function()
		Profiles[player] = nil
		player:Kick(`Profile session end - Please rejoin`)
	end)

	if player.Parent ~= Players then
		profile:EndSession()
		return
	end

	Profiles[player] = profile
	return profile.Data
end

function PlayerData.unloadPlayerData(player: Player)
	local signals = dataSignals[player]
	if signals then
		signals.Studs:Destroy()
		signals.KOs:Destroy()
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

function PlayerData.updateStuds(player: Player, delta: number)
	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return
	end

	assert(profile.Data.Studs + delta > 0)
	profile.Data.Studs += delta
	signals.Studs:Fire(profile.Data.Studs)
end

function PlayerData.addKO(player: Player)
	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return
	end

	profile.Data.KOs += 1
	signals.KOs:Fire(profile.Data.KOs)
end

function PlayerData.addWin(player: Player)
	local profile = Profiles[player]
	local signals = dataSignals[player]
	if not (profile and signals) then
		return
	end

	profile.Data.Wins += 1
	signals.Wins:Fire(profile.Data.Wins)
end

function PlayerData.onStudsChanged(player: Player, callback: (number) -> ())
	local signals = dataSignals[player]
	if not signals then
		return
	end

	signals.Studs:Connect(callback)
end

function PlayerData.onKOsChanged(player: Player, callback: (number) -> ())
	local signals = dataSignals[player]
	if not signals then
		return
	end

	signals.KOs:Connect(callback)
end

function PlayerData.onWinsChanged(player: Player, callback: (number) -> ())
	local signals = dataSignals[player]
	if not signals then
		return
	end

	signals.Wins:Connect(callback)
end

return PlayerData
