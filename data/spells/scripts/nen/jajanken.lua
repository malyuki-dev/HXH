local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setParameter(COMBAT_PARAM_BLOCKSHIELD, true)

function onGetFormulaValues(player, level, maglevel)
	local min = (level / 5) + (maglevel * 4) + 50
	local max = (level / 5) + (maglevel * 8) + 100
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(creature, variant)
	-- Delay para simular "First comes rock..."
	creature:say("First comes rock...", TALKTYPE_MONSTER_SAY)
	
	addEvent(function(cid, var)
		local player = Player(cid)
		if not player then return end
		
		player:say("Rock! Paper! Rock!!", TALKTYPE_MONSTER_SAY)
		combat:execute(player, var)
	end, 1500, creature:getId(), variant)
	
	return true
end
