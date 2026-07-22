local ACCOMPANY_MODAL_ID = 3001

function onModalWindow(player, modalWindowId, buttonId, choiceId)
	if modalWindowId ~= ACCOMPANY_MODAL_ID then
		return false
	end

	-- Cancel button
	if buttonId == 2 or buttonId == 255 then
		player:setStorageValue(80000, -1)
		return true
	end

	-- Accompany button
	if buttonId == 1 then
		local targetPlayer = Player(choiceId)
		
		-- Verifica se o jogador alvo ainda está online
		if not targetPlayer then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "The target player is no longer online or doesn't exist.")
			player:setStorageValue(80000, -1)
			return true
		end
		
		-- Verifica se a carta ainda está na mão do player (anti-cheat)
		local itemUid = player:getStorageValue(80000)
		if itemUid > 0 then
			local item = Item(itemUid)
			if item and item.itemid == 2018 then
				item:remove(1) -- Consome 1 carta
			else
				player:sendTextMessage(MESSAGE_INFO_DESCR, "Spell Card: Accompany not found.")
				player:setStorageValue(80000, -1)
				return true
			end
		else
			return true
		end
		
		player:setStorageValue(80000, -1)

		local targetPos = targetPlayer:getPosition()
		local oldPos = player:getPosition()
		
		-- Efeito de saída
		oldPos:sendMagicEffect(CONST_ME_BIGCLOUDS)
		oldPos:sendMagicEffect(CONST_ME_ENERGYAREA)
		
		-- Teleporta
		player:teleportTo(targetPos)
		
		-- Efeito de chegada
		targetPos:sendMagicEffect(CONST_ME_BIGCLOUDS)
		targetPos:sendMagicEffect(CONST_ME_ENERGYAREA)
		
		-- Opcional: Anúncio do voo
		player:say("ACCOMPANY ON!", TALKTYPE_MONSTER_SAY)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You flew to " .. targetPlayer:getName() .. ".")
		targetPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, player:getName() .. " flew to your location using Accompany!")
		
		return true
	end

	return false
end
