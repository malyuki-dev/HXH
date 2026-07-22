-- Black Whale physical gate validation
-- Requer: data/lib/nen/black_whale_system.lua

function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then return true end
	
	local player = creature
	local requiredTier = 5 -- Default

	-- Lendo o Action ID do Piso do Navio (Configurado no Map Editor)
	if item.actionid == 5001 then requiredTier = 1 end
	if item.actionid == 5002 then requiredTier = 2 end
	if item.actionid == 5003 then requiredTier = 3 end
	if item.actionid == 5004 then requiredTier = 4 end
	if item.actionid == 5005 then requiredTier = 5 end

	local playerTier = player:getWhaleTier()

	-- Validação: Se o número do Tier do jogador for MAIOR que o requerido, ele falha.
	-- Ex: Ele tem Tier 5 (Pobre). Tenta entrar no 1 (Realeza). 5 não é <= 1.
	if playerTier <= requiredTier then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Access Granted: Welcome to Tier " .. requiredTier .. " of the Black Whale.")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		return true
	else
		-- Fisicamente jogado pra trás
		player:teleportTo(fromPosition, true)
		
		-- Efeito de segurança pesada
		player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
		player:sendTextMessage(MESSAGE_STATUS_WARNING, "Access Denied! You do not have the clearance for Tier " .. requiredTier .. ". Your current Tier is " .. playerTier .. ".")
		return false
	end
end
