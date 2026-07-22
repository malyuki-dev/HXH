-- O Gatilho de Libertação (Kill Event)
-- Libera o jogador da maldição da Arma quando ele mata um alvo.
-- Requer: data/lib/nen/crazy_slots_system.lua

function onKill(creature, target)
	if not creature:isPlayer() then return true end

	local player = creature
	
	-- Verifica se o player tem a maldição do Crazy Slots ativa
	if player:getStorageValue(CrazySlots.Storage) > 0 then
		-- O Voto foi cumprido (Sangue foi derramado)
		-- Retira a arma da mão e limpa a Storage
		CrazySlots.releaseCurse(player)
	end

	return true
end
