-- Bungee Pull (Contrair Goma elástica)
-- Requer: data/lib/nen/bungee_gum_system.lua

function onSay(player, words, param)
	if player:getMana() < 50 then
		player:sendCancelMessage("You need 50 Aura to pull the Bungee Gum.")
		return false
	end

	-- Executa a Física Bruta do Puxão (Vetores)
	if BungeeGum.pull(player) then
		player:addMana(-50)
	end

	return false
end
