-- Bungee Gum (Grudar Goma)
-- Requer: data/lib/nen/bungee_gum_system.lua

function onSay(player, words, param)
	if not param or param == "" then
		player:sendCancelMessage("Usage: !bungeegum \"TargetName\"")
		return false
	end

	if player:getMana() < 100 then
		player:sendCancelMessage("You need 100 Aura to attach Bungee Gum.")
		return false
	end

	local target = Creature(param)
	if not target then
		player:sendCancelMessage("Target not found.")
		return false
	end

	-- Impede de usar em si mesmo
	if target:getId() == player:getId() then
		player:sendCancelMessage("You cannot attach Bungee Gum to yourself.")
		return false
	end

	-- Verifica a distância
	if player:getPosition():getDistance(target:getPosition()) > BungeeGum.MaxDistance then
		player:sendCancelMessage("Target is too far away.")
		return false
	end

	-- Gruda a Goma!
	if BungeeGum.attach(player, target) then
		player:addMana(-100)
	end

	return false
end
