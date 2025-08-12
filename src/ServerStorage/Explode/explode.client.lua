local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local camera = game.Workspace.CurrentCamera
local tool = script.Parent

tool.Activated:Connect(function()
	local pos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(pos.X, pos.Y, 0.1)
	local L = 400
	local result = game.Workspace:Raycast(ray.Origin, ray.Direction * L)
	local hitpos = ray.Origin + ray.Direction * L
	if result then
		hitpos = result.Position
	end

	ReplicatedStorage.remotes.explodeAt:FireServer(hitpos)
end)
