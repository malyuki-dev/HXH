local STORAGE_HAS_VOTED = 20004
local ELECTION_MODAL_ID = 1000

local candidates = {
	[1] = "Pariston Hill",
	[2] = "Cheadle Yorkshire",
	[3] = "Leorio Paradinight"
}

function onModalWindow(player, modalWindowId, buttonId, choiceId)
	if modalWindowId ~= ELECTION_MODAL_ID then
		return false
	end
	
	-- Se clicar em Cancel (2) ou Apertar ESC (2)
	if buttonId == 2 then
		return true
	end
	
	-- Se clicar em Vote (1)
	if buttonId == 1 then
		local candidateName = candidates[choiceId]
		if not candidateName then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Invalid candidate.")
			return true
		end
		
		-- Em um ambiente de produção real, nós faríamos um db.query para persistir o voto na tabela `election_votes`
		-- Exemplo: db.query(string.format("INSERT INTO `election_votes` (`player_id`, `candidate`) VALUES (%d, %d)", player:getGuid(), choiceId))
		
		player:setStorageValue(STORAGE_HAS_VOTED, choiceId)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your vote for " .. candidateName .. " has been successfully cast. Thank you for participating in the 13th Hunter Chairman Election.")
		player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
	end
	
	return true
end
