-- Phantom Troupe User Commands
-- Requer: data/lib/nen/phantom_troupe.lua

function onSay(player, words, param)
	-- Comando do Jogador (!spider)
	if words == "!spider" then
		local num = player:getSpiderNumber()
		
		if not num then
			player:sendCancelMessage("You are not a member of the Phantom Troupe.")
			return false
		end

		local msg = "==== PHANTOM TROUPE ====\n"
		if num == 0 then
			msg = msg .. "Position: The Head of the Spider\n"
		else
			msg = msg .. "Position: Spider Leg #" .. num .. "\n"
		end
		msg = msg .. "Status: Active\n"
		msg = msg .. "========================"
		
		player:showTextDialog(2000, msg)
		player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
		return false
	end

	-- Comando do Administrador (!makespider) para distribuir a tatuagem inicial
	if words == "!makespider" then
		if not player:getGroup():getAccess() then
			return false
		end
		
		local splitParam = string.split(param, " ")
		if #splitParam < 2 then
			player:sendCancelMessage("Usage: !makespider <player_name> <0-12>")
			return false
		end

		local targetStr = splitParam[1]
		local num = tonumber(splitParam[2])

		if num < 0 or num > 12 then
			player:sendCancelMessage("Spider number must be between 0 (Head) and 12.")
			return false
		end

		local targetPlayer = Player(targetStr)
		if not targetPlayer then
			player:sendCancelMessage("Player not found.")
			return false
		end

		targetPlayer:setSpiderNumber(num)
		targetPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have been marked as Spider #" .. num .. ".")
		targetPlayer:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
		
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, targetPlayer:getName() .. " is now Spider #" .. num .. ".")
		return false
	end

	return false
end
