--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)

local IDLE_OFFSET = 3
local HOVER_OFFSET = 4
local PRESS_OFFSET = 0
local DISABLED_OFFSET = 0

type Props = {
	Size: UDim2?,
	SizeConstraint: Enum.SizeConstraint?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	LayoutOrder: number?,
	ClipsDescendants: boolean?,
	disabled: boolean?,
	color: Color3?,
	hoverColor: Color3?,
	pressColor: Color3?,
	disabledColor: Color3?,
	onActivated: (() -> ())?,
}

return function(props: Props)
	local ref = (React.useRef(nil) :: any) :: { current: ImageButton }
	local state, setState = React.useState(Enum.GuiState.Idle)
	React.useEffect(function()
		local connection = ref.current:GetPropertyChangedSignal("GuiState"):Connect(function()
			setState(ref.current.GuiState)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	local color = props.color or Color3.fromHSV(0, 0, 1)
	local yOffset = IDLE_OFFSET
	local buttonColor = color
	if props.disabled then
		yOffset = DISABLED_OFFSET
		buttonColor = props.disabledColor or color:Lerp(Color3.new(), 0.2)
	elseif state == Enum.GuiState.Press then
		yOffset = PRESS_OFFSET
		buttonColor = props.pressColor or color:Lerp(Color3.new(), 0.1)
	elseif state == Enum.GuiState.Hover then
		yOffset = HOVER_OFFSET
		buttonColor = props.hoverColor or color:Lerp(Color3.fromHSV(0, 0, 1), 0.1)
	end

	return React.createElement("ImageButton", {
		ref = ref,
		Size = props.Size,
		SizeConstraint = props.SizeConstraint,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Active = not props.disabled,
		Selectable = not props.disabled,
		[React.Event.Activated] = props.onActivated,
	}, {
		bottom = React.createElement("Frame", {
			BackgroundColor3 = color:Lerp(Color3.new(), 0.5),
			Size = UDim2.new(1, 0, 1, -math.max(IDLE_OFFSET, HOVER_OFFSET, PRESS_OFFSET)),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			BorderSizePixel = 0,
		}, {
			corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			float = React.createElement("Frame", {
				ClipsDescendants = props.ClipsDescendants,
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = buttonColor,
				Position = UDim2.fromOffset(0, -yOffset),
			}, {
				corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				React.createElement(React.Fragment, nil, (props :: any).children),
			}),
		}),
	})
end
