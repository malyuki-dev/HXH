-- Emperor Time System (Kurapika's Specialization Stance)
-- Buff Absoluto de combate com Dreno Percentual Letal.

EmperorTime = {}
EmperorTime.Storage = 80161
EmperorTime.DrainPercent = 5 -- Drena 5% do MÁXIMO da vida e mana por segundo
EmperorTime.DrainInterval = 1000 -- 1 Segundo em MS

-- Configuração do Buff de Transe (Poder Absoluto)
local emperorCondition = Condition(CONDITION_ATTRIBUTES)
emperorCondition:setParameter(CONDITION_PARAM_TICKS, -1) -- Duração Infinita (Controlada via Storage)
emperorCondition:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 50) -- +50 Magic Level
emperorCondition:setParameter(CONDITION_PARAM_SKILL_MELEE, 50) -- +50 Físico
emperorCondition:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 50) -- +50 Distância
emperorCondition:setParameter(CONDITION_PARAM_SPEED, 300) -- Haste Absoluto

-- Configuração do Debuff de Fadiga Letal (Exaustão Punitiva)
local fatigueCondition = Condition(CONDITION_PARALYZE)
fatigueCondition:setParameter(CONDITION_PARAM_TICKS, 10000) -- 10 Segundos cravados no chão
fatigueCondition:setFormula(-1, 0, -1, 0) -- -100% de Velocidade

function EmperorTime.start(player)
	if player:getStorageValue(EmperorTime.Storage) == 1 then
		return false
	end

	player:setStorageValue(EmperorTime.Storage, 1)
	player:addCondition(emperorCondition)
	
	player:say("EMPEROR TIME!", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your eyes turn Scarlet. You are sacrificing your lifespan for absolute power.")

	-- Inicia a queima da vitalidade (Loop)
	addEvent(EmperorTime.lifeSpanDrain, EmperorTime.DrainInterval, player:getId())
	return true
end

function EmperorTime.stop(player, isFatigue)
	if player:getStorageValue(EmperorTime.Storage) <= 0 then
		return false
	end

	-- Desliga o Estado e Remove Buffs
	player:setStorageValue(EmperorTime.Storage, 0)
	player:removeCondition(CONDITION_ATTRIBUTES)
	
	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	
	if isFatigue then
		-- Aplica a exaustão letal por estourar o limite
		player:addCondition(fatigueCondition)
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "EMPEROR TIME BROKEN: Your body collapses from extreme exhaustion.")
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Emperor Time deactivated.")
	end

	return true
end

-- O Fogo Letal Assíncrono
function EmperorTime.lifeSpanDrain(playerId)
	local player = Player(playerId)
	if not player then return false end

	-- Se o transe foi desligado externamente, mata o loop
	if player:getStorageValue(EmperorTime.Storage) <= 0 then
		return false
	end

	local maxHealth = player:getMaxHealth()
	local maxMana = player:getMaxMana()
	
	-- Cálculo de 5% de queimação
	local healthDrain = math.floor(maxHealth * (EmperorTime.DrainPercent / 100))
	local manaDrain = math.floor(maxMana * (EmperorTime.DrainPercent / 100))

	-- Ponto Crítico de Exaustão (Se a vida for menor que 5%, o corpo cede)
	if player:getHealth() <= healthDrain then
		EmperorTime.stop(player, true) -- Desliga com Fadiga Absoluta
		return false
	end

	-- Aplica Dano Fixo de Sangramento (Ignora Defesas)
	player:addHealth(-healthDrain)
	player:addMana(-manaDrain)
	
	-- Feedback Visual Leve do Dreno para indicar perigo
	player:getPosition():sendMagicEffect(CONST_ME_HITAREA)
	
	-- Se chama pro próximo segundo
	addEvent(EmperorTime.lifeSpanDrain, EmperorTime.DrainInterval, playerId)
end
