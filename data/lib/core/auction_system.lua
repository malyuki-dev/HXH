-- Aldebaran Global Auction System
AuctionSys = {}

function AuctionSys.setupTable()
	-- Cria a tabela caso não exista
	-- Adaptável para SQLite e MySQL (INT e INTEGER auto_increment)
	local query = [[
		CREATE TABLE IF NOT EXISTS `auction_system` (
			`id` INTEGER PRIMARY KEY AUTOINCREMENT,
			`player_id` INTEGER NOT NULL,
			`player_name` VARCHAR(255) NOT NULL,
			`item_id` INTEGER NOT NULL,
			`item_count` INTEGER NOT NULL DEFAULT 1,
			`price` INTEGER NOT NULL,
			`date` INTEGER NOT NULL
		);
	]]
	-- Em TFS moderno, db.query pode ser usado para tabelas, 
	-- mas para engine MySQL o ideal seria AUTO_INCREMENT. 
	-- Assumiremos compatibilidade SQLite para o dev ambiente:
	db.query(query)
end

-- Inicializa na subida do servidor
AuctionSys.setupTable()
