-- Buy Black Whale Tickets (Talkaction)
-- Requer: data/lib/nen/black_whale_system.lua

local TIER_PRICES = {
	[1] = 1000000, -- VVIP (1 Milhão)
	[2] = 500000,  -- VIP
	[3] = 100000,  -- Middle Class
	[4] = 10000,   -- Lower
	[5] = 0        -- Escória (Gratuito)
}

function onSay(player, words, param)
	local tier = tonumber(param)
	
	if not tier or tier < 1 or tier > 5 then
		player:sendCancelMessage("Usage: !buyticket <1-5>")
		return false
	end

	local currentTier = player:getWhaleTier()
	if tier >= currentTier then
		player:sendCancelMessage("You already have this tier or a better one.")
		return false
	end

	local price = TIER_PRICES[tier]
	
	if not player:removeMoney(price) then
		player:sendCancelMessage("You need " .. price .. " gold coins to buy a Tier " .. tier .. " Ticket.")
		return false
	end

	player:setWhaleTier(tier)
	player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have successfully purchased a Tier " .. tier .. " Passport for the Black Whale!")
	
	return false
end
