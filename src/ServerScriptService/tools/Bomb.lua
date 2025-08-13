--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
		model.Parent = nil
		tool.Enabled = false

		local player = Players:GetPlayerFromCharacter(tool.Parent)
		if player then
			dropBomb(model:GetPivot() * CFrame.new(0, 0, -3), player)
		end

		task.wait(6)
		model.Parent = tool
		tool.Enabled = true
	end)
end
