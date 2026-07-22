-- Black Whale VIP System
-- API para manipular o Tier (Andar) do Navio no Banco de Dados

function Player.getWhaleTier(self)
	local resultId = db.storeQuery("SELECT `tier` FROM `player_black_whale_ticket` WHERE `player_id` = " .. self:getGuid())
	if resultId ~= false then
		local tier = result.getNumber(resultId, "tier")
		result.free(resultId)
		return tier
	end
	
	-- Se não tem registro, ele é a escória (Tier 5) por padrão.
	return 5
end

function Player.setWhaleTier(self, tier)
	if tier < 1 or tier > 5 then return false end
	
	-- Usa REPLACE INTO (MySQL) ou equivalente para atualizar a Primary Key se ela já existir.
	db.query("REPLACE INTO `player_black_whale_ticket` (`player_id`, `tier`) VALUES (" .. self:getGuid() .. ", " .. tier .. ")")
	return true
end
