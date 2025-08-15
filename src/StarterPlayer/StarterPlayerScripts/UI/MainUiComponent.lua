--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local ClientData = require(ReplicatedStorage.modules.game.ClientData)
local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)
local Levels = require(ReplicatedStorage.modules.game.Levels)

local TimeRemainingComponent = require(script.Parent.TimeRemainingComponent)
local WinDialogComponent = require(script.Parent.WinDialogComponent)
local TeamScoresComponent = require(script.Parent.TeamScoresComponent)
local UpgradesModalComponent = require(script.Parent.UpgradesModalComponent)
local ShopModalComponent = require(script.Parent.ShopModalComponent)
local ButtonComponent = require(script.Parent.ButtonComponent)

local function PointsComponent(props: { LayoutOrder: number })
	local points = ClientData.usePoints()

	return React.createElement("TextLabel", {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 0.2),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		BackgroundTransparency = 1,
		Text = `{GameUtil.commaNumber(points)} 🧱`,
		TextScaled = true,
		Font = Enum.Font.SourceSansBold,
		TextColor3 = Color3.fromHSV(0, 0, 1),
	}, {
		stroke = React.createElement("UIStroke", {
			Thickness = 1,
			Color = Color3.fromHSV(0, 0, 0.3),
		}),
	})
end

local function UpgradesButtonComponent(props: { LayoutOrder: number, onActivated: () -> () })
	local points = ClientData.usePoints()
	local levels = ClientData.useLevels()
	local upgradesAvailable, setUpgradesAvailable = React.useState(10)
	React.useEffect(function()
		local n = 0
		for statId, progression in Levels.LEVELS do
			local level = levels[statId] or 1
			local nextLevel = progression[level + 1]
			if level >= #progression or not nextLevel then
				continue
			end

			if points < nextLevel.cost then
				continue
			end

			n += 1
		end

		setUpgradesAvailable(n)
	end, { points, levels } :: { any })

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.45),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
	}, {
		notification = if upgradesAvailable > 0
			then React.createElement("TextLabel", {
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromOffset(30, 30),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 100, 100),
				TextColor3 = Color3.fromHSV(0, 0, 1),
				Text = tostring(upgradesAvailable),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
			}, {
				padding = React.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
					PaddingTop = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
				}),
				corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0),
				}),
			})
			else nil,
		button = React.createElement(ButtonComponent, {
			Size = UDim2.fromScale(1, 1),
			onActivated = props.onActivated,
		}, {
			text = React.createElement("TextLabel", {
				Text = "Upgrades",
				Size = UDim2.fromScale(0.7, 0.9),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.new(),
				BackgroundTransparency = 1,
			}),
		}),
	})
end

local Modals = {
	None = 1,
	Upgrades = 2,
	Shop = 3,
}

return function()
	local modal, setModal = React.useState(nil :: any)
	local onUpgradesPressed = React.useCallback(function()
		setModal(function(current)
			if current == Modals.Upgrades then
				return Modals.None
			else
				return Modals.Upgrades
			end
		end)
	end, {})

	local onShopPressed = React.useCallback(function()
		setModal(function(current)
			if current == Modals.Shop then
				return Modals.None
			else
				return Modals.Shop
			end
		end)
	end, {})

	local onExitModal = React.useCallback(function()
		setModal(Modals.None)
	end, {})

	return React.createElement(React.Fragment, nil, {
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
		topContainer = React.createElement("Frame", {
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
		}, {
			layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 20),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			timer = React.createElement(TimeRemainingComponent, { LayoutOrder = 1 }),
			scores = React.createElement(TeamScoresComponent, { LayoutOrder = 2 }),
		}),
		winDialog = React.createElement(WinDialogComponent),
		leftContainer = React.createElement("Frame", {
			Position = UDim2.fromScale(0, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromScale(0.12, 1),
			BackgroundTransparency = 1,
		}, {
			sizeConstraint = React.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(120, math.huge),
			}),
			layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 20),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			points = React.createElement(PointsComponent, {
				LayoutOrder = 1,
			}),
			upgradesButton = React.createElement(UpgradesButtonComponent, {
				LayoutOrder = 2,
				onActivated = onUpgradesPressed,
			}),
			shopButton = React.createElement(ButtonComponent, {
				LayoutOrder = 3,
				Size = UDim2.fromScale(1, 0.45),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				color = Color3.fromRGB(155, 255, 118),
				onActivated = onShopPressed,
			}, {
				text = React.createElement("TextLabel", {
					Text = "Shop",
					Size = UDim2.fromScale(0.7, 0.9),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					TextColor3 = Color3.new(),
					BackgroundTransparency = 1,
				}),
			}),
		}),
		upgradesModal = if modal == Modals.Upgrades
			then React.createElement(UpgradesModalComponent, { onExit = onExitModal })
			else nil,
		shopModal = if modal == Modals.Shop
			then React.createElement(ShopModalComponent, { onExit = onExitModal })
			else nil,
	})
end
