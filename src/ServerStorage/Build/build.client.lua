--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local RotationTypes = {
	Two = "Two",
	Three = "Three",
	Four = "Four",
	Ground = "Ground",
}

local ROTATIONS = {
	[RotationTypes.Two] = {
		0,
		180,
	},

	[RotationTypes.Three] = {
		0,
		90,
		-90,
	},

	[RotationTypes.Four] = {
		0,
		90,
		180,
		270,
	},

	[RotationTypes.Ground] = {
		0,
		90,
		180,
		270,
	},
}

local ATTACHMENT_ROTATION_TYPE_MAP: { [string]: string } = {
	floor = RotationTypes.Two,
	left = RotationTypes.Three,
	right = RotationTypes.Three,
	front = RotationTypes.Three,
	back = RotationTypes.Three,
	default = RotationTypes.Four,
}

local structureModels = ReplicatedStorage.structures

local camera = game.Workspace.CurrentCamera

local nodesContainer = game.Workspace:FindFirstChild("nodes")
if not nodesContainer then
	nodesContainer = Instance.new("Folder")
	nodesContainer.Name = "nodes"
	nodesContainer.Parent = game.Workspace
end

local structuresContainer = game.Workspace:FindFirstChild("structures")
if not structuresContainer then
	structuresContainer = Instance.new("Folder")
	structuresContainer.Name = "structures"
	structuresContainer.Parent = game.Workspace
end

local function getPreviewModel(sourceModel: Model): Model
	local previewModel = sourceModel:Clone()
	previewModel:WaitForChild("nodes"):Destroy()
	for _, v in previewModel:GetDescendants() do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.CanQuery = false
			v.CanTouch = false
			v.CastShadow = false
			v.Transparency = 0.5
		end
	end
	return previewModel
end

local function mouseRaycast(params: RaycastParams?): (Vector3, RaycastResult?)
	local L = 200
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y, 0.1)
	local res = game.Workspace:Raycast(ray.Origin, ray.Direction * L, params)
	return if res then res.Position else ray.Origin + ray.Direction * L, res
end

local function getStructureFromInstance(instance: Instance?): Instance?
	while instance and instance.Parent ~= structuresContainer do
		instance = instance.Parent
	end
	return instance
end

local function onPreRenderBuildMode(previewModel: Model, rotation: number): (string, BasePart?)
	local rotationOffset = CFrame.Angles(0, rotation, 0)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { player.Character, previewModel }
	params.FilterType = Enum.RaycastFilterType.Exclude
	local pos, res = mouseRaycast(params)
	local prim = previewModel.PrimaryPart :: BasePart
	if res and res.Instance:IsDescendantOf(nodesContainer) then
		local attachmentTypes = res.Instance.Name:split(",")
		for _, name in attachmentTypes do
			local att = prim:FindFirstChild(name) :: Attachment?
			if att then
				previewModel:PivotTo(res.Instance.CFrame * rotationOffset * att.CFrame:Inverse())
				return ATTACHMENT_ROTATION_TYPE_MAP[name] or RotationTypes.Four, nil
			end
		end
	end

	local groundAtt = prim:FindFirstChild("ground") :: Attachment
	previewModel:PivotTo(CFrame.new(pos) * rotationOffset * groundAtt.CFrame:Inverse())
	local rotationType = if res and res.Instance.Anchored then RotationTypes.Ground else RotationTypes.Four
	return rotationType, if res and getStructureFromInstance(res.Instance) then res.Instance else nil
end

local function onPreRenderDeleteMode(): Model?
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { structuresContainer }
	params.FilterType = Enum.RaycastFilterType.Include
	local _, res = mouseRaycast(params)
	if not res then
		return
	end

	local structure = getStructureFromInstance(res.Instance)
	if not structure then
		return
	end

	return structure :: Model
end

local function integrateNode(structure: Model, node: BasePart): BasePart
	local origin = structure:GetPivot().Position
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { nodesContainer }
	params.FilterType = Enum.RaycastFilterType.Include

	local res = game.Workspace:Raycast(origin, node.Position - origin, params)
	if not res then
		node.Parent = nodesContainer
		Instance.new("ObjectValue", node).Value = structure
		return node
	end

	Instance.new("ObjectValue", res.Instance).Value = structure
	node:Destroy()
	return res.Instance
end

local function disintegrateNode(structure: Model, node: BasePart)
	for _, v in node:GetChildren() :: any do
		if v.Value == structure then
			v:Destroy()
			break
		end
	end

	if #node:GetChildren() == 0 then
		node:Destroy()
	end
end

local groundParams = RaycastParams.new()
groundParams.FilterDescendantsInstances = { game.Workspace:FindFirstChild("Baseplate") }
groundParams.FilterType = Enum.RaycastFilterType.Include
local function build(sourceModel: Model, cf: CFrame, weldTo: BasePart?)
	local model = sourceModel:Clone()
	model:PivotTo(cf)

	local nodeRefs = Instance.new("Folder")
	nodeRefs.Name = "nodeRefs"
	nodeRefs.Parent = model

	local welds = Instance.new("Folder")
	welds.Name = "welds"
	welds.Parent = model

	if weldTo then
		local w = Instance.new("WeldConstraint")
		w.Part0 = model.PrimaryPart :: BasePart
		w.Part1 = weldTo
		w.Parent = welds
	end

	local groundAtt = (model.PrimaryPart :: BasePart):FindFirstChild("ground") :: Attachment
	local groundRes = game.Workspace:Raycast(model:GetPivot().Position, groundAtt.CFrame.Position, groundParams)
	if groundRes then
		local w = Instance.new("WeldConstraint")
		w.Part0 = model.PrimaryPart :: BasePart
		w.Part1 = groundRes.Instance
		w.Parent = welds
	end

	local weldRefs = Instance.new("Folder")
	weldRefs.Name = "weldRefs"
	weldRefs.Parent = model

	local nodes = model:FindFirstChild("nodes") :: Folder
	for _, v in nodes:GetChildren() do
		local connectedToNode = integrateNode(model, v :: BasePart)

		for _, objValue in connectedToNode:GetChildren() :: any do
			local otherStructure = objValue.Value
			if otherStructure == model then
				continue
			end

			local w = Instance.new("WeldConstraint")
			w.Part0 = model.PrimaryPart :: BasePart
			w.Part1 = otherStructure.PrimaryPart :: BasePart
			w.Parent = welds

			Instance.new("ObjectValue", otherStructure.weldRefs).Value = w
		end

		local ref = Instance.new("ObjectValue")
		ref.Name = "ref"
		ref.Value = connectedToNode
		ref.Parent = nodeRefs
	end
	nodes:Destroy()

	for _, v in model:GetDescendants() do
		if v:IsA("BasePart") then
			v.Anchored = false
		end
	end

	model.Parent = structuresContainer
end

local function delete(model: Model)
	local nodeRefs = model:FindFirstChild("nodeRefs") :: Folder
	for _, v in nodeRefs:GetChildren() :: any do
		disintegrateNode(model, v.Value :: BasePart)
	end

	local weldRefs = model:FindFirstChild("weldRefs") :: Folder
	for _, v in weldRefs:GetChildren() :: any do
		v.Value:Destroy()
	end

	model:Destroy()
end

local tool = script.Parent
local rotations: any = setmetatable({}, {
	__index = function(t, i)
		return 0
	end,
})

local function setup(): () -> ()
	local deleteHighlight = Instance.new("Highlight")
	deleteHighlight.FillColor = Color3.new(1, 0, 0)
	deleteHighlight.OutlineColor = Color3.new(1, 1, 1)
	deleteHighlight.Parent = game:GetService("Lighting")

	local modelList = structureModels:GetChildren()
	local sourceModel
	local previewModel
	local function cycleModel(delta: number)
		if previewModel then
			previewModel:Destroy()
		end
		local i = table.find(modelList, sourceModel) or 1
		local j = ((i + delta - 1) % #modelList) + 1
		sourceModel = modelList[j]
		previewModel = getPreviewModel(sourceModel)
		previewModel.Parent = game.Workspace
	end
	cycleModel(0)

	local inDeleteMode = false
	local currentRotationType = RotationTypes.Four
	local currentWeldTo: BasePart?

	local connections = {
		RunService.PreRender:Connect(function()
			if inDeleteMode then
				deleteHighlight.Adornee = onPreRenderDeleteMode()
			else
				currentRotationType, currentWeldTo = onPreRenderBuildMode(
					previewModel,
					math.rad(ROTATIONS[currentRotationType][rotations[currentRotationType] + 1])
				)
			end
		end),

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			local isShiftDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			if input.KeyCode == Enum.KeyCode.R then
				if not inDeleteMode then
					rotations[currentRotationType] = (rotations[currentRotationType] + if isShiftDown then -1 else 1)
						% #ROTATIONS[currentRotationType]
				end
			elseif input.KeyCode == Enum.KeyCode.E then
				cycleModel(if isShiftDown then -1 else 1)
			elseif input.KeyCode == Enum.KeyCode.X then
				inDeleteMode = not inDeleteMode
				deleteHighlight.Enabled = inDeleteMode

				if inDeleteMode then
					previewModel.Parent = nil
				else
					previewModel.Parent = game.Workspace
				end
			end
		end),

		tool.Activated:Connect(function()
			if inDeleteMode then
				if deleteHighlight.Adornee then
					delete(deleteHighlight.Adornee :: Model)
				end
			else
				build(sourceModel, previewModel:GetPivot(), currentWeldTo)
			end
		end),
	}

	return function()
		for _, v in connections do
			v:Disconnect()
		end
		deleteHighlight:Destroy()
		previewModel:Destroy()
	end
end

tool.Equipped:Connect(function()
	local teardown = setup()
	tool.Unequipped:Once(teardown)
end)
