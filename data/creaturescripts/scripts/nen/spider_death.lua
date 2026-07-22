function onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	-- Se morreu de monstros ou field damage, ignoramos a usurpação. 
	-- O assassino PRECISA ser um Player pra pegar a vaga.
	
	if not killer then return true end
	
	local realKiller = false
	if killer:isPlayer() then
		realKiller = killer
	elseif killer:getMaster() and killer:getMaster():isPlayer() then
		realKiller = killer:getMaster() -- Summons de player contam
	end
	
	if realKiller then
		-- Confere se a vítima é uma aranha
		local victimSpiderNumber = player:getStorageValue(SpiderSystem.STORAGE_SPIDER)
		if victimSpiderNumber > 0 then
			-- Chama a função usurpadora
			SpiderSystem.usurpSpider(realKiller, player)
		end
	end
	
	return true
end
