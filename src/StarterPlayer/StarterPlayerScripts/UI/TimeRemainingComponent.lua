--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)

return function()
	local secondsRemaining, setSecondsRemaining = React.useState(game.Workspace:GetAttribute("timeRemaining") or 0)
	React.useEffect(function()
		local connection = game.Workspace:GetAttributeChangedSignal("timeRemaining"):Connect(function()
			setSecondsRemaining(game.Workspace:GetAttribute("timeRemaining"))
		end)
		return function()
			connection:Disconnect()
		end
	end)

	local minutes = secondsRemaining // 60
	local seconds = secondsRemaining - minutes * 60
	return React.createElement("TextLabel", {
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(80, 40),
		TextScaled = true,
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.7,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		TextColor3 = Color3.fromHSV(0, 0, 1),
		Text = ("%02i:%02i"):format(minutes, seconds),
	}, {
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
	})
end
