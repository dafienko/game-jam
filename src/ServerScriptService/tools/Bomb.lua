--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)
local PlayerData = require(ServerScriptService.main.PlayerData)
local Levels = require(ReplicatedStorage.modules.game.Levels)

local bombModel: Model = ReplicatedStorage.assets.bomb

local function getBombScale(player: Player): number
	return PlayerData.getStat(player, Levels.STAT_IDs.Bomb_Size).value
		/ Levels.LEVELS[Levels.STAT_IDs.Bomb_Size][1].value
end

local function dropBomb(cf: CFrame, player: Player)
	local bomb = bombModel:Clone()
	bomb:ScaleTo(getBombScale(player))
	bomb:PivotTo(cf)
	bomb:SetAttribute("fromUserId", player.UserId)
	bomb.Parent = game.Workspace
end

return function(tool: Tool, model: Model)
	local function updateModelSize(player: Player)
		model:ScaleTo(getBombScale(player))
	end

	tool.Destroying:Connect(function()
		model:Destroy()
	end)

	tool.Equipped:Connect(function()
		local char = tool.Parent
		local player = char and Players:GetPlayerFromCharacter(char)
		if not player then
			return
		end

		local connection = PlayerData.onLevelsChanged(player, function(statId)
			if statId == Levels.STAT_IDs.Bomb_Size then
				updateModelSize(player)
			end
		end)

		tool.Unequipped:Once(function()
			if connection then
				connection:Disconnect()
			end
		end)
	end)

	tool.Activated:Connect(function()
		local player = Players:GetPlayerFromCharacter(tool.Parent)
		if not player then
			return
		end

		if not GameUtil.isPlayerAlive(player) then
			return
		end

		model.Parent = nil
		tool.Enabled = false

		dropBomb(model:GetPivot() * CFrame.new(0, 0, -3), player)
		task.wait(PlayerData.getStat(player, Levels.STAT_IDs.Bomb_Cooldown).value)

		model.Parent = tool
		tool.Enabled = true
	end)
end
