--!strict

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")

local Util = require(ServerScriptService.Util)

local IDLE_DAMAGE = 5
local SLASH_DAMAGE = 10
local LUNGE_DAMAGE = 30
local SLASH_ANIMATION = "rbxassetid://522635514"
local LUNGE_ANIMATION = "rbxassetid://522638767"

local slashAnimation = Instance.new("Animation")
slashAnimation.AnimationId = SLASH_ANIMATION

local lungeAnimation = Instance.new("Animation")
lungeAnimation.AnimationId = LUNGE_ANIMATION

return function(tool: Tool, model: Model)
	local prim = model and model.PrimaryPart
	local lungeSound = prim and prim:FindFirstChild("lunge") :: Sound?
	local slashSound = prim and prim:FindFirstChild("slash") :: Sound?
	local unsheathSound = prim and prim:FindFirstChild("unsheath") :: Sound?
	if not (prim and lungeSound and slashSound and unsheathSound) then
		return
	end

	local equipped = false
	local myHumanoid: Humanoid?
	local myPlayer: Player?
	local slashAnimationTrack: AnimationTrack?
	local lungeAnimationTrack: AnimationTrack?
	local function canDamage()
		return equipped and myHumanoid and myHumanoid.Health > 0
	end

	local function slash()
		slashSound:Play()
		if slashAnimationTrack then
			slashAnimationTrack:Play()
		end
	end

	local function lunge()
		lungeSound:Play()
		if lungeAnimationTrack then
			lungeAnimationTrack:Play()
		end

		local force = Instance.new("BodyVelocity")
		force.Velocity = Vector3.new(0, 10, 0)
		force.MaxForce = Vector3.new(0, 4000, 0)
		force.Parent = prim
		Debris:AddItem(force, 0.4)

		task.wait(0.2)
		tool.Grip = CFrame.Angles(math.pi / 2, 0, 0)
		task.wait(0.4)
		tool.Grip = CFrame.new()
	end

	tool.Equipped:Connect(function()
		equipped = true
		unsheathSound:Play()

		local char = tool.Parent
		myPlayer = Players:GetPlayerFromCharacter(char)
		myHumanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
		if myHumanoid then
			local animator = myHumanoid:FindFirstChild("Animator") :: Animator? or Instance.new("Animator", myHumanoid)
			slashAnimationTrack = animator:LoadAnimation(slashAnimation)
			lungeAnimationTrack = animator:LoadAnimation(lungeAnimation)
		end
	end)

	tool.Unequipped:Connect(function()
		equipped = false
		myHumanoid = nil
		slashAnimationTrack = nil
		lungeAnimationTrack = nil
	end)

	local lastAttackTime = 0
	local damage = IDLE_DAMAGE
	tool.Activated:Connect(function()
		tool.Enabled = false
		local t = time()
		if t - lastAttackTime < 0.2 then
			lunge()
			damage = LUNGE_DAMAGE
		else
			slash()
			damage = SLASH_DAMAGE
		end

		lastAttackTime = t
		tool.Enabled = true
	end)

	local lastDamageTime = 0
	prim.Touched:Connect(function(hit)
		if not (myPlayer and canDamage()) then
			return
		end

		if time() - lastDamageTime < 0.1 then
			return
		end

		local otherPlayer, otherCharacter = Util.getPlayerAndCharacterFromInstance(hit)
		if not (otherPlayer and otherCharacter) then
			return
		end

		if not Util.canTeamAttackTeam(myPlayer.Team, otherPlayer.Team) then
			return
		end

		Util.playerDamageCharacter(myPlayer, otherCharacter, damage)
		lastDamageTime = time()
	end)
end
