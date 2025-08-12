--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local toolName = script.Parent.Name

require(ReplicatedStorage.modules.game.tools[toolName])(script.Parent)
