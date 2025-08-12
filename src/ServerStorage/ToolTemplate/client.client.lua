--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local toolName = script.Parent.Name

require(ReplicatedStorage:WaitForChild("modules"):WaitForChild("game"):WaitForChild("tools"):WaitForChild(toolName))(
	script.Parent
)
