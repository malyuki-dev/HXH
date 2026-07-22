-- En (Nen Radar & Anti-Stealth)
-- Fase 3.1 

function onSay(player, words, param)
	-- Raio do radar (praticamente cobre a visão inteira da tela e além)
	local radius = 12 
	local centerPos = player:getPosition()
	
	player:say("En!", TALKTYPE_MONSTER_SAY)

	-- Efeito central para mostrar que o En foi expandido
	centerPos:sendMagicEffect(CONST_ME_MAGIC_RED)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You expand your Aura...")

	-- Busca nativa C++ ultra rápida de todos os seres vivos em volta
	local spectators = Game.getSpectators(centerPos, false, false, radius, radius, radius, radius)
	local lifeForms = 0

	for _, spectator in ipairs(spectators) do
		-- Ignora a si mesmo
		if spectator:getId() ~= player:getId() then
			local specPos = spectator:getPosition()
			
			-- Se a criatura estiver invisível (Stealth), QUEBRA a invisibilidade na hora
			if spectator:getCondition(CONDITION_INVISIBLE) then
				spectator:removeCondition(CONDITION_INVISIBLE)
				-- Envia um efeito de fumaça/surpresa avisando que ele foi revelado
				specPos:sendMagicEffect(CONST_ME_POFF)
			end
			
			-- Coloca um pilar de luz/marca em cada forma de vida detectada no mapa
			specPos:sendMagicEffect(CONST_ME_TUTORIALARROW)
			lifeForms = lifeForms + 1
		end
	end

	if lifeForms > 0 then
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "En detected " .. lifeForms .. " life form(s) nearby.")
	else
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "En detected absolutely nothing.")
	end

	-- Dreno fixo de mana por espalhar o En de forma agressiva
	player:addMana(-100)

	return false
end
