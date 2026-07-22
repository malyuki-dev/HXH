function onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	if not player or not killer then
		return true
	end

	-- Somente se o killer for outro Player (PvP)
	if not killer:isPlayer() then
		return true
	end
	
	if player:getId() == killer:getId() then
		return true -- Suicídio não conta
	end

	local targetName = player:getName()
	
	-- Verifica se o morto tinha recompensa na cabeça
	local resultId = db.storeQuery(string.format("SELECT `id`, `amount` FROM `bounty_system` WHERE `target_name` = %s", db.escapeString(targetName)))
	
	if resultId ~= false then
		local bountyId = result.getNumber(resultId, "id")
		local amount = result.getNumber(resultId, "amount")
		result.free(resultId)
		
		-- Deleta a recompensa do banco
		db.query(string.format("DELETE FROM `bounty_system` WHERE `id` = %d", bountyId))
		
		-- Paga o assassino no banco (update SQL direto para cobrir se ele estiver offline ou online)
		-- Aqui faremos a função em Lua se ele estiver online para notificar:
		killer:setBankBalance(killer:getBankBalance() + amount)
		
		killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You claimed a bounty of " .. amount .. " gold coins for killing " .. targetName .. "!")
		killer:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
		
		-- Anúncio global
		Game.broadcastMessage("Blacklist Hunter " .. killer:getName() .. " has claimed the bounty of " .. amount .. " gold on " .. targetName .. "'s head!", MESSAGE_EVENT_ADVANCE)
	end
	
	return true
end
