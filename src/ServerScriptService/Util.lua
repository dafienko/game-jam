--!strict

local Players = game:GetService("Players")

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

function Util.playerDamageCharacter(player: Player, character: Model, amount: number)
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
	if not humanoid then
		return
	end

	if humanoid.Health <= 0 then
		return
	end

	character:SetAttribute("lastTaggedBy", player.UserId)
	character:SetAttribute("taggedAtTime", time())
	humanoid:TakeDamage(amount)
end

function Util.canTeamAttackTeam(attackingTeam: Team?, team: Team?): boolean
	if not team then
		return false
	end

	return attackingTeam ~= team
end

return Util
