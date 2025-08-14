--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)

type Props = {
	thumbnail: string?,
	name: string?,
	displayName: string?,
	valueString: string,
}

return function(props: Props)
	return React.createElement(React.Fragment, nil, {
		layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
		}),
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
		thumbnail = React.createElement("ImageLabel", {
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			Image = props.thumbnail or "",
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
		}),
		nameContainer = React.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
		}, {
			layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalFlex = Enum.UIFlexAlignment.SpaceBetween,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			}),
			displayName = React.createElement("TextLabel", {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0, 0.63),
				BackgroundTransparency = 1,
				TextScaled = true,
				TextColor3 = Color3.fromHSV(0, 0, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = props.displayName or "...",
			}),
			name = React.createElement("TextLabel", {
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				TextScaled = true,
				TextColor3 = Color3.fromHSV(0, 0, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = if props.name then `@{props.name}` else "...",
			}, {
				grow = React.createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Grow,
				}),
			}),
		}),
		value = React.createElement("TextLabel", {
			LayoutOrder = 3,
			BackgroundTransparency = 1,
			TextScaled = true,
			TextColor3 = Color3.fromHSV(0, 0, 1),
			Text = props.valueString,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.fromScale(0, 0.8),
		}, {
			grow = React.createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Grow,
			}),
		}),
	})
end
