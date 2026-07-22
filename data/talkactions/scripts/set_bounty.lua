function onSay(player, words, param)
	local split = param:split(",")
	if #split ~= 2 then
		player:sendCancelMessage("Usage: !bounty PlayerName, Amount")
		return false
	end

	local targetName = split[1]:trim()
	local amount = tonumber(split[2]:trim())

	if not amount or amount <= 0 then
		player:sendCancelMessage("Invalid bounty amount.")
		return false
	end

	if targetName:lower() == player:getName():lower() then
		player:sendCancelMessage("You cannot place a bounty on yourself.")
		return false
	end

	-- Verifica se o player alvo existe no banco de dados
	local resultId = db.storeQuery(string.format("SELECT `id` FROM `players` WHERE `name` = %s", db.escapeString(targetName)))
	if resultId == false then
		player:sendCancelMessage("Player " .. targetName .. " does not exist.")
		return false
	end
	result.free(resultId)

	-- Retira o dinheiro do banco
	if player:getBankBalance() < amount then
		player:sendCancelMessage("You do not have enough money in your bank account.")
		return false
	end

	player:setBankBalance(player:getBankBalance() - amount)

	-- Insere a recompensa, se já existir soma ao valor atual
	local existId = db.storeQuery(string.format("SELECT `id`, `amount` FROM `bounty_system` WHERE `target_name` = %s", db.escapeString(targetName)))
	if existId ~= false then
		local currentAmount = result.getNumber(existId, "amount")
		local newAmount = currentAmount + amount
		local id = result.getNumber(existId, "id")
		db.query(string.format("UPDATE `bounty_system` SET `amount` = %d, `date` = %d WHERE `id` = %d", newAmount, os.time(), id))
		result.free(existId)
	else
		db.query(string.format("INSERT INTO `bounty_system` (`target_name`, `amount`, `setter_name`, `date`) VALUES (%s, %d, %s, %d)", 
			db.escapeString(targetName), amount, db.escapeString(player:getName()), os.time()))
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have placed a bounty of " .. amount .. " gold on " .. targetName .. "'s head.")
	player:getPosition():sendMagicEffect(CONST_ME_CRITICAL_DAMAGE)
	return false
end
