-- Phantom Troupe PvP Succession System
-- O sistema que permite roubar a tatuagem da Aranha ao matar um membro

-- Requer: data/lib/nen/phantom_troupe.lua

function onKill(player, target)
	-- Checa se quem morreu é um jogador (PvP)
	if not target:isPlayer() then return true end

	local killer = player
	local victim = target

	-- Checa se a vítima era uma Aranha
	local victimSpiderNumber = victim:getSpiderNumber()
	
	if victimSpiderNumber then
		-- O assassino rouba a tatuagem!
		
		-- 1. Remove a tatuagem do morto
		victim:removeSpiderTattoo()
		
		-- 2. Insere a tatuagem no assassino
		killer:setSpiderNumber(victimSpiderNumber)

		-- Efeito dramático no assassino
		killer:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
		killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have killed a Phantom Troupe member. You are now Spider #" .. victimSpiderNumber .. ".")
		
		-- Efeito dramático na vítima
		victim:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You were killed and lost your position in the Phantom Troupe.")
		
		-- Mensagem Global no Servidor (Broadcast)
		Game.broadcastMessage("The Spider #" .. victimSpiderNumber .. " has fallen. " .. killer:getName() .. " has taken their place in the Phantom Troupe!", MESSAGE_STATUS_WARNING)
	end

	return true
end
