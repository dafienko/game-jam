--!strict

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local t = require(ReplicatedStorage.modules.dependencies.t)

local Util = require(ServerScriptService.Util)
local PlayerData = require(ServerScriptService.main.PlayerData)
local Levels = require(game.ReplicatedStorage.modules.game.Levels)

local rocketTemplate = ReplicatedStorage.assets.rocket

local ExplosionsInterface = {}

local function applyExplosionImpulse(
	part: BasePart,
	explosionPosition: Vector3,
	impulse: number | Vector3,
	strength: number
)
	if typeof(impulse) == "number" then
		part:ApplyImpulse((part.Position - explosionPosition).Unit * impulse * strength)
	else
		part:ApplyImpulseAtPosition(impulse * strength, explosionPosition)
	end
end

local map = game.Workspace:FindFirstChild("map")
game.Workspace.ChildAdded:Connect(function(child)
	if child.Name == "map" then
		map = child
	end
end)
game.Workspace.ChildRemoved:Connect(function(child)
	if child == map then
		map = nil
	end
end)

local function isMapPart(part: BasePart)
	return map and part:IsDescendantOf(map)
end

local function explodeAtPosition(
	fromPlayer: Player?,
	position: Vector3,
	blastRadius: number,
	destroyJointPercent: number,
	impulse: Vector3 | number
)
	local explosion = Instance.new("Explosion")
	explosion.Position = position
	explosion.BlastRadius = blastRadius
	explosion.ExplosionType = Enum.ExplosionType.NoCraters
	explosion.BlastPressure = 0
	explosion.DestroyJointRadiusPercent = 0

	task.spawn(Util.playSoundAtPositionAsync, "rbxassetid://262562442", 30, 600, 1.1, position)

	for _, v in Players:GetPlayers() do
		if v == fromPlayer then
			continue
		end

		if not Util.canTeamAttackTeam(fromPlayer and fromPlayer.Team, v.Team) then
			continue
		end

		local char = v.Character
		local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
		local hrp = char and char.PrimaryPart
		if not (humanoid and hrp) then
			continue
		end

		local dist = (hrp.Position - position).Magnitude
		if dist > blastRadius then
			continue
		end

		local strength = 1 - math.pow(math.clamp(dist / blastRadius, 0, 1), 3)
		Util.playerDamageCharacter(fromPlayer, char, strength * destroyJointPercent * 200)
		if humanoid.Health <= 0 then
			for _, v in char:GetChildren() do
				if not v:IsA("BasePart") then
					continue
				end

				applyExplosionImpulse(v, position, impulse, strength)
			end
		end
	end

	local ignoreTeam = fromPlayer and fromPlayer.Team
	explosion.Hit:Connect(function(part, dist)
		local player, char = Util.getPlayerAndCharacterFromInstance(part)
		if player or char then
			return
		end

		if ignoreTeam and part.BrickColor == ignoreTeam.TeamColor then
			return
		end

		if not isMapPart(part) then
			return
		end

		local strength = 1 - math.pow(math.clamp(dist / blastRadius, 0, 1), 3)
		local joints = part:GetJoints()
		if #joints > 0 then
			for _, v in joints do
				if math.random() > destroyJointPercent * strength then
					continue
				end

				v:Destroy()
				if fromPlayer then
					PlayerData.addDamage(fromPlayer, 1)
				end
			end
		end

		applyExplosionImpulse(part, position, impulse, strength)
	end)

	explosion.Parent = game.Workspace
	Debris:AddItem(explosion, 3)
end

if RunService:IsStudio() then
	function ExplosionsInterface.onExplodeAtPosition(player: Player, position: Vector3)
		assert(t.Vector3(position))

		explodeAtPosition(player, position, 15, 1, 500)
	end
end

local function isCharacterValid(char: Model): boolean
	local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
	if not humanoid then
		return false
	end

	return humanoid.Health > 0
end

local rocketInitialSpeed = 40
local rocketAcceleration = 50
local rocketMaxDistance = 400
local rocketMaxSpeed = 120
local function propelRocket(rocket: Model, player: Player)
	local explosionSize = PlayerData.getStat(player, Levels.STAT_IDs.RocketLauncher_Size).value
	local explosionPower = PlayerData.getStat(player, Levels.STAT_IDs.RocketLauncher_Power).value

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character :: any }
	params.RespectCanCollide = true

	local speed = rocketInitialSpeed
	local distanceTraveled = 0
	local dir = rocket:GetPivot().LookVector
	local heartbeatConnection
	local function explode(position: Vector3)
		heartbeatConnection:Disconnect()
		rocket:Destroy()
		explodeAtPosition(player, position, explosionSize, explosionPower, dir * 2000 * explosionPower)
	end

	local origin = rocket:GetPivot()
	local xSeed = math.random() * 100
	local ySeed = math.random() * 100
	local wobbleScale = 5
	local wobbleDistanceScale = 0.01
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		speed = math.min(rocketMaxSpeed, speed + rocketAcceleration * dt)
		local dist = speed * dt
		distanceTraveled += dist
		local pivot = rocket:GetPivot()
		local wobble = CFrame.new(
			Vector3.new(
				math.noise(xSeed, distanceTraveled * wobbleDistanceScale),
				math.noise(ySeed, distanceTraveled * wobbleDistanceScale),
				0
			)
				* wobbleScale
				* math.min(math.pow(distanceTraveled / 70, 2), 1)
		)

		local newCF = origin * wobble + dir * distanceTraveled
		if distanceTraveled > rocketMaxDistance then
			explode(newCF.Position)
			return
		end

		local res = game.Workspace:Raycast(pivot.Position, newCF.Position - pivot.Position, params)
		if res then
			explode(res.Position)
			return
		end

		rocket:PivotTo(newCF)
	end)
end

local function createRocket(player: Player, cf: CFrame): Model
	local rocket = rocketTemplate:Clone()
	for _, v in rocket:GetDescendants() do
		if v:IsA("BasePart") then
			v.Color = player.TeamColor.Color
		elseif v:IsA("ParticleEmitter") then
			v.Color = ColorSequence.new(player.TeamColor.Color)
		end
	end
	rocket.PrimaryPart.flyingSound:Play()
	rocket:PivotTo(cf)
	return rocket
end

function ExplosionsInterface.onShootRocketAtPosition(player: Player, rpg: Tool, targetPosition: any)
	assert(t.instanceOf("Tool")(rpg))
	assert(t.Vector3(targetPosition))
	assert(player.Character and isCharacterValid(player.Character), "invalid character")
	assert(rpg:IsDescendantOf(player.Character), "RPG must be equipped")
	assert(rpg.Name == "Rocket Launcher" or rpg.Name == "Triple Rocket Launcher", rpg.Name)

	local cooldown = PlayerData.getStat(player, Levels.STAT_IDs.RocketLauncher_Cooldown).value
	local nextRocketTime = rpg:GetAttribute("nextRocketTime") :: number? or 0
	if time() < nextRocketTime then
		return
	end
	rpg:SetAttribute("nextRocketTime", time() + cooldown)

	local rpgModel = rpg:FindFirstChild("Model")
	local launchers = rpgModel and rpgModel:FindFirstChild("launchers")
	if launchers then
		for i, mainPart: any in launchers:GetChildren() do
			mainPart.shootSound:Play()
			local rocket = createRocket(player, CFrame.new(mainPart.muzzle.WorldPosition, targetPosition))
			propelRocket(rocket, player)
			rocket.Parent = game.Workspace
		end
	end

	return cooldown
end

local function onBombAdded(bomb: Model)
	local userId = bomb:GetAttribute("fromUserId") :: number?
	local fromPlayer = userId and Players:GetPlayerByUserId(userId)
	local explosionSize = PlayerData.getStat(fromPlayer, Levels.STAT_IDs.Bomb_Size).value
	local explosionPower = PlayerData.getStat(fromPlayer, Levels.STAT_IDs.Bomb_Power).value

	local prim = bomb.PrimaryPart
	if not prim then
		return
	end

	local originalColor = prim.Color
	local originalMaterial = prim.Material

	local delay = 1
	for i = 1, 10 do
		task.wait(delay)
		delay *= 0.8
		if not bomb:IsDescendantOf(game.Workspace) then
			return
		end

		if prim.Color == originalColor then
			prim.Color = Color3.new(1, 0, 0)
			prim.Material = Enum.Material.Neon
		else
			prim.Color = originalColor
			prim.Material = originalMaterial
		end
	end

	explodeAtPosition(fromPlayer, prim.Position, explosionSize, explosionPower, 1000 * explosionPower)
	bomb:Destroy()
end

CollectionService:GetInstanceAddedSignal("bomb"):Connect(onBombAdded)

return ExplosionsInterface
