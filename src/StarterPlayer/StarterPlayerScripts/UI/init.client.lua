--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local React = require(ReplicatedStorage.modules.dependencies.React)
local ReactRoblox = require(ReplicatedStorage.modules.dependencies.ReactRoblox)

local TimeRemainingComponent = require(script.TimeRemainingComponent)

local function mainUiComponent()
	return React.createElement(React.Fragment, nil, {
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
		timer = React.createElement(TimeRemainingComponent),
	})
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

ReactRoblox.createRoot(screenGui):render(React.createElement(mainUiComponent))
