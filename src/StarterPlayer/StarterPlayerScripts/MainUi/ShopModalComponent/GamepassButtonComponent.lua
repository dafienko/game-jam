--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local player = game:GetService("Players").LocalPlayer

local React = require(ReplicatedStorage.modules.dependencies.React)

local ProductButtonComponent = require(script.Parent.ProductButtonComponent)

type Props = {
	LayoutOrder: number?,
	Text: string,
	Image: string,
	BackgroundColor3: Color3?,
	productId: number,
}

return function(props: Props)
	return React.createElement(ProductButtonComponent, {
		LayoutOrder = props.LayoutOrder,
		BackgroundColor3 = props.BackgroundColor3,
		productId = props.productId,
		infoType = Enum.InfoType.GamePass,
		Text = props.Text,
		onActivated = function()
			MarketPlaceService:PromptGamePassPurchase(player, props.productId)
		end,
	}, {
		image = React.createElement("ImageLabel", {
			Size = UDim2.fromScale(0.9, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = props.Image,
		}),
	})
end
