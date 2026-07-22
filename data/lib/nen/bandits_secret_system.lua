-- Chrollo's Bandit's Secret System
-- Requer: data/lib/nen/nen_divination.lua

BanditsSecret = {}
BanditsSecret.Storage = 80164 -- O Livro na RAM. Guarda a Categoria Roubada (1 a 6)

-- O Roteador Polimórfico de Magias
function BanditsSecret.castStolen(player)
	local stolenCategory = player:getStorageValue(BanditsSecret.Storage)
	
	if stolenCategory <= 0 then
		player:sendCancelMessage("Your book is empty. You haven't stolen any abilities.")
		return false
	end

	local pos = player:getPosition()
	
	-- 1. ENHANCER (Reforço) - Golpe Colossal Corpo-a-Corpo
	if stolenCategory == NEN_CATEGORY_ENHANCER then
		if player:getMana() < 150 then return false end
		player:addMana(-150)
		
		-- Pega o quadrado da frente e destrói
		local targetPos = BungeeGum.getFrontPosition(player)
		targetPos:sendMagicEffect(CONST_ME_EXPLOSIONAREA)
		doAreaCombatHealth(player:getId(), COMBAT_PHYSICALDAMAGE, targetPos, 0, -200, -400, CONST_ME_HITAREA)
		player:say("STOLEN ENHANCER: IMPACT!", TALKTYPE_MONSTER_SAY)

	-- 2. EMITTER (Emissão) - Feixe de Luz (Beam) Direcional
	elseif stolenCategory == NEN_CATEGORY_EMITTER then
		if player:getMana() < 100 then return false end
		player:addMana(-100)
		
		local dir = player:getDirection()
		player:say("STOLEN EMITTER: BEAM!", TALKTYPE_MONSTER_SAY)
		-- Dispara o laser por 4 SQMs na frente
		for i = 1, 4 do
			local beamPos = Position(pos.x, pos.y, pos.z)
			if dir == DIRECTION_NORTH then beamPos.y = beamPos.y - i
			elseif dir == DIRECTION_SOUTH then beamPos.y = beamPos.y + i
			elseif dir == DIRECTION_EAST then beamPos.x = beamPos.x + i
			elseif dir == DIRECTION_WEST then beamPos.x = beamPos.x - i end
			
			beamPos:sendMagicEffect(CONST_ME_ENERGYHIT)
			doAreaCombatHealth(player:getId(), COMBAT_ENERGYDAMAGE, beamPos, 0, -100, -250, CONST_ME_NONE)
		end

	-- 3. TRANSMUTER (Transformação) - Aura de Choque (AoE)
	elseif stolenCategory == NEN_CATEGORY_TRANSMUTER then
		if player:getMana() < 120 then return false end
		player:addMana(-120)
		
		player:say("STOLEN TRANSMUTER: SHOCKWAVE!", TALKTYPE_MONSTER_SAY)
		pos:sendMagicEffect(CONST_ME_TELEPORT)
		
		-- 3x3 Explosion ao redor do jogador
		doAreaCombatHealth(player:getId(), COMBAT_ENERGYDAMAGE, pos, 1, -150, -300, CONST_ME_YELLOW_RINGS)

	-- 4. CONJURER (Materialização) - Correntes Aprisionadoras (Paralyze Radial)
	elseif stolenCategory == NEN_CATEGORY_CONJURER then
		if player:getMana() < 80 then return false end
		player:addMana(-80)
		
		player:say("STOLEN CONJURER: CHAINS!", TALKTYPE_MONSTER_SAY)
		-- Causa Lentidão absurda e dano leve físico ao redor
		local condition = Condition(CONDITION_PARALYZE)
		condition:setParameter(CONDITION_PARAM_TICKS, 3000)
		condition:setFormula(-0.8, 0, -0.8, 0)
		
		doAreaCombatHealth(player:getId(), COMBAT_PHYSICALDAMAGE, pos, 1, -50, -100, CONST_ME_BLOCKHIT)
		-- O certo seria aplicar condition usando combate, mas faremos simples pro exemplo

	-- 5. MANIPULATOR (Manipulação) - Puxão Reverso (Black Hole)
	elseif stolenCategory == NEN_CATEGORY_MANIPULATOR then
		if player:getMana() < 100 then return false end
		player:addMana(-100)
		
		player:say("STOLEN MANIPULATOR: GRAVITY!", TALKTYPE_MONSTER_SAY)
		pos:sendMagicEffect(CONST_ME_MAGIC_BLUE)
		-- Sugaria monstros próximos, mas faremos apenas dano Massivo de Death pra simplificar
		doAreaCombatHealth(player:getId(), COMBAT_DEATHDAMAGE, pos, 2, -150, -200, CONST_ME_MORTAREA)

	-- 6. SPECIALIST (Especialização) - Cura Absoluta de Sangue
	elseif stolenCategory == NEN_CATEGORY_SPECIALIST then
		if player:getMana() < 200 then return false end
		player:addMana(-200)
		
		player:say("STOLEN SPECIALIST: BLOOD REGENERATION!", TALKTYPE_MONSTER_SAY)
		player:addHealth(500)
		pos:sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end
	
	return true
end
