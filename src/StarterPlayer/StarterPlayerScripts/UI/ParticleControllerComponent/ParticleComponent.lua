--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.modules.dependencies.React)

type Props = {
	spawnAtPosition: Vector2?,
	destinationPosition: Vector2?,

	onComplete: () -> (),
}

local function randomDir()
	local theta = math.random() * 2 * math.pi
	return Vector2.new(math.cos(theta), math.sin(theta))
end

local function a1(alpha: number, spreadAlpha: number)
	return TweenService:GetValue(math.min(1, alpha / spreadAlpha), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
end

local function a2(alpha: number, moveDelay: number): number
	return TweenService:GetValue(
		math.clamp((alpha - moveDelay) / (1 - moveDelay), 0, 1),
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In
	)
end

return function(props: Props)
	local visible, setVisible = React.useState(false)
	local alphaBinding, setAlphaBinding = React.useBinding(1)
	local alphaRef = React.useRef(0)
	local dirRef = React.useRef(randomDir())
	local spread = React.useRef(0)
	local moveDelay = React.useRef(0)
	local speed = React.useRef(1)
	local spreadAlpha = React.useRef(0)

	local initialized = React.useRef(false)
	React.useEffect(function()
		if not initialized.current then
			initialized.current = true
			return
		end

		dirRef.current = randomDir()
		spread.current = math.random() * 90
		moveDelay.current = 0.4 + math.random() * 0.14
		speed.current = 0.35 + math.random() * 0.1
		spreadAlpha.current = 0.1 + math.random() * 0.1
		alphaRef.current = 0
		setVisible(true)
		setAlphaBinding(0)
	end, { props.spawnAtPosition })

	React.useEffect(function()
		local connection
		if alphaRef.current < 1 then
			connection = RunService.RenderStepped:Connect(function(dt: number)
				alphaRef.current = math.min(1, alphaRef.current + dt * speed.current)

				setAlphaBinding(alphaRef.current)
				if alphaRef.current == 1 then
					connection:Disconnect()
					setVisible(false)
					props.onComplete()
				end
			end)
		end

		return function() end
	end, { props.onComplete } :: { any })

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = alphaBinding:map(function(alpha: number): UDim2?
			if not (props.spawnAtPosition and props.destinationPosition) then
				return nil
			end

			local spreadOffset = dirRef.current * spread.current * a1(alpha, spreadAlpha.current)
			local p = (props.spawnAtPosition + spreadOffset):Lerp(
				props.destinationPosition,
				a2(alpha, moveDelay.current)
			)

			return UDim2.fromOffset(p.X, p.Y)
		end),
		Size = alphaBinding:map(function(alpha: number): UDim2?
			local s = 25
			s -= s * a2(alpha, moveDelay.current)
			return UDim2.fromOffset(s, s)
		end),
		Visible = visible,
	}, {
		text = React.createElement("TextLabel", {
			Text = "🧱",
			TextScaled = true,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}),
	})
end
