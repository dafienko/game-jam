--!strict

local GameUtil = {}

local WALL_PART_SIZE = Vector3.new(5, 3, 2)
local WALL_GAP = 0.5

local BRIDGE_PART_SIZE = Vector3.new(6, 2, 6)

export type Blueprint = {
	{
		CFrame: CFrame,
		Size: Vector3,
		weldToIndices: { number },
	}
}

function GameUtil.generateWallBlueprint(width: number, height: number): Blueprint
	local blueprint = {}
	local lastRow
	for i = 0, height - 1 do
		local row = {}
		local parity = i % 2
		local nBricks = width - parity - 1
		local rowWidth = nBricks * WALL_PART_SIZE.X + (nBricks - 1) * WALL_GAP
		local rowStart = CFrame.new((WALL_PART_SIZE.X - rowWidth) / 2, WALL_PART_SIZE.Y * (i + 0.5), 0)
		for j = 1, nBricks do
			local welds = {}
			if lastRow then
				if lastRow[j] then
					table.insert(welds, lastRow[j])
				end
				local k = j + (parity * 2 - 1)
				if lastRow[k] then
					table.insert(welds, lastRow[k])
				end
			else
				table.insert(welds, -1)
			end

			table.insert(blueprint, {
				CFrame = rowStart * CFrame.new((j - 1) * (WALL_PART_SIZE.X + WALL_GAP), 0, 0),
				Size = WALL_PART_SIZE,
				weldToIndices = welds,
			})
			table.insert(row, #blueprint)
		end
		lastRow = row
	end
	return blueprint
end

function GameUtil.generateBridgeBlueprint(width: number, length: number): Blueprint
	local blueprint = {}
	local lastRow
	for i = 1, length do
		local rowWidth = BRIDGE_PART_SIZE.X * width
		local rowStart =
			CFrame.new((BRIDGE_PART_SIZE.X - rowWidth) / 2, -BRIDGE_PART_SIZE.Y / 2, (i - 1) * -BRIDGE_PART_SIZE.Z)
		local row = {}
		local lastIndex = nil
		for j = 1, width do
			local welds = { if lastRow then lastRow[j] else -1 }
			if lastIndex then
				table.insert(welds, lastIndex)
			end
			table.insert(blueprint, {
				CFrame = rowStart * CFrame.new((j - 1) * BRIDGE_PART_SIZE.X, 0, 0),
				Size = BRIDGE_PART_SIZE,
				weldToIndices = welds,
			})

			lastIndex = #blueprint
			table.insert(row, lastIndex)
		end
		lastRow = row
	end
	return blueprint
end

return GameUtil
