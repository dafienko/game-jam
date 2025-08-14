--!strict

local Leaderboard = require(script.Leaderboard)

local winsLeaderboard = Leaderboard.new("globalWins", "🏆 Wins")
local damageLeaderboard = Leaderboard.new("globalDamage", "💥 Damage")
local koLeaderboard = Leaderboard.new("globalKOs", "🥊 KO's")

local Leaderboards = {}

type StandingValues = {
	wins: number,
	damage: number,
	KOs: number,
}

function Leaderboards.updatePlayerStanding(player: Player, standingValues: StandingValues)
	winsLeaderboard:UpdatePlayerStanding(player, standingValues.wins)
	damageLeaderboard:UpdatePlayerStanding(player, standingValues.damage)
	koLeaderboard:UpdatePlayerStanding(player, standingValues.KOs)
end

return Leaderboards
