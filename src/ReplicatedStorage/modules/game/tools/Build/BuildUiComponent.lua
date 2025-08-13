--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)

type Props = {
	Text: string | React.Binding<string>,
	onNextItem: () -> (),
	onLastItem: () -> (),
}

return function(props: Props)
	return React.createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -90),
		Size = UDim2.fromOffset(130, 36),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.5,
		TextColor3 = Color3.fromHSV(0, 0, 1),
		Text = props.Text,
		TextScaled = false,
		TextSize = 18,
	}, {
		lastButton = React.createElement("TextButton", {
			Position = UDim2.new(0, -8, 0, 0),
			AnchorPoint = Vector2.new(1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = 0.5,
			TextColor3 = Color3.fromHSV(0, 0, 1),
			Text = "<",
			TextSize = 24,
			TextScaled = false,
			[React.Event.Activated] = props.onLastItem,
		}),
		nextButton = React.createElement("TextButton", {
			Position = UDim2.new(1, 8, 0, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = 0.5,
			TextColor3 = Color3.fromHSV(0, 0, 1),
			Text = ">",
			TextScaled = false,
			TextSize = 24,
			[React.Event.Activated] = props.onNextItem,
		}),
	})
end
