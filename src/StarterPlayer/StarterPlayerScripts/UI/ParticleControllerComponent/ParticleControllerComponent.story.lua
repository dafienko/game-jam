--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local ReactRoblox = require(ReplicatedStorage.modules.dependencies.ReactRoblox)
local Signal = require(ReplicatedStorage.modules.dependencies.Signal)

local ParticleControllerComponent = require(script.Parent)

return function(target: any)
	local mounted = true
	local emitSignal = Signal.new()

	local root = ReactRoblox.createRoot(target)
	local targetRef = React.createRef()
	root:render(React.createElement(React.Fragment, nil, {
		target = React.createElement("Frame", {
			ref = targetRef,
			Position = UDim2.fromScale(0, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(80, 80),
		}),
		particlesController = React.createElement(ParticleControllerComponent, {
			targetRef = targetRef,
			emitSignal = emitSignal,
		}),
	}))

	task.spawn(function()
		while mounted do
			emitSignal:Fire(
				math.random(3, 12),
				Vector2.new(target.AbsoluteSize.X * math.random(), target.AbsoluteSize.Y * math.random())
			)
			task.wait(1)
		end
	end)

	return function()
		mounted = false
		root:unmount()
	end
end
