--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)

local ButtonComponent = require(script.Parent.Parent.ButtonComponent)

type Props = {
	LayoutOrder: number?,
	productId: number,
	Text: string,
	infoType: Enum.InfoType,
	onActivated: () -> (),
}

return function(props: Props)
	local price = GameUtil.useProductInfo(props.productId, props.infoType)

	return React.createElement(ButtonComponent, {
		color = Color3.fromHSV(0, 0, 1),
		LayoutOrder = props.LayoutOrder,
		ClipsDescendants = true,
		onActivated = props.onActivated,
	}, {
		priceLabel = if price
			then React.createElement("TextLabel", {
				Position = UDim2.fromOffset(12, 12),
				Size = UDim2.fromScale(0.6, 0.15),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = `{GameUtil.commaNumber(price)} `,
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromHSV(0, 0, 0.2),
			}, {
				stroke = React.createElement("UIStroke", {
					Thickness = 3,
					Color = Color3.fromHSV(0, 0, 1),
				}),
			})
			else nil,
		dropShadow = React.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 0.3),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			ImageTransparency = 0.3,
			ZIndex = 2,
		}, {
			padding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0.15, 0),
				PaddingRight = UDim.new(0.15, 0),
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
			}),
			text = React.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				Text = props.Text,
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromHSV(0, 0, 0.2),
			}, {
				stroke = React.createElement("UIStroke", {
					Thickness = 3,
					Color = Color3.fromHSV(0, 0, 1),
				}),
			}),
		}),
		children = React.createElement(React.Fragment, nil, (props :: any).children),
	})
end
