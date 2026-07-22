-- Bodhisattva Hands (Netero's Attacks)
-- Requer: data/lib/nen/damage_scaling.lua

local STORAGE_BODHISATTVA = 80160

-- Single Target (First Hand)
local combatFirstHand = Combat()
combatFirstHand:setParameter(COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
combatFirstHand:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HOLYDAMAGE)

-- Area Burst (Third Hand - Clap)
local combatThirdHand = Combat()
combatThirdHand:setParameter(COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
combatThirdHand:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_GIANTICE)
combatThirdHand:setArea(createCombatArea(AREA_CIRCLE3X3))

-- Massive Area Chaos (99th Hand)
local combat99 = Combat()
combat99:setParameter(COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
combat99:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_YELLOW_RINGS)
combat99:setArea(createCombatArea(AREA_CIRCLE5X5))

function onSay(player, words, param)
	-- Validação da Postura. Nenhuma Mão pode ser usada sem o transe do Bodhisattva.
	if player:getStorageValue(STORAGE_BODHISATTVA) <= 0 then
		player:sendCancelMessage("You must be in the Bodhisattva stance (!bodhisattva on) to use this technique.")
		return false
	end

	-- !firsthand
	if words == "!firsthand" then
		local target = player:getTarget()
		if not target then
			player:sendCancelMessage("You need a target for the First Hand.")
			return false
		end

		local basePower = 30
		local finalDamage = NenDamage.calculate(player, basePower)

		player:say("First Hand!", TALKTYPE_MONSTER_SAY)
		combatFirstHand:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -finalDamage, 0, -(finalDamage * 1.5))
		
		local var = Variant(target:getId())
		combatFirstHand:execute(player, var)
		return false
	end

	-- !thirdhand
	if words == "!thirdhand" then
		local basePower = 50
		local finalDamage = NenDamage.calculate(player, basePower)

		player:say("Third Hand...", TALKTYPE_MONSTER_SAY)
		combatThirdHand:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -finalDamage, 0, -finalDamage)
		
		local var = Variant(player:getPosition())
		combatThirdHand:execute(player, var)
		return false
	end

	-- !ninetyninthhand
	if words == "!ninetyninthhand" then
		local basePower = 150 -- Poder extremo O(1)
		local finalDamage = NenDamage.calculate(player, basePower)

		player:say("Ninety-Ninth Hand!", TALKTYPE_MONSTER_SAY)
		combat99:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -finalDamage, 0, -finalDamage)
		
		local var = Variant(player:getPosition())
		combat99:execute(player, var)
		
		-- Drena 90% da Mana pelo uso massivo
		player:addMana(-(player:getMaxMana() * 0.9))
		return false
	end

	return false
end
