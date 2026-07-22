-- Hisoka's Bungee Gum (Borracha e Goma)
local STORAGE_BUNGEE_GUM = 80140

function onSay(player, words, param)
	local args = param:split(" ")
	local command = args[1]

	if not command then
		player:sendCancelMessage("Usage: !bungeegum attach <name> OR !bungeegum pull")
		return false
	end

	-- ATO 1: GRUDAR A GOMA (ATTACH)
	if command == "attach" then
		local targetName = args[2]
		if not targetName then
			player:sendCancelMessage("You must specify a target name to attach the Bungee Gum.")
			return false
		end

		local target = Player(targetName)
		if not target then
			player:sendCancelMessage("Target not found or offline.")
			return false
		end

		if target:getId() == player:getId() then
			player:sendCancelMessage("You cannot attach Bungee Gum to yourself.")
			return false
		end

		if player:getPosition():getDistance(target:getPosition()) > 7 then
			player:sendCancelMessage("Target is too far away to attach.")
			return false
		end

		-- Grava o GUID do Alvo na Memória do Jogador (A linha tênue)
		player:setStorageValue(STORAGE_BUNGEE_GUM, target:getGuid())
		
		player:say("Bungee Gum!", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		
		-- Efeito que mostra o grude no alvo
		target:getPosition():sendMagicEffect(CONST_ME_HEARTS)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You attached your aura to " .. target:getName() .. ".")
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "WARNING: " .. player:getName() .. " attached Bungee Gum to you!")
		return false
	end

	-- ATO 2: PUXAR A BORRACHA (PULL)
	if command == "pull" then
		local attachedGuid = player:getStorageValue(STORAGE_BUNGEE_GUM)
		
		if attachedGuid <= 0 then
			player:sendCancelMessage("You haven't attached Bungee Gum to anyone.")
			return false
		end

		local target = Player(attachedGuid) -- Em algumas distros funciona via GUID ou ID temporário, mas vamos garantir puxando via Nome/Busca. 
		
		-- Em TFS 1.x Player(guid) pode retornar nil. Vamos iterar online players para achar o guid.
		local foundTarget = nil
		for _, onlinePlayer in ipairs(Game.getPlayers()) do
			if onlinePlayer:getGuid() == attachedGuid then
				foundTarget = onlinePlayer
				break
			end
		end

		if not foundTarget then
			player:sendCancelMessage("The attached target is no longer online.")
			player:setStorageValue(STORAGE_BUNGEE_GUM, 0) -- Limpa a goma
			return false
		end

		local playerPos = player:getPosition()
		local targetPos = foundTarget:getPosition()

		if playerPos:getDistance(targetPos) > 10 then
			player:sendCancelMessage("The Bungee Gum snapped! The target went too far.")
			player:setStorageValue(STORAGE_BUNGEE_GUM, 0)
			return false
		end

		-- A Física Forçada
		player:say("Pull!", TALKTYPE_MONSTER_SAY)
		
		-- Efeitos de tração
		playerPos:sendMagicEffect(CONST_ME_MAGIC_RED)
		targetPos:sendMagicEffect(CONST_ME_POFF)

		-- Puxa o inimigo exatamente para a posição em que o Jogador está (Tile Adj/Stuck)
		foundTarget:teleportTo(playerPos, true)
		playerPos:sendMagicEffect(CONST_ME_TELEPORT)
		
		foundTarget:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You were violently pulled by Bungee Gum!")
		
		-- A goma elástica só serve pra um puxão. Ela rompe após o uso.
		player:setStorageValue(STORAGE_BUNGEE_GUM, 0)
		return false
	end

	return false
end
