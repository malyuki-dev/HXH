-- Invocação da Besta Guardiã de Nen
-- Requer: data/lib/nen/nen_beast_system.lua

function onSay(player, words, param)
	-- Verifica se o jogador tem Mana suficiente para o Custo Inicial de Invocação
	if player:getMana() < 500 then
		player:sendCancelMessage("You need at least 500 Aura to manifest your Guardian Spirit Beast.")
		return false
	end

	-- Verifica se o jogador já possui Summons nativos ativos
	if #player:getSummons() > 0 then
		player:sendCancelMessage("You can only manifest one Guardian Spirit Beast at a time.")
		return false
	end

	-- Consome o custo inicial
	player:addMana(-500)
	
	-- Invoca o monstro na engine C++. Estamos usando um "Demon" genérico como Placeholder 
	-- até colocarmos as Sprites Oficiais do Client HxH.
	local beastName = "Demon" 
	
	local beast = Game.createMonster(beastName, player:getPosition(), true, false)
	
	if not beast then
		player:sendCancelMessage("There is not enough room to manifest your Beast.")
		return false
	end

	-- Atrela o monstro ao jogador (Master)
	beast:setMaster(player)
	
	player:say("NEN BEAST MANIFESTATION!", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your Guardian Spirit Beast has awakened. It will drain " .. NenBeast.DrainAmount .. " Aura every " .. (NenBeast.DrainInterval/1000) .. " seconds.")

	-- Dispara o Fogo Parasita: Inicia o Loop Assíncrono que não trava a Engine
	addEvent(NenBeast.drainAura, NenBeast.DrainInterval, player:getId(), beast:getId())

	return false
end
