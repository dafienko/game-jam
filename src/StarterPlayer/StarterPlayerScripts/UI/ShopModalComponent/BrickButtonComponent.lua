--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local player = game:GetService("Players").LocalPlayer

local React = require(ReplicatedStorage.modules.dependencies.React)

local ProductButtonComponent = require(script.Parent.ProductButtonComponent)

type Props = {
	LayoutOrder: number?,
	Text: string,
	imageText: string,
	productId: number,
}

return function(props: Props)
	return React.createElement(ProductButtonComponent, {
		LayoutOrder = props.LayoutOrder,
		productId = props.productId,
		infoType = Enum.InfoType.Product,
		Text = props.Text,
		onActivated = function()
			MarketPlaceService:PromptProductPurchase(player, props.productId)
		end,
	}, {
		bricks = React.createElement("TextLabel", {
			Size = UDim2.fromScale(0.9, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			Text = props.imageText,
			BackgroundTransparency = 1,
		}),
	})
end
