--!strict

local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)
local Cryo = require(ReplicatedStorage.modules.dependencies.Cryo)

type Props = {
	team: Team,
}

local function TeamScoreComponent(props: Props)
	local color = props.team.TeamColor.Color
	local score = GameUtil.useAttribute(props.team, "score") or 0

	return React.createElement("TextLabel", {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0.25, -20, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		BorderSizePixel = 0,
		BackgroundColor3 = color,
		BackgroundTransparency = 0.3,
		TextColor3 = Color3.fromHSV(0, 0, 1),
		TextStrokeColor3 = Color3.new(),
		TextStrokeTransparency = 0,
		TextScaled = true,
		TextWrapped = true,
		Text = tostring(score),
	}, {
		aspect = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 2,
		}),
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0.15, 0),
			PaddingRight = UDim.new(0.15, 0),
			PaddingTop = UDim.new(0.15, 0),
			PaddingBottom = UDim.new(0.15, 0),
		}),
		stroke = React.createElement("UIStroke", {
			Color = color:Lerp(Color3.new(), 0.2),
			Thickness = 2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	})
end

local function getTeams()
	return Cryo.List.filter(Teams:GetTeams(), function(team: Team)
		return team.Name ~= "Neutral"
	end)
end
local function useTeams()
	local teams, setTeams = React.useState(getTeams())

	React.useEffect(function()
		local function update()
			setTeams(getTeams())
		end

		local connections = {
			Teams.ChildRemoved:Connect(update),
			Teams.ChildAdded:Connect(update),
		}

		return function()
			for _, v in connections do
				v:Disconnect()
			end
		end
	end, {})

	return teams
end

return function(props: { LayoutOrder: number })
	local teams = useTeams()

	return React.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, 0, 0, 40),
	}, {
		layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 20),
		}),
		teamScores = React.createElement(
			React.Fragment,
			nil,
			Cryo.Dictionary.map(teams, function(team)
				return React.createElement(TeamScoreComponent, { team = team }), team.Name
			end) :: any
		),
	})
end
