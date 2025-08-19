--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)

return function()
	local name: string? = GameUtil.useAttribute(ReplicatedStorage, "winningTeamName")
	local color: Color3? = GameUtil.useAttribute(ReplicatedStorage, "winningTeamColor")
	local isDraw: boolean? = GameUtil.useAttribute(ReplicatedStorage, "isDraw")

	if not (isDraw or (name and color)) then
		return React.None
	end

	local uiColor = if isDraw then Color3.fromHSV(0, 0, 0.6) else color
	return React.createElement("TextLabel", {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.9, 0.9),
		BorderSizePixel = 0,
		BackgroundColor3 = uiColor,
		BackgroundTransparency = 0.3,
		TextColor3 = Color3.fromHSV(0, 0, 1),
		TextStrokeColor3 = Color3.new(),
		TextStrokeTransparency = 0,
		TextScaled = true,
		TextWrapped = true,
		Text = if isDraw then "Draw!" else `{name} wins!`,
	}, {
		aspect = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 4,
		}),
		sizeConstraint = React.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(math.huge, 200),
		}),
		stroke = React.createElement("UIStroke", {
			Color = uiColor:Lerp(Color3.new(), 0.2),
			Thickness = 4,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	})
end
