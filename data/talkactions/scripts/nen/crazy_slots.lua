-- Kite's Crazy Slots Conjuration
-- Requer: data/lib/nen/crazy_slots_system.lua

function onSay(player, words, param)
	-- Custo de Aura
	if player:getMana() < 200 then
		player:sendCancelMessage("You need at least 200 Aura to roll the Crazy Slots.")
		return false
	end

	-- Tenta rodar a arma, se tiver sucesso gasta a mana
	if CrazySlots.rollWeapon(player) then
		player:addMana(-200)
	end

	return false
end
