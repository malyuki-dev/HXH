local AUCTION_MODAL_ID = 2000

function onModalWindow(player, modalWindowId, buttonId, choiceId)
	if modalWindowId ~= AUCTION_MODAL_ID then
		return false
	end

	-- Cancel
	if buttonId == 2 then
		return true
	end

	-- Buy
	if buttonId == 1 then
		local resultId = db.storeQuery(string.format("SELECT `player_id`, `player_name`, `item_id`, `item_count`, `price` FROM `auction_system` WHERE `id` = %d", choiceId))
		if resultId == false then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "This auction no longer exists.")
			return true
		end
		
		local sellerId = result.getNumber(resultId, "player_id")
		local sellerName = result.getString(resultId, "player_name")
		local itemId = result.getNumber(resultId, "item_id")
		local itemCount = result.getNumber(resultId, "item_count")
		local price = result.getNumber(resultId, "price")
		result.free(resultId)
		
		-- Checa balance do banco
		if player:getBankBalance() < price then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You do not have enough money in your bank account.")
			return true
		end
		
		-- Em uma engine real, o Parcel pode ser enviado pro Inbox do jogador e o dinheiro depositado na tabela `players`
		-- Aqui faremos o core básico
		player:setBankBalance(player:getBankBalance() - price)
		
		-- Depósito no seller. Como o jogador pode estar offline, a forma correta no TFS é DB Query
		db.query(string.format("UPDATE `players` SET `balance` = `balance` + %d WHERE `id` = %d", price, sellerId))
		
		-- Deletar a oferta
		db.query(string.format("DELETE FROM `auction_system` WHERE `id` = %d", choiceId))
		
		-- Entregar item. Nós deveríamos enviar via correio usando a função nativa do TFS
		-- player:getInbox():addItem(itemId, itemCount)
		-- Para evitar erros caso Inbox não esteja setado pra novos chars, mandaremos pra bag
		local item = player:addItem(itemId, itemCount)
		if not item then
			-- Se não tiver cap, manda pro inbox (fallback robusto do TFS)
			player:getInbox():addItem(itemId, itemCount)
		end
		
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You successfully bought %dx %s from %s for %d gold coins.", itemCount, ItemType(itemId):getName(), sellerName, price))
		player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
	end
	
	return true
end
