-- Heavens Arena Matchmaking System

HeavensArena = {
	Queue = {},
	isArenaOccupied = false,
	storageFighting = 91000, -- Status individual de luta
	
	-- Posições da Arena
	posPlayer1 = Position(1100, 1100, 7),
	posPlayer2 = Position(1104, 1100, 7),
	centerPos = Position(1102, 1100, 7),
	exitPos = Position(1000, 1000, 7) -- Lobby
}

function HeavensArena.setupTable()
	local query = [[
		CREATE TABLE IF NOT EXISTS `arena_points` (
			`player_id` INTEGER PRIMARY KEY,
			`points` INTEGER NOT NULL DEFAULT 0,
			`wins` INTEGER NOT NULL DEFAULT 0,
			`losses` INTEGER NOT NULL DEFAULT 0
		);
	]]
	db.query(query)
end

function HeavensArena.joinQueue(player)
	if HeavensArena.isInQueue(player) then
		return false
	end
	table.insert(HeavensArena.Queue, player:getId())
	return true
end

function HeavensArena.leaveQueue(player)
	for i, pid in ipairs(HeavensArena.Queue) do
		if pid == player:getId() then
			table.remove(HeavensArena.Queue, i)
			return true
		end
	end
	return false
end

function HeavensArena.isInQueue(player)
	for _, pid in ipairs(HeavensArena.Queue) do
		if pid == player:getId() then
			return true
		end
	end
	return false
end

function HeavensArena.cleanQueue()
	-- Remove jogadores deslogados da fila
	for i = #HeavensArena.Queue, 1, -1 do
		if not Player(HeavensArena.Queue[i]) then
			table.remove(HeavensArena.Queue, i)
		end
	end
end

HeavensArena.setupTable()
