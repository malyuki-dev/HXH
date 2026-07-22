-- 100-Type Guanyin Bodhisattva Stance (Netero)
local STORAGE_BODHISATTVA = 80160

-- Condição de Paralisia Absoluta (Root)
local conditionRoot = Condition(CONDITION_PARALYZE)
conditionRoot:setParameter(CONDITION_PARAM_TICKS, -1)
-- Velocidade base de uma criatura no tibia é 200+. Subtrair 1000 trava o personagem (speed negativa/zero).
conditionRoot:setFormula(-1, 0, -1, 0) 

-- Condição de Defesa Colossal (Shield/Armor Buff)
local conditionDefense = Condition(CONDITION_ATTRIBUTES)
conditionDefense:setParameter(CONDITION_PARAM_TICKS, -1)
conditionDefense:setParameter(CONDITION_PARAM_SKILL_SHIELD, 150)

function onSay(player, words, param)
	local paramLower = param:lower()

	if paramLower == "on" then
		if player:getStorageValue(STORAGE_BODHISATTVA) == 1 then
			player:sendCancelMessage("Bodhisattva is already active.")
			return false
		end

		-- Ativa a Postura
		player:setStorageValue(STORAGE_BODHISATTVA, 1)
		player:addCondition(conditionRoot)
		player:addCondition(conditionDefense)

		player:say("100-Type Guanyin Bodhisattva!", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_HOLYDAMAGE)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You entered a state of absolute concentration. You cannot move, but your defense is immense.")
		return false
	end

	if paramLower == "off" then
		if player:getStorageValue(STORAGE_BODHISATTVA) <= 0 then
			player:sendCancelMessage("Bodhisattva is not active.")
			return false
		end

		-- Desativa a Postura
		player:setStorageValue(STORAGE_BODHISATTVA, 0)
		player:removeCondition(CONDITION_PARALYZE)
		player:removeCondition(CONDITION_ATTRIBUTES)

		player:say("Stance released.", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You left the Bodhisattva stance. You can move again.")
		return false
	end

	player:sendCancelMessage("Usage: !bodhisattva on / !bodhisattva off")
	return false
end
