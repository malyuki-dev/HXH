-- O Rito de Passagem: Water Divination (Action Script)
-- O jogador dá "Use" no copo de adivinhação.
-- Requer: data/lib/nen/nen_divination.lua

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Verifica se o player já tem uma categoria no banco de dados
	local currentCategory = player:getNenCategory()

	if not currentCategory then
		-- O Momento do Despertar!
		currentCategory = NenDivination.rollCategory()
		
		-- Salva no Banco de Dados para sempre
		player:setNenCategory(currentCategory)
		
		-- Bônus de Despertar (+1 Magic Level permanente para celebrar)
		-- (Isso seria feito via db.query nos skills do jogador em um servidor completo,
		-- por enquanto vamos focar no Lore).
		
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "AWAKENING: Your Aura flows into the water...")
	else
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You apply your Aura to the water again...")
	end

	-- Lê o Lore da Categoria (Sorteada ou já Existente)
	local lore = NenDivination.Lores[currentCategory]

	-- Solta o Efeito no Copo d'Água (toPosition) ou em cima do copo
	local cupPos = item:getPosition()
	cupPos:sendMagicEffect(lore.effect)

	-- Grita o Destino na Tela do Jogador
	player:say(lore.message, TALKTYPE_MONSTER_SAY)

	return true
end
