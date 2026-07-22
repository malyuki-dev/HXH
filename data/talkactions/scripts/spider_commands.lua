function onSay(player, words, param)
	local action = param:lower():trim()
	
	if words == "!spider" and action == "join" then
		local success, msg = SpiderSystem.joinSpider(player)
		if success then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, msg)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			player:say("I am the Spider.", TALKTYPE_MONSTER_SAY)
		else
			player:sendCancelMessage(msg)
		end
	elseif words == "!spiders" then
		local res = db.storeQuery("SELECT `player_id`, `spider_number` FROM `spiders` ORDER BY `spider_number` ASC")
		if res ~= false then
			local str = "The Phantom Troupe Members:\n\n"
			repeat
				local pid = result.getNumber(res, "player_id")
				local snum = result.getNumber(res, "spider_number")
				
				local pName = "Unknown"
				local res2 = db.storeQuery(string.format("SELECT `name` FROM `players` WHERE `id` = %d", pid))
				if res2 ~= false then
					pName = result.getString(res2, "name")
					result.free(res2)
				end
				
				str = str .. "Spider #" .. snum .. " - " .. pName .. "\n"
			until not result.next(res)
			result.free(res)
			
			player:showTextDialog(1968, str) -- Mostra num livro/pergaminho
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "The Phantom Troupe is currently empty.")
		end
	else
		player:sendCancelMessage("Usage: !spider join | !spiders")
	end
	
	return false
end
