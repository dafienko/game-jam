--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)

local ButtonComponent = require(script.Parent.Parent.ButtonComponent)

type Props = {
	LayoutOrder: number?,
	Text: string,
	Image: string,
	color: Color3,
	onActivated: (string) -> (),
}

return function(props: Props)
	return React.createElement(ButtonComponent, {
		color = props.color,
		LayoutOrder = props.LayoutOrder,
		onActivated = function()
			props.onActivated(props.Text)
		end,
	}, {
		image = React.createElement("ImageLabel", {
			Image = props.Image,
			Size = UDim2.fromScale(0.7, 0.7),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}),
		text = React.createElement("TextLabel", {
			Size = UDim2.fromScale(0.85, 0.35),
			Position = UDim2.fromScale(0.5, 0.9),
			AnchorPoint = Vector2.new(0.5, 1),
			ZIndex = 2,
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			Text = props.Text,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromHSV(0, 0, 0.2),
		}, {
			stroke = React.createElement("UIStroke", {
				Thickness = 3,
				Color = Color3.fromHSV(0, 0, 1),
			}),
		}),
	})
end
