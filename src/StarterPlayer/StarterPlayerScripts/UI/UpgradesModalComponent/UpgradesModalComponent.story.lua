--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local ReactRoblox = require(ReplicatedStorage.modules.dependencies.ReactRoblox)

local UpgradesModalComponent = require(script.Parent)

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(UpgradesModalComponent))

	return function()
		root:unmount()
	end
end
