--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local React = require(ReplicatedStorage.modules.dependencies.React)
local ReactRoblox = require(ReplicatedStorage.modules.dependencies.ReactRoblox)

local TimeRemainingComponent = require(script.TimeRemainingComponent)
local WinDialogComponent = require(script.WinDialogComponent)
local TeamScoresComponent = require(script.TeamScoresComponent)

local function mainUiComponent()
	return React.createElement(React.Fragment, nil, {
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
		topContainer = React.createElement("Frame", {
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
		}, {
			layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 20),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			timer = React.createElement(TimeRemainingComponent, { LayoutOrder = 1 }),
			scores = React.createElement(TeamScoresComponent, { LayoutOrder = 2 }),
		}),
		winDialog = React.createElement(WinDialogComponent),
	})
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

ReactRoblox.createRoot(screenGui):render(React.createElement(mainUiComponent))
