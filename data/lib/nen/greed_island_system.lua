-- Greed Island Database API
-- Manipulação de inserção e leitura das Cartas no Binder (Livro)

-- Adiciona uma carta no slot restrito (1-99) de forma assíncrona/segura
function Player.addGreedIslandCard(self, cardId)
	if cardId < 1 or cardId > 99 then
		self:sendCancelMessage("Invalid Restricted Card ID.")
		return false
	end

	-- Executa a Query com INSERT IGNORE para não crashar caso a constraint Unique Key barre a carta repetida
	db.query("INSERT IGNORE INTO `player_greed_island` (`player_id`, `card_id`) VALUES (" .. self:getGuid() .. ", " .. cardId .. ")")
	return true
end

-- Busca todas as cartas que o jogador tem e devolve num Array (Table)
function Player.getGreedIslandBinder(self)
	local cards = {}
	
	-- Consulta Síncrona que pega todas as cartas daquele GUID específico
	local resultId = db.storeQuery("SELECT `card_id` FROM `player_greed_island` WHERE `player_id` = " .. self:getGuid() .. " ORDER BY `card_id` ASC")
	
	if resultId ~= false then
		repeat
			local cId = result.getNumber(resultId, "card_id")
			table.insert(cards, cId)
		until not result.next(resultId)
		result.free(resultId)
	end
	
	return cards
end
