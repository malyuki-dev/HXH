-- Godspeed (Kanmuru) - Killua's Lightning Mode
local STORAGE_GODSPEED = 80130

-- Configuração do Dreno de Mana (5% da mana máxima a cada 1 segundo)
local MANA_DRAIN_PERCENT = 0.05 
local TICK_INTERVAL_MS = 1000

-- Buff de Velocidade Divina (Speed +1000)
local conditionGodHaste = Condition(CONDITION_HASTE)
conditionGodHaste:setParameter(CONDITION_PARAM_TICKS, -1) -- Infinito (Até ser desativado)
conditionGodHaste:setParameter(CONDITION_PARAM_SPEED, 1000)

-- Buff de Atributos Físicos e Evasão
local conditionGodStats = Condition(CONDITION_ATTRIBUTES)
conditionGodStats:setParameter(CONDITION_PARAM_TICKS, -1)
conditionGodStats:setParameter(CONDITION_PARAM_SKILL_MELEE, 50)
conditionGodStats:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 50)
conditionGodStats:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 10)

-- Função Recursiva (O Motor Elétrico)
local function godspeedLoop(playerId)
	local player = Player(playerId)
	if not player then return end

	-- Verifica se a chave do motor ainda está ligada na memória
	if player:getStorageValue(STORAGE_GODSPEED) <= 0 then return end

	local maxMana = player:getMaxMana()
	local drainAmount = math.max(10, math.floor(maxMana * MANA_DRAIN_PERCENT))
	local currentMana = player:getMana()

	-- Se não tiver mana suficiente, ocorre o Curto-Circuito
	if currentMana < drainAmount then
		player:setStorageValue(STORAGE_GODSPEED, 0)
		player:removeCondition(CONDITION_HASTE)
		player:removeCondition(CONDITION_ATTRIBUTES)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your aura reserves are depleted. Godspeed deactivated.")
		player:say("Short-Circuit...", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return
	end

	-- Drena a Mana e cria os relâmpagos
	player:addMana(-drainAmount)
	player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
	
	-- Agenda o próximo pulso daqui a 1 segundo
	addEvent(godspeedLoop, TICK_INTERVAL_MS, playerId)
end

function onSay(player, words, param)
	local isActive = player:getStorageValue(STORAGE_GODSPEED) > 0

	if isActive then
		-- DESLIGA O MODO
		player:setStorageValue(STORAGE_GODSPEED, 0)
		player:removeCondition(CONDITION_HASTE)
		player:removeCondition(CONDITION_ATTRIBUTES)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Godspeed deactivated.")
		player:say("Kanmuru Off.", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	else
		-- LIGA O MODO
		if player:getMana() < (player:getMaxMana() * MANA_DRAIN_PERCENT) then
			player:sendCancelMessage("You don't have enough Nen to start Godspeed.")
			return false
		end

		player:setStorageValue(STORAGE_GODSPEED, 1)
		player:addCondition(conditionGodHaste)
		player:addCondition(conditionGodStats)
		
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Godspeed activated! Your Nen is draining rapidly.")
		player:say("Kanmuru! Godspeed!", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_BIGCLOUDS)
		
		-- Dá a partida no Motor Elétrico
		godspeedLoop(player:getId())
	end

	return false
end
