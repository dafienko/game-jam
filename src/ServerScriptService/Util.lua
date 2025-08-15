--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")

local toolTemplate = ServerStorage.ToolTemplate

local Util = {}

function Util.getPlayerAndCharacterFromInstance(instance: Instance): (Player?, Model?)
	local player = instance:IsA("Model") and Players:GetPlayerFromCharacter(instance)
	if player then
		return player, instance :: Model
	end

	local potentialCharacter = instance:FindFirstAncestorOfClass("Model")
	if not potentialCharacter then
		return nil, nil
	end

	return Util.getPlayerAndCharacterFromInstance(potentialCharacter)
end

function Util.playerDamageCharacter(player: Player?, character: Model, amount: number)
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
	if not humanoid then
		return
	end

	if humanoid.Health <= 0 then
		return
	end

	if player then
		character:SetAttribute("lastTaggedBy", player.UserId)
		character:SetAttribute("taggedAtTime", time())
	end
	humanoid:TakeDamage(amount)
end

function Util.canTeamAttackTeam(attackingTeam: Team?, team: Team?): boolean
	if not team then
		return false
	end

	return attackingTeam ~= team
end

local soundParts = Instance.new("Folder")
soundParts.Name = "soundParts"
soundParts.Parent = game.Workspace

function Util.playSoundAtPositionAsync(
	soundId: string,
	rolloffMinDistance: number,
	rolloffMaxDistance: number,
	volume: number,
	position: Vector3
)
	local soundPart = Instance.new("Part")
	soundPart.CanCollide = false
	soundPart.CanQuery = false
	soundPart.CanTouch = false
	soundPart.Anchored = true
	soundPart.CastShadow = false
	soundPart.Transparency = 1
	soundPart.CFrame = CFrame.new(position)

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.RollOffMinDistance = rolloffMinDistance
	sound.RollOffMaxDistance = rolloffMaxDistance
	sound.Volume = volume
	sound.Parent = soundPart
	soundPart.Parent = soundParts
	if not sound.IsLoaded then
		sound.Loaded:Wait()
	end
	sound:Play()
	Debris:AddItem(soundPart, sound.TimeLength + 1)
end

function Util.createTool(name: string): Tool
	local tool = toolTemplate:Clone()
	tool.Name = name
	tool.server.Enabled = true

	if not ReplicatedStorage.modules.game.tools:FindFirstChild(name) then
		tool.client:Destroy()
	end

	return tool
end

return Util
