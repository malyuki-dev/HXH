function onPrepareDeath(player, killer)
	if player:getStorageValue(HeavensArena.storageFighting) == 1 then
		-- Estamos na Heavens Arena!
		-- Bloqueia a morte pra não perder XP e Loot
		
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:teleportTo(HeavensArena.exitPos)
		player:setStorageValue(HeavensArena.storageFighting, 0)
		
		-- Anuncia a derrota
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have lost the match in the Heavens Arena.")
		
		-- O killer (se for jogador) ganha
		if killer and killer:isPlayer() and killer:getStorageValue(HeavensArena.storageFighting) == 1 then
			killer:addHealth(killer:getMaxHealth())
			killer:addMana(killer:getMaxMana())
			killer:teleportTo(HeavensArena.exitPos)
			killer:setStorageValue(HeavensArena.storageFighting, 0)
			
			killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are victorious in the Heavens Arena!")
			killer:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
			
			-- Adiciona pontos ao vencedor no Banco de Dados
			local res = db.storeQuery(string.format("SELECT `points` FROM `arena_points` WHERE `player_id` = %d", killer:getGuid()))
			if res ~= false then
				db.query(string.format("UPDATE `arena_points` SET `points` = `points` + 10, `wins` = `wins` + 1 WHERE `player_id` = %d", killer:getGuid()))
				result.free(res)
			else
				db.query(string.format("INSERT INTO `arena_points` (`player_id`, `points`, `wins`) VALUES (%d, 10, 1)", killer:getGuid()))
			end
			
			-- Adiciona loss ao perdedor
			local res2 = db.storeQuery(string.format("SELECT `points` FROM `arena_points` WHERE `player_id` = %d", player:getGuid()))
			if res2 ~= false then
				db.query(string.format("UPDATE `arena_points` SET `losses` = `losses` + 1 WHERE `player_id` = %d", player:getGuid()))
				result.free(res2)
			else
				db.query(string.format("INSERT INTO `arena_points` (`player_id`, `losses`) VALUES (%d, 1)", player:getGuid()))
			end
			
			Game.broadcastMessage("Heavens Arena: " .. killer:getName() .. " has defeated " .. player:getName() .. "!", MESSAGE_EVENT_ADVANCE)
		end
		
		-- Libera a arena pra próxima luta
		HeavensArena.isArenaOccupied = false
		
		return false -- Cancela a morte na engine!
	end

	return true
end
