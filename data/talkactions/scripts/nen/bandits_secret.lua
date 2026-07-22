-- O Livro Aberto (Roubar Magia)
-- Requer: data/lib/nen/bandits_secret_system.lua

function onSay(player, words, param)
	if not param or param == "" then
		player:sendCancelMessage("Usage: !steal \"TargetName\"")
		return false
	end

	local target = Player(param)
	if not target then
		player:sendCancelMessage("Target player not found or offline.")
		return false
	end

	if target:getId() == player:getId() then
		player:sendCancelMessage("You cannot steal from yourself.")
		return false
	end

	-- Verifica distância para o roubo (O Livro exige ver o alvo de perto)
	if player:getPosition():getDistance(target:getPosition()) > 5 then
		player:sendCancelMessage("Target is too far away to steal.")
		return false
	end

	-- Lê a Categoria de Nen do Banco de Dados / Memória do Alvo
	local targetCategory = target:getStorageValue(NenDivination.Storage)
	
	if targetCategory <= 0 then
		player:sendCancelMessage("This player has not awakened their Nen yet. Nothing to steal.")
		return false
	end

	-- Anota a categoria no Livro
	player:setStorageValue(BanditsSecret.Storage, targetCategory)
	
	player:say("Bandit's Secret!", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	target:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	
	local categoryName = NenDivination.Categories[targetCategory] or "Unknown"
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have successfully stolen an " .. categoryName .. " ability from " .. target:getName() .. "!")

	return false
end
