-- Cartas Mágicas de Greed Island
local ITEM_STEAL = 2019
local ITEM_MAGNETIC_FORCE = 2020

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	
	-- CARTA STEAL (Roubo de Backpack)
	if item:getId() == ITEM_STEAL then
		if not target or not target:isPlayer() then
			player:sendCancelMessage("You must use the Steal card on another player.")
			return false
		end
		
		if target:getId() == player:getId() then
			player:sendCancelMessage("You cannot steal from yourself.")
			return false
		end
		
		local targetPos = target:getPosition()
		if player:getPosition():getDistance(targetPos) > 3 then
			player:sendCancelMessage("You are too far away from your target to steal.")
			return false
		end
		
		-- Vasculha o inventário (backpack) do alvo
		local backpack = target:getSlotItem(CONST_SLOT_BACKPACK)
		if not backpack or backpack:getSize() == 0 then
			player:sendCancelMessage("The target's backpack is empty.")
			return false
		end
		
		-- Sorteia um item aleatório para roubar
		local items = {}
		for i = 0, backpack:getSize() - 1 do
			local slotItem = backpack:getItem(i)
			if slotItem then
				table.insert(items, slotItem)
			end
		end
		
		if #items == 0 then
			player:sendCancelMessage("The target's backpack has no storable items.")
			return false
		end
		
		local randomIndex = math.random(1, #items)
		local stolenItem = items[randomIndex]
		
		-- Transfere o item para o ladrão
		local itemClone = player:addItem(stolenItem:getId(), stolenItem:getCount())
		if itemClone then
			stolenItem:remove()
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You used the STEAL card and stole " .. itemClone:getName() .. " from " .. target:getName() .. "!")
			target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "WARNING: " .. player:getName() .. " used a STEAL card on you and took your " .. itemClone:getName() .. "!")
			
			-- Destrói a carta
			item:remove(1)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			target:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		else
			player:sendCancelMessage("You don't have enough space in your inventory to steal this item.")
			return false
		end
	end
	
	-- CARTA MAGNETIC FORCE (Teleporte Seguro de Guild)
	-- Para fins da action, o target aqui será a própria carta, usaremos a mecânica de fugir aleatoriamente pelo mapa 
	-- como "Magnetic Force", atirando o jogador para uma cidade aleatória
	if item:getId() == ITEM_MAGNETIC_FORCE then
		-- Posições das Cidades (Mockadas)
		local cities = {
			Position(1000, 1000, 7),
			Position(1200, 1500, 7),
			Position(800, 900, 7)
		}
		
		local randomCity = cities[math.random(1, #cities)]
		
		player:teleportTo(randomCity)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "MAGNETIC FORCE! You were teleported to a random location.")
		randomCity:sendMagicEffect(CONST_ME_TELEPORT)
		
		item:remove(1)
		return true
	end

	return false
end
