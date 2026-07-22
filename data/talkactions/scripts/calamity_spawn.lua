function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	local pos = Position(1200, 1200, 7) -- Swamp Zone coordinates
	local monster = Game.createMonster("Brion", pos)
	
	if monster then
		Game.broadcastMessage("A Calamity from the Dark Continent has breached our world! BRION, the Botanical Weapon, has appeared in the Swamps! Hunters, assemble!", MESSAGE_EVENT_ADVANCE)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Brion spawned successfully.")
	else
		player:sendCancelMessage("Failed to spawn Brion. Check XML and position.")
	end
	
	return false
end
