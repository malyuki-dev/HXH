-- Crazy Slots - Disparo da Magia (Cast)
local STORAGE_CRAZY_SLOTS = 80110

-- Combate da Foice (Área Massiva)
local combatScythe = Combat()
combatScythe:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combatScythe:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
combatScythe:setArea(createCombatArea(AREA_CIRCLE3X3))

-- Combate da Carabina (Tiro em Linha Reta)
local combatCarbine = Combat()
combatCarbine:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combatCarbine:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
combatCarbine:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGYBALL)
combatCarbine:setArea(createCombatArea(AREA_BEAM5))

-- Combate da Clava (Hit Target Forte)
local combatMace = Combat()
combatMace:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combatMace:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_STONES)

function onSay(player, words, param)
	local activeSlot = player:getStorageValue(STORAGE_CRAZY_SLOTS)
	
	if activeSlot <= 0 then
		player:sendCancelMessage("You have not conjured a Crazy Slot weapon.")
		return false
	end

	local var = Variant(player:getPosition())
	local damageBase = (player:getLevel() * 3) + (player:getMagicLevel() * 10)

	if activeSlot == 2 then
		-- SCYTHE: Silent Waltz
		player:say("Silent Waltz!", TALKTYPE_MONSTER_SAY)
		combatScythe:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -damageBase * 2, 0, -damageBase * 3)
		combatScythe:execute(player, var)
	elseif activeSlot == 3 then
		-- MACE: Esmagamento Frontal
		player:say("Mace Smash!", TALKTYPE_MONSTER_SAY)
		local target = player:getTarget()
		if target then
			local targetVar = Variant(target:getId())
			combatMace:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -damageBase * 1.5, 0, -damageBase * 2.5)
			combatMace:execute(player, targetVar)
		else
			player:sendCancelMessage("You need a target for the Mace.")
			return false
		end
	elseif activeSlot == 4 then
		-- CARBINE: Disparo em Linha
		player:say("Carbine Blast!", TALKTYPE_MONSTER_SAY)
		combatCarbine:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -damageBase * 2, 0, -damageBase * 4)
		combatCarbine:execute(player, var)
	end

	-- APAGA A ARMA DA MEMÓRIA (Liberando a Restrição)
	player:setStorageValue(STORAGE_CRAZY_SLOTS, 0)
	
	-- Remove fisicamente a arma da mão esquerda
	local currentWeapon = player:getSlotItem(CONST_SLOT_LEFT)
	if currentWeapon then
		currentWeapon:remove(1)
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Crazy Slot released.")
	return false
end
