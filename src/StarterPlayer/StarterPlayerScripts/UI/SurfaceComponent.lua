--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)

type Props = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor3: Color3?,
	BorderSizePixel: number?,
	ZIndex: number?,
	constraints: any,
}

return function(props: Props)
	return React.createElement("Frame", {
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		ZIndex = props.ZIndex,
		BackgroundTransparency = 1,
	}, {
		constraintChildren = props.constraints and React.createElement(React.Fragment, nil, props.constraints),
		dropShadow = React.createElement("ImageLabel", {
			Size = UDim2.new(1, 30, 1, 30),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "http://www.roblox.com/asset/?id=15484968371",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(50, 50, 150, 150),
			SliceScale = 0.8,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.3,
			ZIndex = -1,
		}),
		frame = React.createElement("Frame", {
			BackgroundColor3 = props.BackgroundColor3,
			BorderSizePixel = props.BorderSizePixel,
			Size = UDim2.fromScale(1, 1),
		}, (props :: any).children),
	})
end
