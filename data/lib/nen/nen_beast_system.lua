-- Guardian Nen Beast System
-- Kakin Succession War Parasitic Summoning

NenBeast = {}
NenBeast.DrainAmount = 50 -- Quanto de Mana/Aura drena por ciclo
NenBeast.DrainInterval = 2000 -- Tempo em ms (2 segundos)

-- O Evento Recursivo que roda invisível na memória
function NenBeast.drainAura(playerId, beastId)
	local player = Player(playerId)
	local beast = Monster(beastId)

	-- Se o player deslogou ou a besta morreu em combate, cancela o loop imediatamente
	if not player or not beast then
		return false
	end

	-- Aplica o dreno parasita
	if player:getMana() >= NenBeast.DrainAmount then
		player:addMana(-NenBeast.DrainAmount)
		
		-- Feedbacks Visuais do Dreno (O monstro se alimentando)
		beast:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		
		-- O loop chama a si mesmo para o próximo ciclo
		addEvent(NenBeast.drainAura, NenBeast.DrainInterval, playerId, beastId)
	else
		-- Exaustão Total: A Aura do jogador acabou
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "Your Aura is depleted. The Guardian Nen Beast fades away.")
		beast:getPosition():sendMagicEffect(CONST_ME_POFF)
		beast:remove() -- Engine deleta o monstro da memória
		-- O loop não se chama novamente, morrendo aqui.
	end
end
