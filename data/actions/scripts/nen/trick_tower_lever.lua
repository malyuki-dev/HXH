local config = {
	requiredLevel = 50,
	globalStorage = 90000, -- Status da masmorra (0 = Vazia, 1 = Em uso)
	
	-- Posições de onde os jogadores devem estar pisando
	playerPositions = {
		Position(1000, 1000, 7),
		Position(1000, 1001, 7),
		Position(1001, 1000, 7),
		Position(1001, 1001, 7)
	},
	
	-- Para onde eles serão teleportados dentro da Torre
	newPositions = {
		Position(1050, 1050, 8),
		Position(1050, 1051, 8),
		Position(1051, 1050, 8),
		Position(1051, 1051, 8)
	},
	
	-- Onde os monstros vão nascer (centro da arena)
	arenaCenter = Position(1055, 1055, 8)
}

local function spawnWave(waveNum)
	-- Checa se a instância ainda tá rolando
	if Game.getStorageValue(config.globalStorage) ~= 1 then return end
	
	local center = config.arenaCenter
	if waveNum == 1 then
		Game.createMonster("Giant Forest Boar", Position(center.x - 1, center.y, center.z))
		Game.createMonster("Giant Forest Boar", Position(center.x + 1, center.y, center.z))
		Game.broadcastMessage("Trick Tower: Wave 1 has spawned!", MESSAGE_EVENT_ADVANCE)
	elseif waveNum == 2 then
		Game.createMonster("Giant Forest Boar", Position(center.x, center.y - 1, center.z))
		Game.createMonster("Giant Forest Boar", Position(center.x, center.y + 1, center.z))
		Game.broadcastMessage("Trick Tower: Wave 2 has spawned!", MESSAGE_EVENT_ADVANCE)
	elseif waveNum == 3 then
		local boss = Game.createMonster("Majtani", center)
		-- Como o Majtani será um boss especial, atrelamos o evento de morte nele!
		if boss then
			boss:registerEvent("TrickTowerBossDeath")
		end
		Game.broadcastMessage("Trick Tower: The Prisoner Majtani appears!", MESSAGE_EVENT_ADVANCE)
	end
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 1945 then
		-- Verifica se a Trick Tower está ocupada
		if Game.getStorageValue(config.globalStorage) == 1 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "The Trick Tower is currently occupied by another team. Please wait.")
			return true
		end

		local playersInPads = {}
		
		-- Verifica se há jogadores nos tiles corretos (precisamos de pelo menos 1 na primeira posição, mas vamos aceitar grupos menores pra facilitar o teste)
		for i = 1, #config.playerPositions do
			local tile = Tile(config.playerPositions[i])
			if tile then
				local p = tile:getTopCreature()
				if p and p:isPlayer() then
					if p:getLevel() < config.requiredLevel then
						player:sendTextMessage(MESSAGE_INFO_DESCR, "Player " .. p:getName() .. " does not have the required level (" .. config.requiredLevel .. ").")
						return true
					end
					table.insert(playersInPads, p)
				end
			end
		end
		
		if #playersInPads == 0 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You need a team on the trapdoors to enter.")
			return true
		end

		-- Tudo certo, vamos trancar a masmorra e teleportá-los
		Game.setStorageValue(config.globalStorage, 1)
		
		for i, p in ipairs(playersInPads) do
			p:teleportTo(config.newPositions[i])
			p:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			p:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Welcome to the Trick Tower! Survive the waves!")
		end
		
		-- Agenda as ondas (10 seg, 20 seg, 30 seg)
		addEvent(spawnWave, 5000, 1)
		addEvent(spawnWave, 15000, 2)
		addEvent(spawnWave, 25000, 3)
		
		item:transform(1946)
	elseif item.itemid == 1946 then
		item:transform(1945)
	end
	
	return true
end
