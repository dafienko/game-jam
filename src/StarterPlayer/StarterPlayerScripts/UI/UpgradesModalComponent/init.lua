--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local Levels = require(ReplicatedStorage.modules.game.Levels)

local SurfaceComponent = require(script.Parent.SurfaceComponent)
local UpgradeCategoryRowComponent = require(script.UpgradeCategoryRowComponent)
local UpgradeCategoryButtonComponent = require(script.UpgradeCategoryButtonComponent)
local StatRowComponent = require(script.StatRowComponent)

local PageNames = {
	RocketLauncher = "Rocket Launcher",
	Bomb = "Bomb",
	Build = "Build",
	Character = "Character",
}

local Pages = {
	[PageNames.RocketLauncher] = {
		cooldown = React.createElement(StatRowComponent, {
			LayoutOrder = 1,
			name = "Cooldown",
			description = [[How long it takes to reload]],
			statId = Levels.STAT_IDs.RocketLauncher_Cooldown,
		}),
		size = React.createElement(StatRowComponent, {
			LayoutOrder = 2,
			name = "Blast Radius",
			description = [[How large explosions are]],
			statId = Levels.STAT_IDs.RocketLauncher_Size,
		}),
		power = React.createElement(StatRowComponent, {
			LayoutOrder = 3,
			name = "Power",
			description = [[How destructive explosions are]],
			statId = Levels.STAT_IDs.RocketLauncher_Power,
		}),
	},
	[PageNames.Bomb] = {
		cooldown = React.createElement(StatRowComponent, {
			LayoutOrder = 1,
			name = "Cooldown",
			description = [[How long it takes to reload]],
			statId = Levels.STAT_IDs.Bomb_Cooldown,
		}),
		size = React.createElement(StatRowComponent, {
			LayoutOrder = 2,
			name = "Blast Radius",
			description = [[How large explosions are]],
			statId = Levels.STAT_IDs.Bomb_Size,
		}),
		power = React.createElement(StatRowComponent, {
			LayoutOrder = 3,
			name = "Power",
			description = [[How destructive explosions are]],
			statId = Levels.STAT_IDs.Bomb_Power,
		}),
	},
	[PageNames.Build] = {
		cooldown = React.createElement(StatRowComponent, {
			LayoutOrder = 1,
			name = "Cooldown",
			description = [[How long you have to wait between builds]],
			statId = Levels.STAT_IDs.Build_Cooldown,
		}),
		wallSize = React.createElement(StatRowComponent, {
			LayoutOrder = 2,
			name = "Wall Width",
			description = [[How wide your wall is]],
			statId = Levels.STAT_IDs.Build_Wall_Width,
		}),
		wallHeight = React.createElement(StatRowComponent, {
			LayoutOrder = 3,
			name = "Wall Height",
			description = [[How tall your wall is]],
			statId = Levels.STAT_IDs.Build_Wall_Height,
		}),
		bridgeSize = React.createElement(StatRowComponent, {
			LayoutOrder = 4,
			name = "Bridge Width",
			description = [[How wide your bridge is]],
			statId = Levels.STAT_IDs.Build_Bridge_Width,
		}),
		bridgeHeight = React.createElement(StatRowComponent, {
			LayoutOrder = 5,
			name = "Bridge Length",
			description = [[How long your bridge is]],
			statId = Levels.STAT_IDs.Build_Bridge_Length,
		}),
	},
	[PageNames.Character] = {
		walkSpeed = React.createElement(StatRowComponent, {
			LayoutOrder = 1,
			name = "Walk Speed",
			description = [[How fast you can move]],
			statId = Levels.STAT_IDs.Character_WalkSpeed,
		}),
		jumpHeight = React.createElement(StatRowComponent, {
			LayoutOrder = 2,
			name = "Jump Height",
			description = [[How high you can jump]],
			statId = Levels.STAT_IDs.Character_JumpHeight,
		}),
	},
} :: { [string]: any }

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
		BackgroundColor3 = Color3.fromHSV(0, 0, 1),
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
				Text = "Upgrades",
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
				content = if currentPage
					then React.createElement(React.Fragment, nil, {
						React.createElement("TextLabel", {
							Text = currentPage,
							TextColor3 = Color3.fromHSV(0, 0, 0.2),
							TextScaled = true,
							Size = UDim2.new(1, 0, 0, 42),
							Font = Enum.Font.SourceSansBold,
							BackgroundTransparency = 1,
						}, {
							padding = React.createElement("UIPadding", {
								PaddingBottom = UDim.new(0, 8),
							}),
						}),
						React.createElement(React.Fragment, nil, Pages[currentPage]),
					})
					else React.createElement(React.Fragment, nil, {
						row1 = React.createElement(UpgradeCategoryRowComponent, {
							LayoutOrder = 1,
							one = React.createElement(UpgradeCategoryButtonComponent, {
								LayoutOrder = 1,
								color = Color3.fromRGB(255, 144, 144),
								Text = PageNames.RocketLauncher,
								Image = "rbxassetid://113185817926704",
								onActivated = setCurrentPage,
							}),
							two = React.createElement(UpgradeCategoryButtonComponent, {
								LayoutOrder = 2,
								color = Color3.fromRGB(255, 199, 116),
								Text = PageNames.Bomb,
								Image = "rbxassetid://13823733",
								onActivated = setCurrentPage,
							}),
							three = React.createElement(UpgradeCategoryButtonComponent, {
								LayoutOrder = 3,
								color = Color3.fromRGB(132, 183, 255),
								Text = PageNames.Build,
								Image = "rbxassetid://18209589139",
								onActivated = setCurrentPage,
							}),
						}),
						row2 = React.createElement(UpgradeCategoryRowComponent, {
							LayoutOrder = 2,
							one = React.createElement(UpgradeCategoryButtonComponent, {
								LayoutOrder = 1,
								color = Color3.fromRGB(156, 255, 162),
								Text = PageNames.Character,
								Image = "rbxassetid://6877509129",
								onActivated = setCurrentPage,
							}),
						}),
					}),
			}),
		}),
	})
end
