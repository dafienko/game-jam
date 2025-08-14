--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)

local bombModel = ReplicatedStorage.assets.bomb

local function dropBomb(cf: CFrame, player: Player)
	local bomb = bombModel:Clone()
	bomb:PivotTo(cf)
	bomb:SetAttribute("fromUserId", player.UserId)
	bomb.Parent = game.Workspace
end

return function(tool: Tool, model: Model)
	tool.Destroying:Connect(function()
		model:Destroy()
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
		task.wait(3.5)

		model.Parent = tool
		tool.Enabled = true
	end)
end
