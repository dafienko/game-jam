--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.modules.dependencies.React)
local ReactRoblox = require(ReplicatedStorage.modules.dependencies.ReactRoblox)

local MainUiComponent = require(script.Parent.MainUiComponent)

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(MainUiComponent))

	return function()
		root:unmount()
	end
end
