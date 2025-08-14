--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer
local ContextActionService = game:GetService("ContextActionService")

local React = require(ReplicatedStorage.modules.dependencies.React)
local ReactRoblox = require(ReplicatedStorage.modules.dependencies.ReactRoblox)
local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)

local BuildUiComponent = require(script.BuildUiComponent)

local BUILD_ACTION_NAME = "Build"
local STRUCTURE_NAMES = {
	"Wall",
	"Bridge",
}

local buildGui = Instance.new("ScreenGui")
buildGui.Name = "build"
buildGui.ResetOnSpawn = false
buildGui.Parent = player:WaitForChild("PlayerGui")

local root = ReactRoblox.createRoot(buildGui)

local function renderBlueprint(blueprint: GameUtil.Blueprint): Model
	local model = Instance.new("Model")
	model.Name = "preview"
	for _, v in blueprint do
		local part = Instance.new("Part")
		part.Size = v.Size
		part.CFrame = v.CFrame
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 0.5
		part.Parent = model
	end

	model.WorldPivot = CFrame.new()
	return model
end

local function setPreviewModelValid(model: Model, valid: boolean)
	local color = if valid then Color3.fromRGB(28, 82, 196) else Color3.new(1, 0, 0)
	for _, v in model:GetDescendants() do
		if v:IsA("BasePart") then
			v.Color = color
		end
	end
end

local canBuildAtTime = 0
local function startBuilding(tool: Tool, humanoidRootPart: Part): () -> ()
	local currentStructure = STRUCTURE_NAMES[1]
	local currentCf: CFrame = CFrame.new()
	local currentAnchorPart: BasePart?
	local currentPreviewModel
	local debounce = false

	local function updatePreviewPlacement()
		if not currentPreviewModel then
			return
		end
		local vec = Vector3.new(0, -8, 0)
		local origin = humanoidRootPart.CFrame * CFrame.new(0, 0, -10)
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { game.Workspace:FindFirstChild("map") }
		params.FilterType = Enum.RaycastFilterType.Include
		local res = game.Workspace:Raycast(origin.Position, vec, params)
		local pos = if res then res.Position else origin.Position + vec / 2
		currentCf = origin - origin.Position + pos
		currentPreviewModel:PivotTo(currentCf)
		currentAnchorPart = res and res.Instance
		setPreviewModelValid(
			currentPreviewModel,
			currentAnchorPart ~= nil and not debounce and time() >= canBuildAtTime
		)
	end

	local function onCurrentStructureChanged()
		if currentPreviewModel then
			currentPreviewModel:Destroy()
		end
		local blueprint = if currentStructure == "Wall"
			then GameUtil.generateWallBlueprint(6, 4)
			else GameUtil.generateBridgeBlueprint(3, 10)
		currentPreviewModel = renderBlueprint(blueprint)
		currentPreviewModel.Parent = game.Workspace
		updatePreviewPlacement()
	end
	onCurrentStructureChanged()

	local function cycleCurrentStructure(dir: number)
		local i = table.find(STRUCTURE_NAMES, currentStructure)
		assert(i)
		i = (i + dir - 1) % #STRUCTURE_NAMES + 1
		currentStructure = STRUCTURE_NAMES[i]
		onCurrentStructureChanged()
	end

	local function build()
		if not GameUtil.isPlayerAlive(player) then
			return
		end

		if time() < canBuildAtTime then
			return
		end

		if not currentAnchorPart then
			return
		end

		if debounce then
			return
		end
		debounce = true

		if ReplicatedStorage.remotes.build:InvokeServer(currentStructure, currentCf) then
			canBuildAtTime = time() + 12
		end

		debounce = false
	end

	local textBinding, setText = React.createBinding(currentStructure)
	root:render(React.createElement(BuildUiComponent, {
		Text = textBinding,
		onNextItem = function()
			cycleCurrentStructure(1)
		end,
		onLastItem = function()
			cycleCurrentStructure(-1)
		end,
	}))

	local connections = {
		RunService.RenderStepped:Connect(function()
			updatePreviewPlacement()
			local timeRemaining = canBuildAtTime - time()
			if debounce then
				setText("Building...")
			elseif timeRemaining > 0 then
				setText(("%.2f"):format(timeRemaining))
			else
				setText(currentStructure)
			end
		end),
	}
	local didBindAction = false
	if UserInputService.TouchEnabled then
		ContextActionService:BindAction(BUILD_ACTION_NAME, function()
			build()
		end, true)
		didBindAction = true
	else
		table.insert(
			connections,
			tool.Activated:Connect(function()
				build()
			end)
		)
	end

	return function()
		if didBindAction then
			ContextActionService:UnbindAction(BUILD_ACTION_NAME)
		end
		for _, v in connections do
			v:Disconnect()
		end
		if currentPreviewModel then
			currentPreviewModel:Destroy()
		end
		root:render(React.None)
	end
end

return function(tool: Tool)
	tool.Equipped:Connect(function()
		local hrp = player.Character and player.Character.PrimaryPart
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not (hrp and humanoid and GameUtil.isPlayerAlive(player)) then
			return
		end

		local stopBuilding = startBuilding(tool, hrp)

		local connections = {}
		local function cleanup()
			stopBuilding()
		end

		table.insert(connections, tool.Unequipped:Once(cleanup))
		table.insert(connections, humanoid.Died:Once(cleanup))
	end)
end
