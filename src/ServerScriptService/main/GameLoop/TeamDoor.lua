--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")

local Util = require(ServerScriptService.Util)

local TeamDoor = {}
TeamDoor.__index = TeamDoor

type TeamDoorData = {
	model: Model,
	fullModel: Model,
	team: Team,
	connections: { RBXScriptConnection },
	spawnLocations: { SpawnLocation },
	doorPart: BasePart,
	uiTextLabel: TextLabel,
	canJoin: boolean,
}

export type TeamDoor = typeof(setmetatable({} :: TeamDoorData, TeamDoor))

function TeamDoor.new(model: Model, team: Team, spawnLocations: { SpawnLocation }): TeamDoor
	local fullModel = model:FindFirstChild("full")
	assert(fullModel and fullModel:IsA("Model"))
	fullModel.Parent = nil

	local surfaceGui = model:FindFirstChild("SurfaceGui") :: SurfaceGui
	local textLabel = surfaceGui:FindFirstChild("TextLabel") :: TextLabel
	local doorPart = model.PrimaryPart :: BasePart

	doorPart.Color = team.TeamColor.Color

	local self: TeamDoor
	self = setmetatable({
		model = model,
		fullModel = fullModel,
		team = team,
		spawnLocations = spawnLocations,
		canJoin = true,
		doorPart = doorPart,
		uiTextLabel = textLabel,
		connections = {
			(model.PrimaryPart :: BasePart).Touched:Connect(function(other)
				self:_onTouched(other)
			end),
		},
	}, TeamDoor)

	task.spawn(function()
		self:UpdateStatus()
	end)

	return self
end

function TeamDoor._onTouched(self: TeamDoor, other: BasePart)
	if not self.canJoin then
		return
	end

	local player, character = Util.getPlayerAndCharacterFromInstance(other)
	if not (player and character) then
		return
	end

	player.Team = self.team

	local spawnLocation = self.spawnLocations[math.random(1, #self.spawnLocations)]
	character:PivotTo(spawnLocation.CFrame + Vector3.new(0, 5, 0))
end

function TeamDoor.UpdateStatus(self: TeamDoor)
	local min = math.huge
	for _, v in Teams:GetTeams() do
		if v.Name == "Neutral" then
			continue
		end

		min = math.min(min, #v:GetPlayers())
	end

	self.canJoin = #self.team:GetPlayers() == min
	if self.canJoin then
		self.fullModel.Parent = nil
		self.doorPart.Material = Enum.Material.Neon
		local color = self.team.TeamColor.Color
		self.uiTextLabel.Text = `<font color="rgb({math.round(color.R * 255)},{math.round(color.G * 255)},{math.round(
			color.B * 255
		)})">{self.team.Name}</font>`
	else
		self.fullModel.Parent = self.model
		self.doorPart.Material = Enum.Material.SmoothPlastic
		self.uiTextLabel.Text = "Full"
	end
end

function TeamDoor.Destroy(self: TeamDoor)
	for _, v in self.connections do
		v:Disconnect()
	end
	self.fullModel:Destroy()
	self.model:Destroy()
end

return TeamDoor
