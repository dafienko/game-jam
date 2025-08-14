--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local t = require(ReplicatedStorage.modules.dependencies.t)
local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)
local Levels = require(ReplicatedStorage.modules.game.Levels)
local PlayerData = require(ServerScriptService.main.PlayerData)

local BuildInterface = {}

local function constructBlueprint(player: Player, rootPart: BasePart, cf: CFrame, blueprint: GameUtil.Blueprint)
	local color = player.TeamColor
	local parts = {}
	for i, v in blueprint do
		local map = game.Workspace:FindFirstChild("map")
		if not map then
			return
		end

		local part = Instance.new("Part")
		part.Anchored = false
		part.BrickColor = color
		part.Size = v.Size
		part.CFrame = cf * v.CFrame

		for _, j in v.weldToIndices do
			local weldTo = if j == -1 then rootPart else parts[j]
			if not (weldTo and weldTo:IsDescendantOf(game)) then
				continue
			end

			local w = Instance.new("WeldConstraint")
			w.Part0 = part
			w.Part1 = weldTo
			w.Parent = part
		end

		part.Parent = map
		parts[i] = part
		task.wait(0.1)
	end
end

function BuildInterface.onBuild(player: Player, structureName: string, cf: CFrame)
	assert(t.string(structureName))
	assert(t.CFrame(cf))

	local canBuildAtTime = player:GetAttribute("canBuildAtTime") :: number? or 0
	if time() < canBuildAtTime then
		return
	end

	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not (char and humanoid and humanoid.Health > 0) then
		return
	end

	local dist = (char:GetPivot().Position - cf.Position).Magnitude
	if dist > 30 then
		return
	end

	local map = game.Workspace:FindFirstChild("map")
	if not map then
		return
	end

	local blueprint
	if structureName == "Wall" then
		blueprint = GameUtil.generateWallBlueprint(
			PlayerData.getStat(player, Levels.STAT_IDs.Build_Wall_Width).value,
			PlayerData.getStat(player, Levels.STAT_IDs.Build_Wall_Height).value
		)
	elseif structureName == "Bridge" then
		blueprint = GameUtil.generateBridgeBlueprint(
			PlayerData.getStat(player, Levels.STAT_IDs.Build_Bridge_Width).value,
			PlayerData.getStat(player, Levels.STAT_IDs.Build_Bridge_Length).value
		)
	else
		assert(false, `Invalid structure name {structureName}`)
	end

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { map }
	params.FilterType = Enum.RaycastFilterType.Include

	local res = game.Workspace:Raycast(cf.Position + Vector3.new(0, 4, 0), Vector3.new(0, -8, 0), params)
	if not (res and res.Instance and res.Instance:IsA("BasePart")) then
		return
	end
	task.spawn(constructBlueprint, player, res.Instance, cf - cf.Position + res.Position, blueprint)

	local cooldown = PlayerData.getStat(player, Levels.STAT_IDs.Build_Cooldown).value
	player:SetAttribute("canBuildAtTime", time() + cooldown)
	return cooldown
end

return BuildInterface
