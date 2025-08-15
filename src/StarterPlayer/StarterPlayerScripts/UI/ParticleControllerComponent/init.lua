--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cryo = require(ReplicatedStorage.modules.dependencies.Cryo)
local React = require(ReplicatedStorage.modules.dependencies.React)
local Signal = require(ReplicatedStorage.modules.dependencies.Signal)

local ParticleComponent = require(script.ParticleComponent)

local POOL_SIZE = 40

type Props = {
	targetRef: { current: GuiObject? },
	emitSignal: Signal.Signal<(number, Vector2)>,
}

local function getGuiObjectCenter(object: GuiObject): Vector2
	return object.AbsolutePosition
		+ object.AbsoluteSize / 2
		- (if object.Parent and object.Parent:IsA("GuiObject") then object.Parent.AbsolutePosition else Vector2.zero)
end

return function(props: Props)
	local childrenRef = React.useRef({})
	for i = 1, POOL_SIZE do
		local spawnPosition, setSpawnPosition = React.useState(nil :: Vector2?)
		local destinationPosition, setDestinationPosition =
			React.useState(if props.targetRef.current then getGuiObjectCenter(props.targetRef.current) else nil)

		local availableRef = React.useRef(true)
		local onComplete = React.useCallback(function()
			availableRef.current = true
		end)

		childrenRef.current[tostring(i)] = {
			spawnPosition = spawnPosition,
			setSpawnPosition = setSpawnPosition,
			destinationPosition = destinationPosition,
			setDestinationPosition = setDestinationPosition,
			availableRef = availableRef,
			onComplete = onComplete,
		}
	end

	React.useEffect(function()
		local connection = props.emitSignal:Connect(function(amount, position)
			for _, particle in childrenRef.current do
				if not particle.availableRef.current then
					continue
				end

				particle.availableRef.current = false
				particle.setSpawnPosition(position)
				particle.setDestinationPosition(
					if props.targetRef.current then getGuiObjectCenter(props.targetRef.current) else nil
				)

				amount -= 1
				if amount <= 0 then
					break
				end
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, { props.emitSignal })

	return React.createElement(
		React.Fragment,
		nil,
		Cryo.Dictionary.map(childrenRef.current, function(v)
			return React.createElement(ParticleComponent, {
				BackgroundColor3 = Color3.fromHSV(0, 0, 1),
				spawnAtPosition = v.spawnPosition,
				destinationPosition = v.destinationPosition,
				onComplete = v.onComplete,
			})
		end) :: any
	)
end
