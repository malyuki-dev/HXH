-- Phantom Troupe Database API
-- Manipulação de inserção, leitura e substituição dos Membros da Aranha

PhantomTroupe = {}

-- Busca qual é o número da tatuagem do jogador atual (0 a 12). Retorna nil se não for membro.
function Player.getSpiderNumber(self)
	local resultId = db.storeQuery("SELECT `spider_number` FROM `phantom_troupe` WHERE `player_id` = " .. self:getGuid())
	if resultId ~= false then
		local num = result.getNumber(resultId, "spider_number")
		result.free(resultId)
		return num
	end
	return nil
end

-- Associa um jogador a uma Perna da Aranha. Usa REPLACE INTO para sobrescrever se necessário.
function Player.setSpiderNumber(self, num)
	if num < 0 or num > 12 then return false end
	
	-- Remove o membro antigo daquela perna (se existir) para garantir a consistência
	PhantomTroupe.removeMember(num)

	-- Insere o novo
	db.query("INSERT INTO `phantom_troupe` (`spider_number`, `player_id`) VALUES (" .. num .. ", " .. self:getGuid() .. ")")
	return true
end

-- Deleta a tatuagem de um jogador específico (usado quando ele é morto e perde a facção)
function Player.removeSpiderTattoo(self)
	db.query("DELETE FROM `phantom_troupe` WHERE `player_id` = " .. self:getGuid())
end

-- Utilitário: Deleta um membro baseado no número da perna (0 a 12)
function PhantomTroupe.removeMember(num)
	db.query("DELETE FROM `phantom_troupe` WHERE `spider_number` = " .. num)
end
