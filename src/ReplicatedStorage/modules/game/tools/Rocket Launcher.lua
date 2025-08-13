--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local camera = game.Workspace.CurrentCamera
local shootRocketAtPositionRemote = ReplicatedStorage.remotes.shootRocketAtPosition

return function(tool: Tool)
	local canShootAtTime = 0
	local cooldown = 1

	local function onActionInputAtScreenPosition(screenPosition: Vector2)
		if time() < canShootAtTime then
			return
		end

		local ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y, 0.1)
		local L = 400
		local res = game.Workspace:Raycast(ray.Origin, ray.Direction * L)
		local pos = if res then res.Position else ray.Origin + ray.Direction * L
		canShootAtTime = time() + cooldown
		shootRocketAtPositionRemote:FireServer(tool, pos)
	end

	tool.Equipped:Connect(function()
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
