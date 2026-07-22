-- Configuração dos Portões Zoldyck (Tiers 1 a 7)
-- Baseado no peso que o jogador consegue erguer

local GATES = {
	[5001] = { tier = 1, requiredStrength = 100, weightMsg = "2 tons" },
	[5002] = { tier = 2, requiredStrength = 200, weightMsg = "4 tons" },
	[5003] = { tier = 3, requiredStrength = 400, weightMsg = "8 tons" },
	[5004] = { tier = 4, requiredStrength = 800, weightMsg = "16 tons" },
	[5005] = { tier = 5, requiredStrength = 1600, weightMsg = "32 tons" },
	[5006] = { tier = 6, requiredStrength = 3200, weightMsg = "64 tons" },
	[5007] = { tier = 7, requiredStrength = 6400, weightMsg = "128 tons" }
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local gateInfo = GATES[item:getActionId()]
	if not gateInfo then return false end
	
	-- Cálculo de Força Bruta Pura (Level + Capacidade Ociosa)
	-- A capacidade (FreeCap) no Tibia geralmente escala com o level, vamos usar como representação de músculos.
	local strength = (player:getLevel() * 5) + (player:getFreeCapacity() / 100)
	
	if strength >= gateInfo.requiredStrength then
		-- O jogador passou no teste
		local dir = player:getDirection()
		local passPos = player:getPosition()
		
		-- Calcula pra onde ele vai ser arremessado baseado na direção que ele está olhando
		if dir == DIRECTION_NORTH then passPos.y = passPos.y - 2
		elseif dir == DIRECTION_SOUTH then passPos.y = passPos.y + 2
		elseif dir == DIRECTION_WEST then passPos.x = passPos.x - 2
		elseif dir == DIRECTION_EAST then passPos.x = passPos.x + 2
		end
		
		-- Teleporta 2 blocos (Atravessando o portão)
		player:teleportTo(passPos)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "With a mighty roar, you push open Gate " .. gateInfo.tier .. " (" .. gateInfo.weightMsg .. ") of the Zoldyck Estate!")
		
		-- Efeitos de pedras caindo e fumaça
		item:getPosition():sendMagicEffect(CONST_ME_STONES)
		passPos:sendMagicEffect(CONST_ME_POFF)
	else
		-- Falha
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You try to push Gate " .. gateInfo.tier .. " (" .. gateInfo.weightMsg .. "), but it doesn't even budge. You are too weak.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end
	
	return true
end
