function onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	if creature:getName():lower() ~= "brion" then
		return true
	end
	
	local maxHealth = creature:getMaxHealth()
	local damageMap = creature:getDamageMap()
	local damagers = {}
	
	-- Itera pelo map de dano de todos que atacaram a Calamidade
	for id, damage in pairs(damageMap) do
		local p = Player(id)
		if p then
			local totalDamage = damage.total
			table.insert(damagers, {player = p, dmg = totalDamage})
			
			-- Se bateu pelo menos 1% da vida do World Boss, recebe loot
			if totalDamage >= (maxHealth * 0.01) then
				-- Item 2157: Gold Nugget (No nosso lore: Relíquia do Continente Negro)
				p:addItem(2157, 1)
				p:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received a Dark Continent Relic for your efforts against Brion!")
				p:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			end
		end
	end
	
	-- Calcula o Top 3 para o Broadcast
	table.sort(damagers, function(a, b) return a.dmg > b.dmg end)
	
	local broadcast = "The Calamity BRION has been defeated!\nTOP 3 HUNTERS:\n"
	for i = 1, math.min(3, #damagers) do
		broadcast = broadcast .. i .. ". " .. damagers[i].player:getName() .. " (" .. damagers[i].dmg .. " dmg)\n"
	end
	
	Game.broadcastMessage(broadcast, MESSAGE_EVENT_ADVANCE)
	
	return true
end
