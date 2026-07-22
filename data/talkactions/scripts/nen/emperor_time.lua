local STORAGE_EMPEROR_TIME = 85000

-- Criando a Condition Monstruosa de Emperor Time
local conditionEmperor = Condition(CONDITION_ATTRIBUTES)
conditionEmperor:setParameter(CONDITION_PARAM_TICKS, -1) -- Infinito até ser desligado
conditionEmperor:setParameter(CONDITION_PARAM_SKILL_MELEE, 50)
conditionEmperor:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 50)
conditionEmperor:setParameter(CONDITION_PARAM_SKILL_SHIELD, 50)
conditionEmperor:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 100)
conditionEmperor:setParameter(CONDITION_PARAM_SPEED, 200)

-- Função recursiva (Heartbeat de Dano)
local function EmperorTimeDrain(playerId)
	local player = Player(playerId)
	-- Se o jogador não existir mais ou a storage estiver desligada, paramos o loop
	if not player or player:getStorageValue(STORAGE_EMPEROR_TIME) <= 0 then
		return
	end
	
	-- Calcula 5% da Vida Máxima
	local drain = math.floor(player:getMaxHealth() * 0.05)
	if drain < 1 then drain = 1 end
	
	-- Aplica o True Damage
	-- Se a vida for menor que o drain, o jogador MORRE por exaustão de aura
	player:addHealth(-drain)
	player:getPosition():sendMagicEffect(CONST_ME_DRAWBLOOD)
	
	if player:getHealth() <= 0 then
		-- O jogador morreu pro próprio Nen
		player:setStorageValue(STORAGE_EMPEROR_TIME, 0)
		player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, conditionEmperor)
		Game.broadcastMessage(player:getName() .. " was consumed by their own Emperor Time aura and died.", MESSAGE_EVENT_ADVANCE)
		return
	end
	
	-- Reprograma o próximo hit (Recursividade após 1000ms = 1 segundo)
	addEvent(EmperorTimeDrain, 1000, playerId)
end

function onSay(player, words, param)
	local action = param:lower():trim()
	
	if action == "off" then
		if player:getStorageValue(STORAGE_EMPEROR_TIME) > 0 then
			player:setStorageValue(STORAGE_EMPEROR_TIME, 0)
			player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_DEFAULT, conditionEmperor)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You deactivated Emperor Time. The aura drain stops.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		else
			player:sendCancelMessage("Emperor Time is not active.")
		end
		return false
	end
	
	-- Ativação
	if player:getStorageValue(STORAGE_EMPEROR_TIME) > 0 then
		player:sendCancelMessage("Emperor Time is already active! Type '!emperortime off' to deactivate.")
		return false
	end
	
	player:setStorageValue(STORAGE_EMPEROR_TIME, 1)
	player:addCondition(conditionEmperor)
	
	player:say("EMPEROR TIME!", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "EMPEROR TIME ACTIVATED: Your aura is overflowing, but it is draining your life! Type '!emperortime off' to stop it before you die.")
	
	-- Dispara o loop
	EmperorTimeDrain(player:getId())
	
	return false
end
