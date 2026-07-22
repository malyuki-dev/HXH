-- Nen Damage Scaling Framework
-- Fase 6.1 (Matemática O(1))

NenDamage = {}

-- Fatores de Escalonamento Globais
local LEVEL_MULTIPLIER = 1.5
local AURA_MULTIPLIER = 0.5
local MAGIC_LEVEL_MULTIPLIER = 2.0

--[[
	Calcula o dano final baseado em uma complexidade estrutural O(1).
	@param player: Objeto Player
	@param basePower: O multiplicador estático do quão forte é a magia (Ex: 10, 50, 100)
	@return dano final (int)
]]
function NenDamage.calculate(player, basePower)
	if not player then return 0 end

	local level = player:getLevel()
	local magicLevel = player:getMagicLevel()
	local auraCapacity = player:getAuraCapacity() -- Puxa do DB / hunter_system.lua

	-- Formula Core: ( (Level * M1) + (Magic Level * M2) + (Aura * M3) ) * Poder da Skill
	local rawPower = (level * LEVEL_MULTIPLIER) + (magicLevel * MAGIC_LEVEL_MULTIPLIER) + (auraCapacity * AURA_MULTIPLIER)
	
	local finalDamage = math.floor(rawPower * (basePower / 10))

	-- Garante que o mínimo de dano seja sempre 1
	if finalDamage < 1 then
		finalDamage = 1
	end

	return finalDamage
end
