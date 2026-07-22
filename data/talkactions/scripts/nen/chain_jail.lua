-- Chain Jail (Kurapika's Vow)
local conditionParalyze = Condition(CONDITION_PARALYZE)
conditionParalyze:setParameter(CONDITION_PARAM_TICKS, 10000) -- 10 segundos
conditionParalyze:setParameter(CONDITION_PARAM_SPEED, -1000) -- Paralisia total

function onSay(player, words, param)
	local targetName = param:trim()
	
	if targetName == "" then
		player:sendCancelMessage("Usage: !chainjail \"TargetName\"")
		return false
	end

	local target = Player(targetName)
	if not target then
		player:sendCancelMessage("Target not found or offline.")
		return false
	end

	if target:getId() == player:getId() then
		player:sendCancelMessage("You cannot use Chain Jail on yourself.")
		return false
	end

	if player:getPosition():getDistance(target:getPosition()) > 7 then
		player:sendCancelMessage("Target is too far away.")
		return false
	end

	-- Verificar na base de dados se o Target é uma aranha (Tabela 'spiders')
	local isSpider = false
	local targetPlayerId = target:getGuid()
	
	local res = db.storeQuery(string.format("SELECT `player_id` FROM `spiders` WHERE `player_id` = %d LIMIT 1", targetPlayerId))
	if res ~= false then
		isSpider = true
		result.free(res)
	end

	player:say("CHAIN JAIL!", TALKTYPE_MONSTER_SAY)

	if isSpider then
		-- Target is a Spider: Paralyse and Damage
		target:addCondition(conditionParalyze)
		target:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have been wrapped in Kurapika's Chain Jail. You cannot move!")
		
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Chain Jail successful! The Spider is trapped.")
	else
		-- Target is NOT a spider: Vow broken. Instant Death.
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Vow broken! You used Chain Jail on a non-Spider!")
		player:getPosition():sendMagicEffect(CONST_ME_DRAWBLOOD)
		
		-- Kill the player instantly
		local damage = player:getHealth()
		doTargetCombatHealth(0, player, COMBAT_PHYSICALDAMAGE, -damage, -damage, CONST_ME_BLOCKHIT)
		
		player:say("Judgment Chain pierced my heart...", TALKTYPE_MONSTER_SAY)
	end

	return false
end
