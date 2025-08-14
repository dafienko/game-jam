--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(ServerScriptService.main.PlayerData)
local t = require(ReplicatedStorage.modules.dependencies.t)
local Levels = require(ReplicatedStorage.modules.game.Levels)

local StatsInterface = {}

function StatsInterface.onUpgradeStat(player: Player, statId: number)
	assert(t.number(statId))

	local points = PlayerData.getPoints(player)
	local currentLevel = PlayerData.getStatLevel(player, statId)
	if not (points and currentLevel) then
		error("missing player data not loaded")
	end

	local progression = Levels.LEVELS[statId]
	if currentLevel >= #progression then
		error("already max level")
	end

	local nextLevel = progression[currentLevel + 1]
	assert(points >= nextLevel.cost, `{points} < {nextLevel.cost}`)
	PlayerData.upgradeStat(player, statId)
	PlayerData.deductPoints(player, nextLevel.cost)
end

return StatsInterface
