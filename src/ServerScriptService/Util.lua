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

return Util
