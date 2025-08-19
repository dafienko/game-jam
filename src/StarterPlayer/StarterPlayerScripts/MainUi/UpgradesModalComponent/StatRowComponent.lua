--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local player = game:GetService("Players").LocalPlayer

local React = require(ReplicatedStorage.modules.dependencies.React)
local Levels = require(ReplicatedStorage.modules.game.Levels)
local ClientData = require(ReplicatedStorage.modules.game.ClientData)
local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)
local Products = require(ReplicatedStorage.modules.game.Products)

local ButtonComponent = require(script.Parent.Parent.ButtonComponent)

type Props = {
	LayoutOrder: number,
	statId: number,
	name: string,
	description: string,
}

local function formatNumber(n: number)
	return ("%.2f"):format(n)
end

return function(props: Props)
	local level = ClientData.useStatLevel(props.statId)
	local progression = Levels.LEVELS[props.statId]
	local stat = progression[level]
	local isMaxLevel = level >= #progression
	local nextStat = if isMaxLevel then nil else progression[level + 1]
	local points = ClientData.usePoints()
	local canAfford = nextStat and points >= nextStat.cost
	local delta = if nextStat then nextStat.value - stat.value else 0

	local disabled, setDisabled = React.useState(false)
	local debounce = React.useRef(false)
	local onBuy = React.useCallback(function()
		if debounce.current then
			return
		end
		debounce.current = true
		setDisabled(true)

		xpcall(function(...)
			if canAfford then
				ReplicatedStorage.remotes.upgradeStat:InvokeServer(props.statId)
			else
				local needsPoints = if nextStat then nextStat.cost - points else 0
				local productId = Products.DevProducts.smallBrickPack.id
				if needsPoints >= 15000 then
					productId = Products.DevProducts.largeBrickPack.id
				elseif needsPoints >= 3500 then
					productId = Products.DevProducts.mediumBrickPack.id
				end

				MarketPlaceService:PromptProductPurchase(player, productId)
			end
		end, warn)

		setDisabled(false)
		debounce.current = false
	end, { level, points, props.statId })

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1 - (props.LayoutOrder % 2) * 0.1,
		Size = UDim2.new(1, 0, 0, 80),
		BackgroundColor3 = Color3.new(),
	}, {
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
		layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalFlex = Enum.UIFlexAlignment.Fill,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
		left = React.createElement("Frame", {
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.6, 0),
		}, {
			layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
			}),
			name = React.createElement("TextLabel", {
				Text = `<b>{props.name}:</b> <i>{stat.value}</i>`,
				RichText = true,
				Size = UDim2.fromScale(0, 0.45),
				BackgroundTransparency = 1,
				TextSize = 30,
				Font = Enum.Font.SourceSans,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = Color3.fromHSV(0, 0, 0.3),
			}),
			description = React.createElement("TextLabel", {
				Text = props.description,
				TextScaled = true,
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSans,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = Color3.fromHSV(0, 0, 0.3),
			}, {
				grow = React.createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Grow,
				}),
				textSize = React.createElement("UITextSizeConstraint", {
					MaxTextSize = 22,
				}),
			}),
		}),
		right = React.createElement("Frame", {
			LayoutOrder = 2,
			BackgroundTransparency = 1,
		}, {
			grow = React.createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Grow,
			}),
			content = if nextStat
				then React.createElement(ButtonComponent, {
					Size = UDim2.fromScale(1, 1),
					color = if canAfford then Color3.fromRGB(40, 205, 40) else Color3.fromRGB(255, 100, 100),
					disabled = disabled,
					onActivated = onBuy,
				}, {
					layout = React.createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 2),
					}),
					padding = React.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 6),
						PaddingRight = UDim.new(0, 6),
						PaddingTop = UDim.new(0, 6),
						PaddingBottom = UDim.new(0, 6),
					}),
					upgrade = React.createElement("TextLabel", {
						LayoutOrder = 1,
						Text = `Upgrade: {GameUtil.commaNumber(nextStat.cost)} 🧱`,
						BackgroundTransparency = 1,
						TextScaled = true,
						Size = UDim2.fromScale(0, 0.5),
						TextColor3 = Color3.fromHSV(0, 0, 1),
						TextStrokeTransparency = 0.9,
						Font = Enum.Font.SourceSansBold,
					}),
					desc = React.createElement("TextLabel", {
						LayoutOrder = 2,
						Text = `{formatNumber(stat.value)} -> {formatNumber(nextStat.value)} <b>({if delta > 0
							then "+"
							else ""}{formatNumber(delta)})</b>`,
						RichText = true,
						BackgroundTransparency = 1,
						TextScaled = true,
						TextColor3 = Color3.fromHSV(0, 0, 0.2),
						Font = Enum.Font.SourceSans,
					}, {
						grow = React.createElement("UIFlexItem", {
							FlexMode = Enum.UIFlexMode.Grow,
						}),
					}),
				})
				else React.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					TextSize = 30,
					Text = "Max Level",
					Font = Enum.Font.SourceSansLight,
					TextColor3 = Color3.fromHSV(0, 0, 0.3),
				}),
		}),
	})
end
