-- Godspeed Toggle (Kanmuru)
-- Requer: data/lib/nen/godspeed_system.lua

function onSay(player, words, param)
	local isGodspeedOn = player:getStorageValue(Godspeed.Storage) > 0

	-- Toggle Logic
	if param == "on" then
		Godspeed.turnOn(player)
	elseif param == "off" then
		if isGodspeedOn then
			Godspeed.turnOff(player)
		else
			player:sendCancelMessage("Godspeed is already off.")
		end
	else
		player:sendCancelMessage("Usage: !godspeed on | !godspeed off")
	end

	return false
end
