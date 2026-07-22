local VOW_STORAGE = 81000
local VOW_DURATION = 60000 -- 60 segundos
local EXHAUST_DURATION = 120000 -- 2 minutos de punição

-- Condição de Poder Divino (Buff)
local conditionVow = Condition(CONDITION_ATTRIBUTES)
conditionVow:setParameter(CONDITION_PARAM_TICKS, VOW_DURATION)
conditionVow:setParameter(CONDITION_PARAM_STAT_MAXHITPOINTS, 5000) -- +5000 HP Max
conditionVow:setParameter(CONDITION_PARAM_STAT_MAXMANAPOINTS, 5000) -- +5000 MP Max
conditionVow:setParameter(CONDITION_PARAM_SKILL_MELEE, 50) -- +50 Melee
conditionVow:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 50) -- +50 Dist
conditionVow:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 50) -- +50 ML

local conditionSpeed = Condition(CONDITION_HASTE)
conditionSpeed:setParameter(CONDITION_PARAM_TICKS, VOW_DURATION)
conditionSpeed:setParameter(CONDITION_PARAM_SPEED, 800) -- Haste extrema

-- Condição de Punição (Debuff/Exhaust)
local conditionExhaust = Condition(CONDITION_ATTRIBUTES)
conditionExhaust:setParameter(CONDITION_PARAM_TICKS, EXHAUST_DURATION)
conditionExhaust:setParameter(CONDITION_PARAM_SKILL_MELEE, -100)
conditionExhaust:setParameter(CONDITION_PARAM_SKILL_DISTANCE, -100)
conditionExhaust:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, -100)

local conditionSlow = Condition(CONDITION_PARALYZE)
conditionSlow:setParameter(CONDITION_PARAM_TICKS, EXHAUST_DURATION)
conditionSlow:setFormula(-0.9, 0, -0.9, 0) -- -90% de lentidão

local function applyPunishment(playerId)
	local player = Player(playerId)
	if not player then return end -- Se estiver offline não toma no momento, mas na volta a condition deveria persistir (TFS cuida disso, mas o HP não).
	
	-- Remove o Storage de controle
	player:setStorageValue(VOW_STORAGE, -1)
	
	-- Punição vital: HP e MP para 1
	player:addHealth(-(player:getHealth() - 1))
	player:addMana(-(player:getMana()))
	
	-- Aplica debuffs massivos
	player:addCondition(conditionExhaust)
	player:addCondition(conditionSlow)
	
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The Nen Vow has ended... Your life force is completely drained.")
	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	player:say("AAARGH...", TALKTYPE_MONSTER_SAY)
end

function onSay(player, words, param)
	-- Checa se já está sob efeito do juramento
	if player:getStorageValue(VOW_STORAGE) > 0 then
		player:sendCancelMessage("You are already under the effects of a Nen Vow.")
		return false
	end

	-- Aplica o Buff Absurdo
	player:addCondition(conditionVow)
	player:addCondition(conditionSpeed)
	
	-- Restaura HP e MP para o novo máximo
	player:addHealth(player:getMaxHealth())
	player:addMana(player:getMaxMana())
	
	player:setStorageValue(VOW_STORAGE, 1)
	
	player:say("I don't care if this is the end...", TALKTYPE_YELL)
	player:getPosition():sendMagicEffect(CONST_ME_THUNDER)
	player:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
	
	-- Transforma a outfit num "Gon-san" temporário
	local outfit = player:getOutfit()
	outfit.lookType = 12 -- (Id imaginário do Super Saiyan/Gon-san)
	player:setOutfit(outfit)
	
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have sacrificed your future for absolute power. You have 60 seconds.")
	
	-- Agenda a punição
	addEvent(applyPunishment, VOW_DURATION, player:getId())
	
	return false
end
