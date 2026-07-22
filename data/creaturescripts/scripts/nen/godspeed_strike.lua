-- Godspeed Melee Tracker (C++ HealthChange Hook)
-- Requer: data/lib/nen/godspeed_system.lua

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not attacker or not attacker:isPlayer() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end
	
	-- Verifica se o atacante está no Transe do Godspeed
	if attacker:getStorageValue(Godspeed.Storage) > 0 then
		-- Só aplica o choque se for um golpe Melee (Dano Físico)
		if primaryType == COMBAT_PHYSICALDAMAGE then
			-- Adiciona 20% de dano bônus elétrico
			local bonusShock = math.floor(primaryDamage * 0.2)
			
			-- Eletrocuta a vítima visualmente
			creature:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
			
			-- Aplica o Micro-Stun (1 segundo de paralisia)
			creature:addCondition(Godspeed.StunCondition)
			
			-- Retorna o dano físico normal + o dano elétrico bônus secundário
			return primaryDamage, primaryType, secondaryDamage - bonusShock, COMBAT_ENERGYDAMAGE
		end
	end

	return primaryDamage, primaryType, secondaryDamage, secondaryType
end
