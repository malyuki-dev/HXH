local conditionBuff = Condition(CONDITION_ATTRIBUTES)
conditionBuff:setParameter(CONDITION_PARAM_TICKS, 30000) -- 30 seconds
conditionBuff:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 20)
conditionBuff:setParameter(CONDITION_PARAM_SKILL_MELEE, 20)

local conditionDegen = Condition(CONDITION_FIRE) -- Usaremos fire como degen
conditionDegen:setParameter(CONDITION_PARAM_DELAYED, 1)
conditionDegen:addDamage(30, 1000, -50) -- 30 ticks de 1 segundo, dano 50

local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)
combat:addCondition(conditionBuff)
combat:addCondition(conditionDegen)

function onCastSpell(creature, variant)
	creature:say("Emperor Time!", TALKTYPE_MONSTER_SAY)
	return combat:execute(creature, variant)
end
