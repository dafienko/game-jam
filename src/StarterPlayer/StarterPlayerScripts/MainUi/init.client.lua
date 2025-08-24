--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local React = require(ReplicatedStorage.modules.dependencies.React)
local ReactRoblox = require(ReplicatedStorage.modules.dependencies.ReactRoblox)
local ParticlesUi = require(StarterPlayerScripts.ParticlesUi)

local MainUiComponent = require(script.MainUiComponent)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Main"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

ReactRoblox.createRoot(screenGui):render(React.createElement(MainUiComponent, {
	emitBrickFx = ParticlesUi.emit,
}))
