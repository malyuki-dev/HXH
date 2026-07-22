-- Spider System (Genei Ryodan)

SpiderSystem = {
	STORAGE_SPIDER = 82000, -- Armazena o Número da Pata (1 a 13)
	MAX_SPIDERS = 13
}

function SpiderSystem.setupTable()
	local query = [[
		CREATE TABLE IF NOT EXISTS `spiders` (
			`player_id` INTEGER PRIMARY KEY,
			`spider_number` INTEGER NOT NULL UNIQUE
		);
	]]
	db.query(query)
end

function SpiderSystem.getAvailableSpiderNumber()
	local occupied = {}
	local res = db.storeQuery("SELECT `spider_number` FROM `spiders`")
	if res ~= false then
		repeat
			local num = result.getNumber(res, "spider_number")
			occupied[num] = true
		until not result.next(res)
		result.free(res)
	end

	for i = 1, SpiderSystem.MAX_SPIDERS do
		if not occupied[i] then
			return i
		end
	end
	
	return -1 -- Nenhuma vaga
end

function SpiderSystem.joinSpider(player)
	local currentSpider = player:getStorageValue(SpiderSystem.STORAGE_SPIDER)
	if currentSpider > 0 then
		return false, "You are already a Spider."
	end

	local vacantNumber = SpiderSystem.getAvailableSpiderNumber()
	if vacantNumber == -1 then
		return false, "The Phantom Troupe is currently full. You must kill a Spider to take their place."
	end

	-- Adiciona na DB
	db.query(string.format("INSERT INTO `spiders` (`player_id`, `spider_number`) VALUES (%d, %d)", player:getGuid(), vacantNumber))
	
	-- Seta a storage
	player:setStorageValue(SpiderSystem.STORAGE_SPIDER, vacantNumber)
	return true, "You have joined the Phantom Troupe! You are Spider #" .. vacantNumber .. "."
end

function SpiderSystem.usurpSpider(killer, victim)
	local spiderNum = victim:getStorageValue(SpiderSystem.STORAGE_SPIDER)
	if spiderNum > 0 then
		-- Remove do perdedor
		victim:setStorageValue(SpiderSystem.STORAGE_SPIDER, -1)
		db.query(string.format("DELETE FROM `spiders` WHERE `player_id` = %d", victim:getGuid()))
		
		-- Passa pro assassino (se o assassino ja não for aranha)
		if killer:getStorageValue(SpiderSystem.STORAGE_SPIDER) <= 0 then
			killer:setStorageValue(SpiderSystem.STORAGE_SPIDER, spiderNum)
			db.query(string.format("INSERT INTO `spiders` (`player_id`, `spider_number`) VALUES (%d, %d)", killer:getGuid(), spiderNum))
			
			Game.broadcastMessage("A new spider has spun its web. " .. killer:getName() .. " killed " .. victim:getName() .. " and is now Spider #" .. spiderNum .. "!", MESSAGE_EVENT_ADVANCE)
		else
			-- Se o assassino já for uma aranha, a vaga fica vazia (a perna cai)
			Game.broadcastMessage("A Spider leg has been severed. " .. victim:getName() .. " (Spider #" .. spiderNum .. ") was killed by " .. killer:getName() .. ".", MESSAGE_EVENT_ADVANCE)
		end
	end
end

SpiderSystem.setupTable()
