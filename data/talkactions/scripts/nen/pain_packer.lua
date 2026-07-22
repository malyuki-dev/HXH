-- Pain Packer (Rising Sun) - Feitan
local STORAGE_PAIN_PACKER = 80150

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

function onSay(player, words, param)
	local storedDamage = player:getStorageValue(STORAGE_PAIN_PACKER)
	
	if storedDamage <= 0 then
		player:sendCancelMessage("You haven't stored enough pain to cast Rising Sun.")
		return false
	end

	-- Fórmula Base + (Dor Acumulada * Multiplicador Massivo)
	local baseDamage = (player:getLevel() * 2) + (player:getMagicLevel() * 5)
	local sunDamage = baseDamage + (storedDamage * 1.5)

	-- Limite máximo para não crashar o server (Cap 50k por exemplo)
	if sunDamage > 50000 then
		sunDamage = 50000
	end

	player:say("Pain Packer... RISING SUN!", TALKTYPE_MONSTER_SAY)
	
	local var = Variant(player:getPosition())
	
	-- Configura o dano customizado do Combat no momento do cast
	combat:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -sunDamage, 0, -sunDamage)
	combat:execute(player, var)

	player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You released " .. math.floor(sunDamage) .. " fire damage based on your accumulated pain!")

	-- Zera a dor
	player:setStorageValue(STORAGE_PAIN_PACKER, 0)
	
	return false
end
