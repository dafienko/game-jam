--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerData = require(ServerScriptService.main.PlayerData)
local Products = require(ReplicatedStorage.modules.game.Products)

type ProductFunction = (receiptInfo: any, player: Player) -> boolean

local function getBrickProductHandler(amount: number): ProductFunction
	return function(receiptInfo, player: Player)
		return PlayerData.addPoints(player, amount)
	end
end

local function onTripleRocketLauncherPurchase(receiptInfo, player: Player): boolean
	player:SetAttribute(Products.GamePasses.tripleRocketLauncher.attribute, true)
	return true
end

local function onDoubleBricksPurchase(receiptInfo, player: Player): boolean
	player:SetAttribute(Products.GamePasses.doubleBricks.attribute, true)
	return true
end

local productFunctions: { [number]: ProductFunction } = {
	[Products.DevProducts.smallBrickPack.id] = getBrickProductHandler(1000),
	[Products.DevProducts.mediumBrickPack.id] = getBrickProductHandler(3500),
	[Products.DevProducts.largeBrickPack.id] = getBrickProductHandler(15000),

	[Products.GamePasses.tripleRocketLauncher.id] = onTripleRocketLauncherPurchase,
	[Products.GamePasses.doubleBricks.id] = onDoubleBricksPurchase,
}

return function(receiptInfo)
	print("ProcessReceipt", "playerId:", receiptInfo.PlayerId, "productId:", receiptInfo.ProductId, receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	local player = Players:GetPlayerByUserId(userId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profileLoaded = PlayerData.waitForProfile(player)
	if not profileLoaded then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local handler = productFunctions[productId]
	assert(handler, `invalid productId '{productId}`)
	local success, result = pcall(handler, receiptInfo, player)
	if not (success and result) then
		warn(`Failed to process receipt:`, receiptInfo, success, result)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end
