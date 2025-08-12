--!strict

local Teams = game:GetService("Teams")
local ServerStorage = game:GetService("ServerStorage")

local TeamDoor = require(script.TeamDoor)

local GAME_DURATION_SECONDS = 60 * 10

local maps = ServerStorage.Maps
local Lobby = game.Workspace.Lobby
local joinDoorTemplate = Lobby.joinDoorTemplate
joinDoorTemplate.Parent = nil

local function loadMapModel(sourceMapModel: Model): () -> ()
	local model = sourceMapModel:Clone()
	local teamColorSpawns = {}
	for _, v in model:GetDescendants() do
		if v:IsA("SpawnLocation") then
			if teamColorSpawns[v.TeamColor] then
				table.insert(teamColorSpawns[v.TeamColor], v)
			else
				teamColorSpawns[v.TeamColor.Name] = { v }
			end
		end
	end

	model.Parent = game.Workspace

	local teams = {}
	local teamDoors = {}
	local i = 0
	for teamColorName, spawnLocations in teamColorSpawns do
		i += 1
		local team = Instance.new("Team")
		team.Name = teamColorName
		team.TeamColor = BrickColor.new(teamColorName :: any)
		team.AutoAssignable = false
		team.Parent = Teams
		table.insert(teams, team)

		local door = joinDoorTemplate:Clone()
		local dir = (i % 2) * 2 - 1
		local offset = i // 2
		door:PivotTo(door:GetPivot() * CFrame.new(30 * offset * dir, 0, 0), 0, 0)
		table.insert(teamDoors, TeamDoor.new(door, team, spawnLocations))
		door.Parent = Lobby
	end

	return function()
		model:Destroy()
		for _, v in teamDoors do
			v:Destroy()
		end
		for _, v in teams do
			v:Destroy()
		end
	end
end

while true do
	local cleanup = loadMapModel(maps.Map1)
	for t = GAME_DURATION_SECONDS, 0, -1 do
		game.Workspace:SetAttribute("timeRemaining", t)
		task.wait(1)
	end
	cleanup()
end

return nil
