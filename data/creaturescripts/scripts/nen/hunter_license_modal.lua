local LICENSE_MODAL_ID = 4001
local STORAGE_SELLOUT = 83000
local HUNTER_HQ_POS = Position(1300, 1300, 7) -- Coordenadas da Sede Secreta

function onModalWindow(player, modalWindowId, buttonId, choiceId)
	if modalWindowId ~= LICENSE_MODAL_ID then
		return false
	end

	-- Cancel button
	if buttonId == 2 or buttonId == 255 then
		return true
	end

	if buttonId == 1 then
		if choiceId == 1 then
			-- Acesso VIP
			player:teleportTo(HUNTER_HQ_POS)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Welcome to the Hunter Association Headquarters.")
			
		elseif choiceId == 2 then
			-- Vender a Alma (Pawn License)
			
			-- Procura a Licença na mochila
			local item = player:getItemById(2026, true)
			if item then
				-- Remove 1 Licença
				item:remove(1)
				
				-- Seta a marca do desonrado
				player:setStorageValue(STORAGE_SELLOUT, 1)
				
				-- Adiciona 100 Milhões na conta bancária do TFS
				player:setBankBalance(player:getBankBalance() + 100000000)
				
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You pawned your Hunter License for 100,000,000 Zennis. You will never be able to access the Hunter Network again.")
				player:getPosition():sendMagicEffect(CONST_ME_COIN_YELLOW)
			else
				player:sendCancelMessage("You do not have the Hunter License with you.")
			end
		end
		return true
	end

	return false
end
