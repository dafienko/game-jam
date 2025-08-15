--!strict

local Teams = game:GetService("Teams")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerData = require(ServerScriptService.main.PlayerData)

local TeamDoor = require(script.TeamDoor)

local INTERMISSION_SECONDS = 5

local maps = ServerStorage.Maps
local Lobby = game.Workspace.Lobby
local loadingGui = Lobby.LoadingGui
local joinDoorTemplate = Lobby.joinDoorTemplate
joinDoorTemplate.Parent = nil

local function startNewGame(sourceMapModel: Model): () -> ()
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

	model.Name = "map"
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
		team:SetAttribute("score", 0)
		team.Parent = Teams
		table.insert(teams, team)

		local door = joinDoorTemplate:Clone()
		local dir = (i % 2) * 2 - 1
		local offset = i // 2
		door:PivotTo(door:GetPivot() * CFrame.new(30 * offset * dir, 0, 0), 0, 0)
		local teamDoor = TeamDoor.new(door, team, spawnLocations)
		table.insert(teamDoors, teamDoor)
		door.Parent = Lobby

		team.PlayerAdded:Connect(function()
			teamDoor:UpdateStatus()
		end)
		team.PlayerRemoved:Connect(function()
			teamDoor:UpdateStatus()
		end)
	end

	return function()
		model:Destroy()
		for _, v in teamDoors do
			v:Destroy()
		end

		local highestTeamScore: number = -1
		local isDraw = false
		local winningTeam: Team?
		for _, v in teams do
			local score = v:GetAttribute("score") :: number
			if score == highestTeamScore then
				isDraw = true
			elseif score > highestTeamScore then
				highestTeamScore = score
				isDraw = false
				winningTeam = v
			end
		end
		if isDraw then
			ReplicatedStorage:SetAttribute("isDraw", true)
		elseif winningTeam then
			for _, v in winningTeam:GetPlayers() do
				PlayerData.addWin(v)
			end
			ReplicatedStorage:SetAttribute("winningTeamName", winningTeam.Name)
			ReplicatedStorage:SetAttribute("winningTeamColor", winningTeam.TeamColor.Color)
		end
		for _, v in teams do
			v:Destroy()
		end

		for _, v in Players:GetPlayers() do
			v.Team = Teams.Neutral

			local char = v.Character
			if not char then
				continue
			end

			char:SetAttribute("lastTaggedBy", nil)
			local humanoid = char:FindFirstChild("Humanoid")
			if not humanoid then
				continue
			end

			humanoid.Health = 0
		end
	end
end

local function countdown(seconds: number)
	for t = seconds, 0, -1 do
		game.Workspace:SetAttribute("timeRemaining", t)
		task.wait(1)
	end
end

while true do
	loadingGui.Enabled = false
	local map = maps.Animals
	local cleanup = startNewGame(map)
	countdown(map:GetAttribute("duration"))
	cleanup()
	task.delay(5, function()
		ReplicatedStorage:SetAttribute("isDraw", nil)
		ReplicatedStorage:SetAttribute("winningTeamName", nil)
		ReplicatedStorage:SetAttribute("winningTeamColor", nil)
	end)
	loadingGui.Enabled = true
	countdown(INTERMISSION_SECONDS)
end

return nil
