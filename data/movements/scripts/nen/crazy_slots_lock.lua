-- O Bloqueio Absoluto de Inventário (Crazy Slots)
-- Requer: data/lib/nen/crazy_slots_system.lua

function onDeEquipItem(player, item, slot, isCheck)
	-- Verifica se a maldição está ativada no jogador
	local curseActive = player:getStorageValue(CrazySlots.Storage)
	
	if curseActive > 0 then
		-- Verifica se o item que ele está tentando desequipar é a arma maldita dele
		local cursedWeaponId = CrazySlots.Weapons[curseActive]
		
		if item:getId() == cursedWeaponId then
			if not isCheck then
				player:sendTextMessage(MESSAGE_STATUS_WARNING, "Bad roll! You cannot unequip the Crazy Slots weapon until you make a kill.")
				player:getPosition():sendMagicEffect(CONST_ME_POISONAREA)
			end
			-- O retorno "false" em MoveEvents impede fisicamente que o item saia do Slot
			return false
		end
	end

	return true
end
