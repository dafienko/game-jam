--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local Products = require(ReplicatedStorage.modules.game.Products)

local UpgradeCategoryRowComponent = require(script.Parent.UpgradesModalComponent.UpgradeCategoryRowComponent)
local SurfaceComponent = require(script.Parent.SurfaceComponent)
local BrickButtonComponent = require(script.BrickButtonComponent)
local GamepassButtonComponent = require(script.GamepassButtonComponent)

type Props = {
	onExit: () -> (),
}

return function(props: Props)
	local currentPage, setCurrentPage: (string?) -> () = React.useState(nil :: string?)
	local layoutRef = (React.useRef(nil) :: any) :: { current: UIListLayout }
	local scrollingFrameRef = (React.useRef(nil) :: any) :: { current: ScrollingFrame }

	React.useEffect(function()
		local function updateCanvasSize()
			scrollingFrameRef.current.CanvasSize = UDim2.fromOffset(0, layoutRef.current.AbsoluteContentSize.Y)
		end

		local connection = layoutRef.current:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
		updateCanvasSize()

		return function()
			connection:Disconnect()
		end
	end, {})

	return React.createElement(SurfaceComponent, {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.9, 0.9),
		ZIndex = 99999,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(155, 255, 118),
		constraints = {
			aspect = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1.4,
			}),
			sizeConstraint = React.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(math.huge, 500),
			}),
		},
	}, {
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
		corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 8),
		}),
		headerRow = React.createElement("Frame", {
			Size = UDim2.fromOffset(0, 60),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}, {
			title = React.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Text = "Shop",
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.fromRGB(0, 0, 0),
			}),
			exit = React.createElement("TextButton", {
				Size = UDim2.fromScale(1, 1),
				Font = Enum.Font.FredokaOne,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(255, 100, 100),
				TextColor3 = Color3.fromHSV(0, 0, 1),
				Text = "X",
				BorderSizePixel = 0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Position = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				Modal = true,
				[React.Event.Activated] = props.onExit,
			}, {
				padding = React.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
				}),
				corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
			}),
			back = if currentPage ~= nil
				then React.createElement("TextButton", {
					Size = UDim2.fromScale(1, 1),
					Font = Enum.Font.FredokaOne,
					TextScaled = true,
					BackgroundColor3 = Color3.fromRGB(8, 141, 217),
					TextColor3 = Color3.fromHSV(0, 0, 1),
					Text = "<",
					BorderSizePixel = 0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Position = UDim2.fromScale(0, 0.5),
					AnchorPoint = Vector2.new(0, 0.5),
					[React.Event.Activated] = function()
						setCurrentPage(nil)
					end,
				}, {
					padding = React.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingTop = UDim.new(0, 8),
						PaddingBottom = UDim.new(0, 8),
					}),
					corner = React.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),
				})
				else nil,
		}),
		contentContainer = React.createElement("Frame", {
			LayoutOrder = 2,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHSV(0, 0, 0.8),
			ClipsDescendants = true,
		}, {
			padding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
			}),
			corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			grow = React.createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Grow,
			}),
			scrollingFrame = React.createElement("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				CanvasSize = UDim2.new(),
				BackgroundTransparency = 1,
				ScrollBarImageColor3 = Color3.new(),
				ScrollBarImageTransparency = 0,
				ScrollBarThickness = 1,
				ClipsDescendants = false,
				ref = scrollingFrameRef,
			}, {
				layout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, if currentPage then 0 else 8),
					ref = layoutRef,
				}),
				padding = React.createElement("UIPadding", {
					PaddingRight = UDim.new(0, 8),
				}),
				content = React.createElement(React.Fragment, nil, {
					productsHeader = React.createElement("TextLabel", {
						LayoutOrder = 1,
						Text = "- Dev Products -",
						Size = UDim2.new(1, 0, 0, 35),
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						TextColor3 = Color3.fromHSV(0, 0, 0.2),
					}),
					row1 = React.createElement(UpgradeCategoryRowComponent, {
						LayoutOrder = 2,
						one = React.createElement(BrickButtonComponent, {
							LayoutOrder = 1,
							imageText = "🧱",
							Text = Products.DevProducts.smallBrickPack.name,
							productId = Products.DevProducts.smallBrickPack.id,
						}),
						two = React.createElement(BrickButtonComponent, {
							LayoutOrder = 2,
							imageText = "🧱\n🧱🧱",
							Text = Products.DevProducts.mediumBrickPack.name,
							productId = Products.DevProducts.mediumBrickPack.id,
						}),
						three = React.createElement(BrickButtonComponent, {
							LayoutOrder = 3,
							imageText = "🧱🧱🧱\n🧱🧱🧱\n🧱🧱🧱",
							Text = Products.DevProducts.largeBrickPack.name,
							productId = Products.DevProducts.largeBrickPack.id,
						}),
					}),
					passesHeader = React.createElement("TextLabel", {
						LayoutOrder = 3,
						Text = "- Passes -",
						Size = UDim2.new(1, 0, 0, 35),
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						TextColor3 = Color3.fromHSV(0, 0, 0.2),
					}),
					row2 = React.createElement(UpgradeCategoryRowComponent, {
						LayoutOrder = 4,
						one = React.createElement(GamepassButtonComponent, {
							LayoutOrder = 1,
							BackgroundColor3 = Color3.new(),
							Image = "rbxassetid://91730383116453",
							Text = Products.GamePasses.tripleRocketLauncher.name,
							productId = Products.GamePasses.tripleRocketLauncher.id,
						}),
						two = React.createElement(GamepassButtonComponent, {
							LayoutOrder = 2,
							BackgroundColor3 = Color3.new(),
							Image = "rbxassetid://97929281785483",
							Text = Products.GamePasses.doubleBricks.name,
							productId = Products.GamePasses.doubleBricks.id,
						}),
					}),
				}),
			}),
		}),
	})
end
