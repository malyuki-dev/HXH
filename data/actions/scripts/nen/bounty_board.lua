local BOUNTY_MODAL_ID = 3000

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Faz o SELECT no banco pegando o Top 10 Bounties
	local resultId = db.storeQuery("SELECT `target_name`, `amount`, `setter_name` FROM `bounty_system` ORDER BY `amount` DESC LIMIT 10")
	
	if resultId == false then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "The Blacklist is currently empty. No active bounties.")
		return true
	end
	
	local window = ModalWindow(BOUNTY_MODAL_ID, "Top 10 Blacklist Hunters", "Current Active Bounties:")
	
	local count = 1
	repeat
		local targetName = result.getString(resultId, "target_name")
		local amount = result.getNumber(resultId, "amount")
		
		local choiceText = string.format("%d. %s - Reward: %d Gold", count, targetName, amount)
		
		window:addChoice(count, choiceText)
		count = count + 1
	until not result.next(resultId)
	
	result.free(resultId)
	
	-- No botão de fechar
	window:addButton(1, "Close")
	window:setDefaultEnterButton(1)
	window:setDefaultEscapeButton(1)
	window:sendToPlayer(player)
	
	return true
end
