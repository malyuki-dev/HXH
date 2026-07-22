local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)

function onCastSpell(creature, variant)
	local target = creature:getTarget()
	if not target then
		creature:sendCancelMessage("You need a target.")
		return false
	end

	local playerPos = creature:getPosition()
	local targetPos = target:getPosition()
	
	if playerPos:getDistance(targetPos) > 7 then
		creature:sendCancelMessage("Target is too far.")
		return false
	end

	creature:say("Bungee Gum...", TALKTYPE_MONSTER_SAY)
	
	-- Puxa o alvo para perto (ao lado do caster)
	local newPos = {x = playerPos.x + 1, y = playerPos.y, z = playerPos.z}
	if target:teleportTo(newPos, true) then
		targetPos:sendMagicEffect(CONST_ME_POFF)
		newPos:sendMagicEffect(CONST_ME_MAGIC_RED)
		combat:execute(creature, variant)
	end
	
	return true
end
