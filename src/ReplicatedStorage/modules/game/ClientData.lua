--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = require(ReplicatedStorage.modules.game.Levels)
local Signal = require(ReplicatedStorage.modules.dependencies.Signal)

local clientLevels: { [number]: number } = {}
local levelChangedSignal = Signal.new()

ReplicatedStorage.remotes.updateClientLevels.OnClientEvent:Connect(function(update: { [string]: number })
	for i, v in clientLevels do
		local id = tonumber(i)
		assert(id, i)
		clientLevels[id] = v
		levelChangedSignal:Fire(id)
	end
end)
ReplicatedStorage.remotes.updateClientLevels:FireServer() -- signal server to update the client initial state

local ClientData = {
	LevelChanged = levelChangedSignal,
}

function ClientData.getStat(statId: number)
	local myLevel = clientLevels[statId] or 1
	return Levels.LEVELS[statId][myLevel]
end

return ClientData
