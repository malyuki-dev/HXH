-- Aldebaran Global Bounty System
BountySys = {}

function BountySys.setupTable()
	-- Cria a tabela caso não exista
	local query = [[
		CREATE TABLE IF NOT EXISTS `bounty_system` (
			`id` INTEGER PRIMARY KEY AUTOINCREMENT,
			`target_name` VARCHAR(255) NOT NULL,
			`amount` INTEGER NOT NULL,
			`setter_name` VARCHAR(255) NOT NULL,
			`date` INTEGER NOT NULL
		);
	]]
	db.query(query)
end

-- Inicializa na subida do servidor
BountySys.setupTable()
