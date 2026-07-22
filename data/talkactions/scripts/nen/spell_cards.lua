-- Unrestricted Spell Cards (Greed Island)

-- Coordenadas hardcoded para fins de demonstração Alpha das cidades do Continente GI
local GI_CITIES = {
	["antokiba"] = Position(1000, 1000, 7),
	["masadora"] = Position(1200, 1050, 7),
	["soufrabi"] = Position(1500, 1200, 7)
}

function onSay(player, words, param)
	-- Format: !spellcard magnetic "PlayerName" OR !spellcard accompany "Antokiba"
	local splitParam = string.split(param, "\"")
	if #splitParam < 2 then
		player:sendCancelMessage("Usage: !spellcard <card_name> \"<target_or_city>\"")
		return false
	end

	local cardType = splitParam[1]:trim():lower()
	local targetStr = splitParam[2]:trim()

	-- SPELL CARD 1014: MAGNETIC FORCE
	-- Transporta APENAS o usuário até outro jogador.
	if cardType == "magnetic" then
		local targetPlayer = Player(targetStr)
		if not targetPlayer then
			player:sendCancelMessage("The player '" .. targetStr .. "' is offline or does not exist.")
			return false
		end
		
		-- Animação de ativação do livro
		player:say("Magnetic Force ON!", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		
		-- Transporte Instantâneo
		player:teleportTo(targetPlayer:getPosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Magnetic Force teleported you to " .. targetPlayer:getName() .. ".")
		return false
	end

	-- SPELL CARD 1015: ACCOMPANY
	-- Transporta VOCÊ e todos os JOGADORES próximos até uma cidade ou jogador visitado.
	if cardType == "accompany" then
		local destPos = nil
		local cityDest = GI_CITIES[targetStr:lower()]
		
		if cityDest then
			destPos = cityDest
		else
			local targetPlayer = Player(targetStr)
			if targetPlayer then
				destPos = targetPlayer:getPosition()
			end
		end

		if not destPos then
			player:sendCancelMessage("Cannot find the destination '" .. targetStr .. "'.")
			return false
		end

		player:say("Accompany ON!", TALKTYPE_MONSTER_SAY)
		
		local centerPos = player:getPosition()
		centerPos:sendMagicEffect(CONST_ME_MAGIC_GREEN)

		-- Engine Core: Pega todo mundo que tá até 2 SQMs de distância
		local spectators = Game.getSpectators(centerPos, false, true, 2, 2, 2, 2)
		local count = 0

		-- O Arraste em Massa (Group Teleport)
		for _, spectator in ipairs(spectators) do
			if spectator:isPlayer() then
				spectator:teleportTo(destPos)
				spectator:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				count = count + 1
			end
		end

		-- Notifica o conjurador
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Accompany teleported " .. count .. " player(s) to the destination.")
		return false
	end

	player:sendCancelMessage("Unknown spell card.")
	return false
end
