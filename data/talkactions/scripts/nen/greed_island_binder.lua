-- Greed Island Binder Interface
-- Requer: data/lib/nen/greed_island_system.lua

-- Nomes Fictícios das Cartas (apenas como prova de conceito, os 99 podem ser definidos depois)
local CARD_NAMES = {
	[1] = "Patch of Forest",
	[2] = "Strip of Beach",
	[17] = "Breath of Archangel",
	[25] = "Risky Dice",
	[81] = "Blue Planet"
}

function onSay(player, words, param)
	-- Comando Provisório para Inserir Carta no DB
	if words == "!gaincard" then
		local cardId = tonumber(param)
		if not cardId then
			player:sendCancelMessage("Usage: !gaincard <1-99>")
			return false
		end
		
		player:addGreedIslandCard(cardId)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You gained Restricted Slot Card No. " .. string.format("%03d", cardId) .. "!")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		return false
	end

	-- O Binder Oficial (!book)
	if words == "!book" then
		player:say("Book!", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_TUTORIALARROW)
		
		-- Consulta o MySQL para buscar o Array completo de cartas
		local myCards = player:getGreedIslandBinder()
		
		local msg = "=== GREED ISLAND BINDER ===\n"
		msg = msg .. "Restricted Slots Owned: " .. #myCards .. "/100\n\n"
		
		if #myCards == 0 then
			msg = msg .. "Your Binder is completely empty."
		else
			for i, cardId in ipairs(myCards) do
				local name = CARD_NAMES[cardId] or "Unknown Card"
				msg = msg .. "[No. " .. string.format("%03d", cardId) .. "] - " .. name .. "\n"
			end
		end
		
		msg = msg .. "==========================="

		-- Renderiza o texto no Popup do Client
		player:showTextDialog(2000, msg)
		return false
	end

	return false
end
