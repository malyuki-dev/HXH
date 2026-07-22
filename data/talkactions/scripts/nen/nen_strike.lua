-- Nen Strike (Ataque Básico com Engine Matemática Customizada)
-- Requer data/lib/nen/damage_scaling.lua

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)

function onSay(player, words, param)
	local targetName = param
	local target = nil

	if targetName and targetName ~= "" then
		target = Player(targetName) or Monster(targetName)
	else
		target = player:getTarget()
	end

	if not target then
		player:sendCancelMessage("You need a target to cast Nen Strike.")
		return false
	end

	if player:getPosition():getDistance(target:getPosition()) > 5 then
		player:sendCancelMessage("Target is too far.")
		return false
	end

	-- Aplica a Engine de Cálculo O(1) criada na Fase 6.1
	local basePower = 15 -- Uma habilidade fraca/média
	local finalDamage = NenDamage.calculate(player, basePower)

	player:say("Nen Strike!", TALKTYPE_MONSTER_SAY)
	
	local var = Variant(target:getId())
	
	-- Forçamos o dano customizado matemático dentro do Combat object nativo
	combat:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -finalDamage, 0, -finalDamage)
	combat:execute(player, var)

	return false
end
