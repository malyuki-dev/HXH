function onSay(player, words, param)
	local price = tonumber(param)
	if not price or price <= 0 then
		player:sendCancelMessage("Usage: !sellitem <price>")
		return false
	end

	-- Pegamos o item na mão direita (slot 5) ou esquerda (slot 6)
	local item = player:getSlotItem(CONST_SLOT_RIGHT)
	if not item then
		item = player:getSlotItem(CONST_SLOT_LEFT)
	end

	if not item then
		player:sendCancelMessage("You must hold the item you want to sell in your hands.")
		return false
	end

	-- Impede venda de itens não-removíveis
	if not item:getType():isMovable() then
		player:sendCancelMessage("You cannot sell this item.")
		return false
	end

	local itemId = item:getId()
	local itemCount = item:getCount()
	local guid = player:getGuid()
	local name = player:getName()

	-- Insere na tabela
	db.query(string.format("INSERT INTO `auction_system` (`player_id`, `player_name`, `item_id`, `item_count`, `price`, `date`) VALUES (%d, %s, %d, %d, %d, %d)", 
		guid, db.escapeString(name), itemId, itemCount, price, os.time()))

	-- Remove o item do jogo
	item:remove()

	player:sendTextMessage(MESSAGE_INFO_DESCR, "Your item has been successfully listed in the Global Auction House for " .. price .. " gold coins.")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	return false
end
