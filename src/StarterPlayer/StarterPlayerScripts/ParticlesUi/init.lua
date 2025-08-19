--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local React = require(ReplicatedStorage.modules.dependencies.React)
local ReactRoblox = require(ReplicatedStorage.modules.dependencies.ReactRoblox)
local Signal = require(ReplicatedStorage.modules.dependencies.Signal)

local ParticleControllerComponent = require(script.ParticleControllerComponent)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Particles"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local emitSignal = Signal.new()
ReactRoblox.createRoot(screenGui):render(React.createElement(ParticleControllerComponent, { emitSignal = emitSignal }))

return {
	emit = function(n: number, source: Vector2, destination: Vector2)
		emitSignal:Fire(n, source, destination)
	end,
}
