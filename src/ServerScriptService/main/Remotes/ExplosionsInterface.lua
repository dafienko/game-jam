--!strict

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local t = require(ReplicatedStorage.modules.dependencies.t)
local Util = require(ServerScriptService.Util)

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

local function explodeAtPosition(position: Vector3, blastRadius: number, impulse: Vector3 | number, ignoreTeam: Team?)
	local explosion = Instance.new("Explosion")
	explosion.Position = position
	explosion.BlastRadius = blastRadius
	explosion.ExplosionType = Enum.ExplosionType.NoCraters
	explosion.BlastPressure = 0
	explosion.DestroyJointRadiusPercent = 0

	for _, v in Players:GetPlayers() do
		if (ignoreTeam and v.Team == ignoreTeam) or not v.Team then
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

		local D = 5
		local strength = D / math.max(dist, D)
		humanoid:TakeDamage(strength * 100)
		if humanoid.Health <= 0 then
			for _, v in char:GetChildren() do
				if not v:IsA("BasePart") then
					continue
				end

				applyExplosionImpulse(v, position, impulse, strength)
			end
		end
	end

	explosion.Hit:Connect(function(part, dist)
		local player, char = Util.getPlayerAndCharacterFromInstance(part)
		if player or char then
			return
		end

		if ignoreTeam and part.BrickColor == ignoreTeam.TeamColor then
			return
		end

		local D = 4
		local strength = D / math.max(dist, D)
		local joints = part:GetJoints()
		if #joints > 0 then
			for _, v in joints do
				if math.random() > 0.8 * strength then
					continue
				end

				v:Destroy()
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

		explodeAtPosition(position, 15, 500, player.Team)
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
local function propelRocket(rocket: Model, team: Team, player: Player)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character :: any }
	params.RespectCanCollide = true

	local speed = rocketInitialSpeed
	local distanceTraveled = 0
	local dir = rocket:GetPivot().LookVector
	local heartbeatConnection
	local function cleanup()
		heartbeatConnection:Disconnect()
		rocket:Destroy()
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		speed = math.min(rocketMaxSpeed, speed + rocketAcceleration * dt)
		local dist = speed * dt
		distanceTraveled += dist
		local pivot = rocket:GetPivot()
		local newCF = pivot + dir * dist
		if distanceTraveled > rocketMaxDistance then
			explodeAtPosition(newCF.Position, 15, dir * 1500, team)
			cleanup()
			return
		end

		local res = game.Workspace:Raycast(pivot.Position, dir * dist, params)
		if res then
			explodeAtPosition(res.Position, 15, dir * 1500, team)
			cleanup()
			return
		end

		rocket:PivotTo(newCF)
	end)
end

function ExplosionsInterface.onShootRocketAtPosition(player: Player, rpg: Tool, targetPosition: any)
	assert(t.instanceOf("Tool")(rpg))
	assert(t.Vector3(targetPosition))
	assert(player.Character and isCharacterValid(player.Character), "invalid character")
	assert(rpg:IsDescendantOf(player.Character), "RPG must be equipped")

	local nextRocketTime = player:GetAttribute("nextRocketTime") :: number?
	if time() < (nextRocketTime or 0) then
		return
	end
	player:SetAttribute("nextRocketTime", time() + 1)

	local rpgModel = rpg:FindFirstChild("Model")
	local mainPart = rpgModel and rpgModel:FindFirstChild("main")
	local muzzleAttachment = mainPart and mainPart:FindFirstChild("muzzle") :: Attachment?
	local shootFrom = if muzzleAttachment then muzzleAttachment.WorldCFrame else rpg:GetPivot()
	local rocket = rocketTemplate:Clone()
	for _, v in rocket:GetDescendants() do
		if v:IsA("BasePart") then
			v.Color = player.TeamColor.Color
		elseif v:IsA("ParticleEmitter") then
			v.Color = ColorSequence.new(player.TeamColor.Color)
		end
	end
	rocket:PivotTo(CFrame.new(shootFrom.Position, targetPosition))
	propelRocket(rocket, player.Team, player)
	rocket.Parent = game.Workspace
end

return ExplosionsInterface
