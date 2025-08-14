--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)

local function placeholderComponent(LayoutOrder: number)
	return React.createElement("Frame", {
		LayoutOrder = LayoutOrder,
		BackgroundTransparency = 1,
	})
end

type Props = {
	LayoutOrder: number?,
	one: React.ReactElement<any, any>?,
	two: React.ReactElement<any, any>?,
	three: React.ReactElement<any, any>?,
}

return function(props: Props)
	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0.33, 8),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
	}, {
		layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalFlex = Enum.UIFlexAlignment.Fill,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 8),
		}),
		one = props.one or placeholderComponent(1),
		two = props.two or placeholderComponent(2),
		three = props.three or placeholderComponent(3),
	})
end
