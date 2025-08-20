--!strict

local char = script.Parent
local humanoid = char:FindFirstChildOfClass("Humanoid")
assert(humanoid)

local camera = game.Workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Custom
camera.CameraSubject = humanoid

humanoid.Died:Once(function()
	camera.CameraSubject = nil
	camera.CameraType = Enum.CameraType.Fixed
end)
