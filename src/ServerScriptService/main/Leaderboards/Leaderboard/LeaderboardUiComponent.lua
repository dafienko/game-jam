--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Cryo = require(ReplicatedStorage.modules.dependencies.Cryo)
local React = require(ReplicatedStorage.modules.dependencies.React)
local GameUtil = require(ReplicatedStorage.modules.game.GameUtil)

local LeaderboardRowComponent = require(script.Parent.LeaderboardRowComponent)

type RowData = {
	userId: number,
	userName: string?,
	displayName: string?,
	value: number,
}

export type DataTable = { RowData }

type Props = { data: DataTable, title: string }

return function(props: Props)
	local thumbnails, setThumbnails = React.useState({})

	local useRows = table.move(props.data, 1, math.min(10, #props.data), 1, {})
	React.useEffect(function()
		local canceled = false
		local userIds = Cryo.Dictionary.map(useRows, function(row)
			return row.userId
		end)

		local done = 0
		local thumbnails = {}
		for _, v in userIds do
			task.spawn(function()
				xpcall(function()
					thumbnails[v] =
						Players:GetUserThumbnailAsync(v, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end, warn)

				if canceled then
					return
				end

				done += 1
				if done == #userIds then
					setThumbnails(thumbnails)
				end
			end)
		end

		return function()
			canceled = true
		end
	end, { props.data })

	local rows, setRows = React.useState({})
	React.useEffect(function()
		local function mapRowToComponent(row: RowData, index: number): any
			return React.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.1),
				LayoutOrder = index,
				BackgroundColor3 = Color3.fromHSV(0, 0, 1),
				BorderSizePixel = 0,
				BackgroundTransparency = 1 - (index % 2) * 0.15,
			}, {
				content = React.createElement(LeaderboardRowComponent, {
					name = row.userName,
					displayName = row.displayName,
					thumbnail = thumbnails[row.userId],
					valueString = GameUtil.commaNumber(row.value),
				}),
			}),
				tostring(index)
		end

		setRows(Cryo.Dictionary.map(useRows, mapRowToComponent))
	end, { props.data, thumbnails })

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
		layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		title = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 72),
			BackgroundTransparency = 1,
			TextScaled = true,
			TextColor3 = Color3.fromHSV(0, 0, 1),
			Text = props.title,
		}, {
			padding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
			}),
		}),
		bottom = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
		}, {
			grow = React.createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Grow,
			}),
			layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			rows = React.createElement(React.Fragment, nil, rows),
		}),
	})
end
