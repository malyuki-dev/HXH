-- Killua's Godspeed (Kanmuru) System
-- Motor de Eletricidade e Dreno

Godspeed = {}
Godspeed.Storage = 80165 -- Status On/Off
Godspeed.AuraDrain = 20 -- Aura perdida por segundo

-- Cria a Condição de Velocidade Extrema (+2000 Speed)
local speedCondition = Condition(CONDITION_HASTE)
speedCondition:setParameter(CONDITION_PARAM_TICKS, -1) -- Infinito enquanto estiver ativo
speedCondition:setParameter(CONDITION_PARAM_SPEED, 1500)
speedCondition:setParameter(CONDITION_PARAM_SUBID, 801)

-- Cria a Condição de Micro-Stun para os inimigos (Choque)
local stunCondition = Condition(CONDITION_PARALYZE)
stunCondition:setParameter(CONDITION_PARAM_TICKS, 1000) -- Duração de 1 segundo
stunCondition:setFormula(-0.9, 0, -0.9, 0) -- -90% de velocidade
Godspeed.StunCondition = stunCondition

-- O Loop infinito que gasta aura
function Godspeed.drainLoop(playerId)
	local player = Player(playerId)
	if not player then return end

	-- Se desligou a storage, cancela tudo
	if player:getStorageValue(Godspeed.Storage) <= 0 then
		Godspeed.turnOff(player)
		return
	end

	-- Se não tem mana, desliga sozinho (Burnout)
	if player:getMana() < Godspeed.AuraDrain then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your aura ran out. Godspeed deactivated.")
		Godspeed.turnOff(player)
		return
	end

	-- Gasta a mana
	player:addMana(-Godspeed.AuraDrain)
	
	-- Efeitos visuais elétricos pelo corpo do jogador
	player:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
	
	-- Chama o loop daqui a 1 segundo novamente (Asynchronous Lua Hook)
	addEvent(Godspeed.drainLoop, 1000, playerId)
end

function Godspeed.turnOn(player)
	if player:getStorageValue(Godspeed.Storage) > 0 then
		player:sendCancelMessage("Godspeed is already active.")
		return false
	end

	if player:getMana() < 100 then
		player:sendCancelMessage("You need at least 100 Aura to activate Godspeed.")
		return false
	end

	player:setStorageValue(Godspeed.Storage, 1)
	player:addCondition(speedCondition)
	
	player:say("GODSPEED!", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_BIGCLOUDS)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You activated Godspeed. Your neurons are accelerating.")

	-- Inicia o dreno
	Godspeed.drainLoop(player:getId())
	return true
end

function Godspeed.turnOff(player)
	player:setStorageValue(Godspeed.Storage, 0)
	player:removeCondition(CONDITION_HASTE, CONDITIONID_DEFAULT, 801)
	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Godspeed deactivated.")
	return true
end
