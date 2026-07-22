function onSay(player, words, param)
	local action = param:lower():trim()
	
	if action == "join" then
		if player:getStorageValue(HeavensArena.storageFighting) == 1 then
			player:sendCancelMessage("You are already fighting!")
			return false
		end
		
		if HeavensArena.joinQueue(player) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have joined the Heavens Arena queue! Please wait for an opponent.")
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		else
			player:sendCancelMessage("You are already in the queue.")
		end
	elseif action == "leave" then
		if HeavensArena.leaveQueue(player) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have left the Heavens Arena queue.")
		else
			player:sendCancelMessage("You are not in the queue.")
		end
	else
		player:sendCancelMessage("Usage: !arena join | !arena leave")
	end
	
	return false
end
