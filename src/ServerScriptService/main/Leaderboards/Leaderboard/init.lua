--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UsersService = game:GetService("UserService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Cryo = require(ReplicatedStorage.modules.dependencies.Cryo)
local React = require(ReplicatedStorage.modules.dependencies.React)
local ReactRoblox = require(ReplicatedStorage.modules.dependencies.ReactRoblox)

local LeaderboardUiComponent = require(script.LeaderboardUiComponent)

local lobbyLeaderboards = game.Workspace.Lobby.leaderboards

local PODIUM_ANIMATIONS = Cryo.List.map({
	"http://www.roblox.com/asset/?id=507771019",
	"http://www.roblox.com/asset/?id=507776043",
	"http://www.roblox.com/asset/?id=507777268",
}, function(id)
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	return anim
end)
local HUMANOID_SCALE = 1.5

local Leaderboard = {}
Leaderboard.__index = Leaderboard

type LeaderboardData = {
	datastore: OrderedDataStore,
	uiRoot: ReactRoblox.RootType,
	title: string,
	podiumParts: { BasePart },
	currentPodiumModels: { Model }?,
	renderIndex: number?,
}

export type Leaderboard = typeof(setmetatable({} :: LeaderboardData, Leaderboard))

function Leaderboard.new(dataStoreName: string, title: string): Leaderboard
	local orderedDataStore = DataStoreService:GetOrderedDataStore(dataStoreName)

	local leaderboardModel = lobbyLeaderboards:FindFirstChild(dataStoreName)
	assert(leaderboardModel, dataStoreName)

	local ui = Instance.new("SurfaceGui")
	ui.Name = "leaderboard"
	ui.Adornee = leaderboardModel.screen
	ui.ResetOnSpawn = false
	ui.LightInfluence = 0
	ui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	ui.PixelsPerStud = 20
	ui.Brightness = 2
	ui.Parent = leaderboardModel

	local self = setmetatable({
		datastore = orderedDataStore,
		uiRoot = ReactRoblox.createRoot(ui),
		title = title,
		podiumParts = {
			leaderboardModel.gold,
			leaderboardModel.silver,
			leaderboardModel.bronze,
		},
	}, Leaderboard)

	task.spawn(function()
		while true do
			xpcall(Leaderboard._refresh, warn, self)
			task.wait(60 * 5)
		end
	end)

	return self
end

function Leaderboard.UpdatePlayerStanding(self: Leaderboard, player: Player, value: number)
	self.datastore:SetAsync(tostring(player.UserId), value)
end

function Leaderboard._refresh(self: Leaderboard)
	local pages = self.datastore:GetSortedAsync(false, 10)
	local page = pages:GetCurrentPage()

	local userIds = Cryo.List.map(page, function(row)
		local userId = tonumber(row.key)
		assert(userId, row.key)
		return userId
	end)

	local userInfos = UsersService:GetUserInfosByUserIdsAsync(userIds)

	local data: LeaderboardUiComponent.DataTable = {}
	for i, v in page do
		table.insert(data, {
			userId = userIds[i],
			value = v.value,
			userName = userInfos[i].Username,
			displayName = userInfos[i].DisplayName,
		})
	end
	self:_render(data)
end

function Leaderboard._render(self: Leaderboard, data: LeaderboardUiComponent.DataTable)
	self.renderIndex = if self.renderIndex then self.renderIndex + 1 else 1
	local renderIndex = self.renderIndex

	if self.currentPodiumModels then
		for _, v in self.currentPodiumModels do
			v:Destroy()
		end
		self.currentPodiumModels = nil
	end

	for i, podiumPart in self.podiumParts do
		local row = data[i]
		if not row then
			break
		end

		local models = {}
		self.currentPodiumModels = models
		task.spawn(function()
			local char = Players:CreateHumanoidModelFromUserId(row.userId)
			if self.renderIndex ~= renderIndex then
				char:Destroy()
				return
			end

			char.Name = row.displayName
			local humanoid: any = char.Humanoid
			humanoid.HeadScale.Value *= HUMANOID_SCALE
			humanoid.BodyDepthScale.Value *= HUMANOID_SCALE
			humanoid.BodyWidthScale.Value *= HUMANOID_SCALE
			humanoid.BodyHeightScale.Value *= HUMANOID_SCALE

			local animator = humanoid:FindFirstAncestorOfClass("Animator") or Instance.new("Animator", humanoid)
			local prim = char.PrimaryPart
			prim.Anchored = true
			local offset = (podiumPart.Size.Y + prim.Size.Y) / 2 + humanoid.HipHeight * HUMANOID_SCALE
			char:PivotTo(podiumPart.CFrame * CFrame.new(0, offset, 0))
			char.Parent = game.Workspace

			local track = animator:LoadAnimation(PODIUM_ANIMATIONS[i])
			track.Looped = true
			track:Play()

			table.insert(models, char)
		end)
	end

	self.uiRoot:render(React.createElement(LeaderboardUiComponent, { data = data, title = self.title }))
end

return Leaderboard
