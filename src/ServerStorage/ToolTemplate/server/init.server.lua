--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local tool = script.Parent
local toolName = tool.Name

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Transparency = 1
handle.CanCollide = false
handle.CanQuery = false
handle.CanTouch = false
handle.Massless = true
handle.Parent = tool

local model = ReplicatedStorage.assets.tools[toolName]:Clone()
model:PivotTo(handle.CFrame)
model.Name = "Model"

local w = Instance.new("WeldConstraint")
w.Part0 = handle
w.Part1 = model.PrimaryPart
w.Parent = handle

model.Parent = tool

local module = ServerScriptService.tools:FindFirstChild(toolName)
if module then
	require(module)(tool)
end
