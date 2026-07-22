-- Dragon Dive (Zeno Zoldyck) - Chuva Assíncrona
-- Requer: data/lib/nen/damage_scaling.lua

-- Dano de Área Dinâmico do Dragão
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA) -- Efeito de impacto no chão

-- O impacto de UM único dragão caindo
function onDragonImpact(playerId, targetPos, finalDamage)
	local player = Player(playerId)
	if not player then return end

	-- Exibe a chuva (distância) caindo do "teto" (coordenada com Z menor ou y menor para simular queda)
	local fromPos = Position(targetPos.x - 3, targetPos.y - 3, targetPos.z)
	fromPos:sendDistanceEffect(targetPos, CONST_ANI_ENERGYBALL)

	-- Calcula a matemática
	local var = Variant(targetPos)
	combat:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -finalDamage, 0, -finalDamage)
	combat:execute(player, var)
end

function onSay(player, words, param)
	-- Zeno's Dragon Dive é custoso e mortal
	local basePower = 40 -- Cada pinga da chuva dói (O(1) Framework)
	local finalDamage = NenDamage.calculate(player, basePower)

	player:say("Dragon Dive!", TALKTYPE_MONSTER_SAY)
	
	local centerPos = player:getPosition()
	local radiusX = 8 -- Raio enorme na horizontal
	local radiusY = 6 -- Raio enorme na vertical
	
	-- Efeito cosmético de Aura do Conjurador
	centerPos:sendMagicEffect(CONST_ME_BIGCLOUDS)
	
	local drops = 60 -- Número de dragões na chuva
	local baseDelay = 50 -- 50ms (intervalo base de assincronicidade)

	-- O Loop de Fracionamento (Thread Segura)
	for i = 1, drops do
		-- Define um Tile aleatório dentro do raio do jogador
		local randX = centerPos.x + math.random(-radiusX, radiusX)
		local randY = centerPos.y + math.random(-radiusY, radiusY)
		local dropPos = Position(randX, randY, centerPos.z)

		-- Calcula o atraso para esse dragão cair (ex: 50ms, 150ms, 400ms...)
		-- Espalha 60 dragões ao longo de 3 segundos (3000ms) = 60 drops / 3000ms
		local delay = baseDelay * i + math.random(0, 100)
		
		-- O Motor C++ agenda a destruição perfeitamente no Background
		addEvent(onDragonImpact, delay, player:getId(), dropPos, finalDamage)
	end

	return false
end
