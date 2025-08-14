--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local Levels = require(ReplicatedStorage.modules.game.Levels)
local Signal = require(ReplicatedStorage.modules.dependencies.Signal)

local clientLevels: { [number]: number } = {}
local clientPoints = 0
local levelChangedSignal = Signal.new()
local pointsChangedSignal = Signal.new()

ReplicatedStorage.remotes.updateClientLevels.OnClientEvent:Connect(function(update: { [string]: number })
	for i, v in update do
		local id = tonumber(i)
		assert(id, i)
		clientLevels[id] = v
		levelChangedSignal:Fire(id)
	end
end)

ReplicatedStorage.remotes.updateClientPoints.OnClientEvent:Connect(function(points)
	clientPoints = points
	pointsChangedSignal:Fire(points)
end)

local ClientData = {
	LevelChanged = levelChangedSignal,
}

function ClientData.getLevel(statId: number): number
	return clientLevels[statId] or 1
end

function ClientData.getStat(statId: number)
	return Levels.LEVELS[statId][ClientData.getLevel(statId)]
end

function ClientData.useStatLevel(statId: number): number
	local level, setLevel = React.useState(clientLevels[statId] or 1)

	React.useEffect(function()
		setLevel(clientLevels[statId] or 1)

		local connection = levelChangedSignal:Connect(function(changedStatId)
			if statId == changedStatId then
				setLevel(clientLevels[statId])
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, { statId })

	return level
end

function ClientData.useLevels(): typeof(clientLevels)
	local levels, setLevels = React.useState(table.clone(clientLevels))

	React.useEffect(function()
		local connection = levelChangedSignal:Connect(function()
			setLevels(table.clone(clientLevels))
		end)

		return function()
			connection:Disconnect()
		end
	end)

	return levels
end

function ClientData.usePoints(): number
	local points, setPoints = React.useState(clientPoints)

	React.useEffect(function()
		local connection = pointsChangedSignal:Connect(setPoints)

		return function()
			connection:Disconnect()
		end
	end)

	return points
end

task.spawn(function()
	-- signal server to update the client initial state
	ReplicatedStorage.remotes.updateClientLevels:FireServer()
	ReplicatedStorage.remotes.updateClientPoints:FireServer()
end)

return ClientData
