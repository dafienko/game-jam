--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local collectFxTemplate = ReplicatedStorage.assets.collectFx

local POOL_SIZE = 20

local collectFxFolder = Instance.new("Folder")
collectFxFolder.Name = "collectFx"
collectFxFolder.Parent = game.Workspace

local poolIndex = 1
local pool: { { part: Part, sound: Sound, particleEmitter: ParticleEmitter, readyAt: number } } = {}
for i = 1, POOL_SIZE do
	local clone = collectFxTemplate:Clone()
	clone.ParticleEmitter.Enabled = false
	clone.Parent = collectFxFolder

	table.insert(pool, {
		part = clone,
		sound = clone.sound,
		particleEmitter = clone.ParticleEmitter,
		readyAt = 0,
	})
end

return {
	fxAt = function(cf: CFrame, size: Vector3, color: Color3)
		local i = poolIndex
		local instance = pool[i]
		if time() < instance.readyAt then
			return
		end
		poolIndex = poolIndex % POOL_SIZE + 1

		instance.particleEmitter.Color = ColorSequence.new(color)
		instance.sound:Play()
		instance.part.Size = size
		instance.part.CFrame = cf
		instance.particleEmitter:Emit(size.X * size.Y * size.Z)
		instance.readyAt = time() + 1.5
	end,
}
