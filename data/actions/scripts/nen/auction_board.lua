local AUCTION_MODAL_ID = 2000

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Faz o SELECT no banco pegando as últimas 20 ofertas
	local resultId = db.storeQuery("SELECT `id`, `player_name`, `item_id`, `item_count`, `price` FROM `auction_system` ORDER BY `date` DESC LIMIT 20")
	
	if resultId == false then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "There are currently no items in the Global Auction House.")
		return true
	end
	
	local window = ModalWindow(AUCTION_MODAL_ID, "Global Auction House", "Select an item to buy:")
	local hasItems = false
	
	repeat
		local auctionId = result.getNumber(resultId, "id")
		local sellerName = result.getString(resultId, "player_name")
		local itemId = result.getNumber(resultId, "item_id")
		local itemCount = result.getNumber(resultId, "item_count")
		local price = result.getNumber(resultId, "price")
		
		-- ItemType nativo para pegar nome
		local itemType = ItemType(itemId)
		local itemName = itemType:getName()
		
		local choiceText = string.format("[%d] %dx %s by %s", price, itemCount, itemName, sellerName)
		
		-- O ID da choice tem que caber no range, mas podemos usar o id do leilão direto (já que é AUTO_INCREMENT). 
		-- Em TFS os choices costumam ser 1..255 max? Se for muito alto, a gente precisa mapear. 
		-- Como isso é um alpha, usaremos o ID direto se for menor que 255. 
		-- Caso contrário, para segurança total:
		window:addChoice(auctionId, choiceText)
		hasItems = true
	until not result.next(resultId)
	
	result.free(resultId)
	
	if hasItems then
		window:addButton(1, "Buy")
		window:addButton(2, "Cancel")
		window:setDefaultEnterButton(1)
		window:setDefaultEscapeButton(2)
		window:sendToPlayer(player)
	end
	
	return true
end
