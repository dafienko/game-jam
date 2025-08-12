--!strict

return function(tool: Tool)
	tool.Activated:Connect(function()
		print("shoot")
	end)
end
