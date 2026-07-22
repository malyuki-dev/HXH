function onSay(player, words, param)
	-- Verifica limite de summons
	if #player:getSummons() >= 1 then
		player:sendCancelMessage("You can only conjure one Nen Beast at a time.")
		return false
	end
	
	-- Custos de mana (Aura)
	local manaCost = 500
	if player:getMana() < manaCost then
		player:sendCancelMessage("You do not have enough aura to conjure a Nen Beast.")
		return false
	end
	
	player:addMana(-manaCost)
	
	-- Cria o Monstro Base
	local beast = Game.createMonster("Nen Beast", player:getPosition())
	if not beast then
		player:sendCancelMessage("Failed to conjure Nen Beast. Not enough space.")
		return false
	end
	
	-- Seta como servo absoluto do jogador
	beast:setMaster(player)
	
	-- O Pulo do Gato (Dynamic Scaling)
	-- Matemática: HP Max = Nível do Jogador * 50 + Magic Level * 100
	local pLevel = player:getLevel()
	local pMagicLevel = player:getMagicLevel()
	
	local maxHealth = (pLevel * 50) + (pMagicLevel * 100)
	-- Mínimo de 1000 pra não bugar caso o cara seja level 1 sem magic level
	if maxHealth < 1000 then maxHealth = 1000 end 
	
	-- Injeta a fórmula na engine C++ da criatura invocada
	beast:setMaxHealth(maxHealth)
	beast:setHealth(maxHealth)
	
	-- Aumenta a velocidade baseando-se no magic level do jogador (magos mais fortes = feras mais rápidas)
	local extraSpeed = pMagicLevel * 2
	beast:changeSpeed(extraSpeed)
	
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	player:say("Nen Beast, materialise!", TALKTYPE_MONSTER_SAY)
	
	return false
end
