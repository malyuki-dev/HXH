-- Pain Packer Tracker (Feitan's Vow)
local STORAGE_PAIN_PACKER = 80150

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature:isPlayer() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	-- Verifica se a criatura tomou dano na vida real (dano letal que diminui o HP)
	local totalDamage = (primaryDamage or 0) + (secondaryDamage or 0)
	
	if totalDamage > 0 then
		local currentPain = creature:getStorageValue(STORAGE_PAIN_PACKER)
		if currentPain < 0 then
			currentPain = 0
		end
		
		-- Soma a dor
		creature:setStorageValue(STORAGE_PAIN_PACKER, currentPain + totalDamage)
	end
	
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end
