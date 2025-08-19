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
	root:render(React.createElement(ParticleControllerComponent, {
		emitSignal = emitSignal,
	}))

	task.spawn(function()
		while mounted do
			emitSignal:Fire(
				math.random(3, 12),
				Vector2.new(target.AbsoluteSize.X * math.random(), target.AbsoluteSize.Y * math.random()),
				target.AbsoluteSize / 2
			)
			task.wait(1)
		end
	end)

	return function()
		mounted = false
		root:unmount()
	end
end
