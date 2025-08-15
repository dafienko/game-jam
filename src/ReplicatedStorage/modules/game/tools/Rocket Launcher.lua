--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)

local camera = game.Workspace.CurrentCamera
local shootRocketAtPositionRemote = ReplicatedStorage.remotes.shootRocketAtPosition

return function(tool: Tool)
	local canShootAtTime = 0
	local debounce = false

	local function onActionInputAtScreenPosition(screenPosition: Vector2)
		if not GameUtil.isPlayerAlive(player) then
			return
		end

		if time() < canShootAtTime then
			return
		end

		if debounce then
			return
		end
		debounce = true

		local ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y, 0.1)
		local L = 400
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { player.Character }
		local res = game.Workspace:Raycast(ray.Origin, ray.Direction * L, params)
		local pos = if res then res.Position else ray.Origin + ray.Direction * L
		local cooldown = shootRocketAtPositionRemote:InvokeServer(tool, pos)
		if cooldown then
			canShootAtTime = time() + cooldown
		end
		debounce = false
	end

	tool.Equipped:Connect(function()
		if not GameUtil.isPlayerAlive(player) then
			return
		end

		local connections = {
			UserInputService.InputEnded:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					onActionInputAtScreenPosition(Vector2.new(input.Position.X, input.Position.Y))
				end
			end),

			UserInputService.TouchTap:Connect(function(positions, gameProcessed)
				if gameProcessed then
					return
				end

				if #positions ~= 1 then
					return
				end

				onActionInputAtScreenPosition(positions[1])
			end),
		}

		tool.Unequipped:Once(function()
			for _, v in connections do
				v:Disconnect()
			end
		end)
	end)
end
