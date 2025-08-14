--!strict

local DEFAULT_COST_1 = 0
local DEFAULT_COST_2 = 200
local DEFAULT_COST_3 = 500
local DEFAULT_COST_4 = 2000
local DEFAULT_COST_5 = 50000

local STAT_IDs = {
	RocketLauncher_Cooldown = 1,
	RocketLauncher_Size = 2,
	RocketLauncher_Power = 3,

	Bomb_Cooldown = 4,
	Bomb_Size = 5,
	Bomb_Power = 6,

	Build_Cooldown = 7,
	Build_Wall_Width = 8,
	Build_Wall_Height = 9,
	Build_Bridge_Width = 10,
	Build_Bridge_Length = 11,

	Character_WalkSpeed = 12,
	Character_JumpHeight = 13,
}

export type StatLevel = {
	value: number,
	cost: number,
}

export type Stat = { StatLevel }

local LEVELS: { [number]: Stat } = {
	[STAT_IDs.RocketLauncher_Cooldown] = {
		{
			value = 1.2,
			cost = DEFAULT_COST_1,
		},
		{
			value = 1.1,
			cost = DEFAULT_COST_2,
		},
		{
			value = 1,
			cost = DEFAULT_COST_3,
		},
		{
			value = 0.9,
			cost = DEFAULT_COST_4,
		},
		{
			value = 0.8,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.RocketLauncher_Size] = {
		{
			value = 11,
			cost = DEFAULT_COST_1,
		},
		{
			value = 13,
			cost = DEFAULT_COST_2,
		},
		{
			value = 14,
			cost = DEFAULT_COST_3,
		},
		{
			value = 14.5,
			cost = DEFAULT_COST_4,
		},
		{
			value = 15,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.RocketLauncher_Power] = {
		{
			value = 0.55,
			cost = DEFAULT_COST_1,
		},
		{
			value = 0.6,
			cost = DEFAULT_COST_2,
		},
		{
			value = 0.65,
			cost = DEFAULT_COST_3,
		},
		{
			value = 0.68,
			cost = DEFAULT_COST_4,
		},
		{
			value = 0.7,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Bomb_Cooldown] = {
		{
			value = 3.5,
			cost = DEFAULT_COST_1,
		},
		{
			value = 3.3,
			cost = DEFAULT_COST_2,
		},
		{
			value = 3.15,
			cost = DEFAULT_COST_3,
		},
		{
			value = 3,
			cost = DEFAULT_COST_4,
		},
		{
			value = 2.9,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Bomb_Size] = {
		{
			value = 25,
			cost = DEFAULT_COST_1,
		},
		{
			value = 28.5,
			cost = DEFAULT_COST_2,
		},
		{
			value = 31,
			cost = DEFAULT_COST_3,
		},
		{
			value = 33,
			cost = DEFAULT_COST_4,
		},
		{
			value = 35,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Bomb_Power] = {
		{
			value = 0.7,
			cost = DEFAULT_COST_1,
		},
		{
			value = 0.75,
			cost = DEFAULT_COST_2,
		},
		{
			value = 0.79,
			cost = DEFAULT_COST_3,
		},
		{
			value = 0.84,
			cost = DEFAULT_COST_4,
		},
		{
			value = 0.87,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Build_Cooldown] = {
		{
			value = 15,
			cost = DEFAULT_COST_1,
		},
		{
			value = 13,
			cost = DEFAULT_COST_2,
		},
		{
			value = 11.5,
			cost = DEFAULT_COST_3,
		},
		{
			value = 10.2,
			cost = DEFAULT_COST_4,
		},
		{
			value = 9.5,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Build_Wall_Width] = {
		{
			value = 2,
			cost = DEFAULT_COST_1,
		},
		{
			value = 3,
			cost = DEFAULT_COST_2,
		},
		{
			value = 4,
			cost = DEFAULT_COST_3,
		},
		{
			value = 5,
			cost = DEFAULT_COST_4,
		},
		{
			value = 6,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Build_Wall_Height] = {
		{
			value = 2,
			cost = DEFAULT_COST_1,
		},
		{
			value = 3,
			cost = DEFAULT_COST_2,
		},
		{
			value = 4,
			cost = DEFAULT_COST_3,
		},
		{
			value = 5,
			cost = DEFAULT_COST_4,
		},
		{
			value = 6,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Build_Bridge_Width] = {
		{
			value = 1,
			cost = DEFAULT_COST_1,
		},
		{
			value = 2,
			cost = DEFAULT_COST_2,
		},
		{
			value = 3,
			cost = DEFAULT_COST_3,
		},
		{
			value = 4,
			cost = DEFAULT_COST_4,
		},
		{
			value = 5,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Build_Bridge_Length] = {
		{
			value = 6,
			cost = DEFAULT_COST_1,
		},
		{
			value = 8,
			cost = DEFAULT_COST_2,
		},
		{
			value = 9,
			cost = DEFAULT_COST_3,
		},
		{
			value = 10,
			cost = DEFAULT_COST_4,
		},
		{
			value = 11,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Character_WalkSpeed] = {
		{
			value = 18,
			cost = DEFAULT_COST_1,
		},
		{
			value = 22,
			cost = DEFAULT_COST_2,
		},
		{
			value = 24,
			cost = DEFAULT_COST_3,
		},
		{
			value = 26,
			cost = DEFAULT_COST_4,
		},
		{
			value = 27,
			cost = DEFAULT_COST_5,
		},
	},
	[STAT_IDs.Character_JumpHeight] = {
		{
			value = 9,
			cost = DEFAULT_COST_1,
		},
		{
			value = 10,
			cost = DEFAULT_COST_2,
		},
		{
			value = 11,
			cost = DEFAULT_COST_3,
		},
		{
			value = 12,
			cost = DEFAULT_COST_4,
		},
		{
			value = 13,
			cost = DEFAULT_COST_5,
		},
	},
}

setmetatable(LEVELS, {
	__index = function(_, i)
		error(`invalid statId '{i}'`)
	end,
})

return {
	LEVELS = (LEVELS :: any) :: { [number]: { StatLevel } },
	STAT_IDs = STAT_IDs,
}
