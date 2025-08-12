--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Transparency = 1
handle.CanCollide = false
handle.CanQuery = false
handle.CanTouch = false
handle.Massless = true
handle.Parent = script.Parent

local model = ReplicatedStorage.assets.tools[script.Parent.Name]:Clone()
model:PivotTo(handle.CFrame)

local w = Instance.new("WeldConstraint")
w.Part0 = handle
w.Part1 = model.PrimaryPart
w.Parent = handle

model.Parent = script.Parent
