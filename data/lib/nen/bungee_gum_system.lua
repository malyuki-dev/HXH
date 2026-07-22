-- Hisoka's Bungee Gum System
-- Vector Calculations and Target RAM Mapping

BungeeGum = {}
BungeeGum.Storage = 80163 -- Armazena o ID (UID) da criatura grudada
BungeeGum.MaxDistance = 10 -- Raio máximo que o elástico aguanta sem quebrar (SQM)

-- Retorna a Posição Matemática exatamente na Frente do jogador (1 SQM)
function BungeeGum.getFrontPosition(player)
	local pos = player:getPosition()
	local dir = player:getDirection()
	
	if dir == DIRECTION_NORTH then
		pos.y = pos.y - 1
	elseif dir == DIRECTION_SOUTH then
		pos.y = pos.y + 1
	elseif dir == DIRECTION_EAST then
		pos.x = pos.x + 1
	elseif dir == DIRECTION_WEST then
		pos.x = pos.x - 1
	end
	
	return pos
end

function BungeeGum.attach(player, target)
	-- Salva o Entity ID da criatura/player na RAM da Storage do jogador
	player:setStorageValue(BungeeGum.Storage, target:getId())
	
	player:say("Bungee Gum!", TALKTYPE_MONSTER_SAY)
	target:getPosition():sendMagicEffect(CONST_ME_HEARTS) -- Simulando efeito chiclete rosa
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your Bungee Gum has attached to " .. target:getName() .. ".")
	return true
end

function BungeeGum.pull(player)
	local targetId = player:getStorageValue(BungeeGum.Storage)
	if targetId <= 0 then
		player:sendCancelMessage("Your Bungee Gum is not attached to anyone.")
		return false
	end

	-- Limpa a RAM (A Goma se retrai e solta)
	player:setStorageValue(BungeeGum.Storage, 0)

	local target = Creature(targetId)
	if not target then
		player:sendCancelMessage("The target is dead or too far away.")
		return false
	end

	local playerPos = player:getPosition()
	local targetPos = target:getPosition()
	
	-- Se não for no mesmo andar ou muito longe, a borracha arrebenta
	if playerPos.z ~= targetPos.z or playerPos:getDistance(targetPos) > BungeeGum.MaxDistance then
		player:sendCancelMessage("The target is out of Bungee Gum's elastic range. It snapped.")
		return false
	end

	local pullPos = BungeeGum.getFrontPosition(player)
	
	-- Verifica se o quadrado na frente do jogador é andável (Não é parede)
	local tile = Tile(pullPos)
	if not tile or tile:hasProperty(CONST_PROP_BLOCKSOLID) then
		player:sendCancelMessage("There is no space in front of you to pull the target.")
		return false
	end

	-- Física Bruta: Teleporta o inimigo esfregando no chão
	target:getPosition():sendMagicEffect(CONST_ME_POFF) -- Fumaça de onde ele saiu
	target:teleportTo(pullPos, true)
	
	-- Efeitos no destino e Dano de Impacto (Colisão)
	pullPos:sendMagicEffect(CONST_ME_STUN)
	doTargetCombatHealth(player:getId(), target, COMBAT_PHYSICALDAMAGE, -100, -300, CONST_ME_NONE)
	
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You pulled " .. target:getName() .. " with Bungee Gum!")
	
	return true
end
