-- Skill Hunter / Bandit's Secret (Chrollo's Nen)
local STORAGE_SKILL_HUNTER = 80120

-- Vocation Mappings to Elements
local VOC_SORCERER = 1 -- Emissor (Energy)
local VOC_DRUID = 2    -- Transmutador (Ice)
local VOC_PALADIN = 3  -- Conjurador (Holy/Distance)
local VOC_KNIGHT = 4   -- Intensificador (Physical)

-- Combates
local combatEnergy = Combat()
combatEnergy:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combatEnergy:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
combatEnergy:setArea(createCombatArea(AREA_BEAM5))

local combatIce = Combat()
combatIce:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combatIce:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICEAREA)
combatIce:setArea(createCombatArea(AREA_CIRCLE3X3))

local combatHoly = Combat()
combatHoly:setParameter(COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
combatHoly:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HOLYDAMAGE)
combatHoly:setArea(createCombatArea(AREA_SQUARE1X1))

local combatPhysical = Combat()
combatPhysical:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combatPhysical:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
combatPhysical:setArea(createCombatArea(AREA_SQUARE1X1))

function onSay(player, words, param)
	local args = param:split(" ")
	local command = args[1]
	
	if not command then
		player:sendCancelMessage("Usage: !skillhunter steal <name> OR !skillhunter cast")
		return false
	end
	
	-- ATO 1: ROUBAR (STEAL)
	if command == "steal" then
		local targetName = args[2]
		if not targetName then
			player:sendCancelMessage("You must specify a target name to steal from.")
			return false
		end
		
		local target = Player(targetName)
		if not target then
			player:sendCancelMessage("Target not found or offline.")
			return false
		end
		
		if target:getId() == player:getId() then
			player:sendCancelMessage("You cannot steal from yourself.")
			return false
		end
		
		if player:getPosition():getDistance(target:getPosition()) > 5 then
			player:sendCancelMessage("Target is too far away to steal.")
			return false
		end
		
		-- Rouba a Vocação (Categoria de Nen)
		local targetVoc = target:getVocation():getId()
		player:setStorageValue(STORAGE_SKILL_HUNTER, targetVoc)
		
		player:say("Bandit's Secret!", TALKTYPE_MONSTER_SAY)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		target:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You stole the Nen ability of " .. target:getName() .. "!")
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "WARNING: " .. player:getName() .. " copied your Nen signature!")
		return false
	end
	
	-- ATO 2: DISPARAR O FEITIÇO ROUBADO (CAST)
	if command == "cast" then
		local stolenVoc = player:getStorageValue(STORAGE_SKILL_HUNTER)
		
		if stolenVoc <= 0 then
			player:sendCancelMessage("Your Bandit's Secret book is empty. Steal a skill first.")
			return false
		end
		
		local damageBase = (player:getLevel() * 3) + (player:getMagicLevel() * 10)
		local var = Variant(player:getPosition())
		local targetVar = nil
		
		local target = player:getTarget()
		if target then
			targetVar = Variant(target:getId())
		end
		
		-- Emissor (Energy Beam)
		if stolenVoc == VOC_SORCERER then
			player:say("Stolen Skill: Emitter Beam!", TALKTYPE_MONSTER_SAY)
			combatEnergy:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -damageBase * 2, 0, -damageBase * 3)
			combatEnergy:execute(player, var)
			
		-- Transmutador (Ice Explosion)
		elseif stolenVoc == VOC_DRUID then
			player:say("Stolen Skill: Transmuter Blizzard!", TALKTYPE_MONSTER_SAY)
			combatIce:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -damageBase * 1.5, 0, -damageBase * 2.5)
			combatIce:execute(player, var)
			
		-- Conjurador (Holy Target)
		elseif stolenVoc == VOC_PALADIN then
			if not targetVar then
				player:sendCancelMessage("You need a target to cast the Conjurer spell.")
				return false
			end
			player:say("Stolen Skill: Conjurer Spears!", TALKTYPE_MONSTER_SAY)
			combatHoly:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -damageBase * 3, 0, -damageBase * 4)
			combatHoly:execute(player, targetVar)
			
		-- Intensificador (Physical Punch)
		else
			if not targetVar then
				player:sendCancelMessage("You need a target to cast the Enhancer punch.")
				return false
			end
			player:say("Stolen Skill: Enhancer Impact!", TALKTYPE_MONSTER_SAY)
			combatPhysical:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -damageBase * 4, 0, -damageBase * 6)
			combatPhysical:execute(player, targetVar)
		end
		
		-- O Opcional da Restrição de Chrollo: A magia roubada não some da memória, ela pode ser spammada
		-- até ele roubar outra.
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		return false
	end

	return false
end
