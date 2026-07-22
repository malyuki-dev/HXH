local function startFight(pid1, pid2)
	local p1 = Player(pid1)
	local p2 = Player(pid2)
	
	if not p1 or not p2 then
		HeavensArena.isArenaOccupied = false
		return
	end
	
	p1:sendTextMessage(MESSAGE_EVENT_ADVANCE, "FIGHT!")
	p2:sendTextMessage(MESSAGE_EVENT_ADVANCE, "FIGHT!")
	
	HeavensArena.centerPos:sendMagicEffect(CONST_ME_FIREAREA)
end

function onThink(interval)
	HeavensArena.cleanQueue()
	
	if HeavensArena.isArenaOccupied then
		return true
	end
	
	if #HeavensArena.Queue >= 2 then
		-- Puxa os dois primeiros
		local pid1 = HeavensArena.Queue[1]
		local pid2 = HeavensArena.Queue[2]
		
		local p1 = Player(pid1)
		local p2 = Player(pid2)
		
		if p1 and p2 then
			HeavensArena.isArenaOccupied = true
			table.remove(HeavensArena.Queue, 1)
			table.remove(HeavensArena.Queue, 1) -- Remove o segundo que agora virou o primeiro
			
			-- Teleporta
			p1:teleportTo(HeavensArena.posPlayer1)
			p2:teleportTo(HeavensArena.posPlayer2)
			
			p1:setStorageValue(HeavensArena.storageFighting, 1)
			p2:setStorageValue(HeavensArena.storageFighting, 1)
			
			p1:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Match found! Opponent: " .. p2:getName())
			p2:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Match found! Opponent: " .. p1:getName())
			
			Game.broadcastMessage("Heavens Arena: " .. p1:getName() .. " vs " .. p2:getName() .. " is starting!", MESSAGE_EVENT_ADVANCE)
			
			-- Delay pro inicio da luta (3 seg)
			addEvent(startFight, 3000, pid1, pid2)
		end
	end
	
	return true
end
