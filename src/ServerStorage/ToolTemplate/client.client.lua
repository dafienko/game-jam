--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local toolName = script.Parent.Name

local module =
	ReplicatedStorage:WaitForChild("modules"):WaitForChild("game"):WaitForChild("tools"):WaitForChild(toolName)
require(module)(script.Parent)
