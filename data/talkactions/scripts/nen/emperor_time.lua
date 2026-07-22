-- Emperor Time (Ativação e Desativação)
-- Requer: data/lib/nen/emperor_time_system.lua

function onSay(player, words, param)
	local action = string.lower(param)

	if action == "on" then
		if not EmperorTime.start(player) then
			player:sendCancelMessage("You are already in Emperor Time.")
		end
		return false
	elseif action == "off" then
		if not EmperorTime.stop(player, false) then
			player:sendCancelMessage("You are not using Emperor Time.")
		end
		return false
	else
		player:sendCancelMessage("Usage: !emperortime on | !emperortime off")
		return false
	end
end
