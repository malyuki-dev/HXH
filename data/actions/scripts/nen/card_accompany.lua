local ACCOMPANY_MODAL_ID = 3001

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local onlinePlayers = Game.getPlayers()
	
	if #onlinePlayers <= 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "There are no other players online to Accompany.")
		return true
	end
	
	-- Passamos o item.uid pelo próprio título ou armazenamos num storage local do player pra usar no modal, 
	-- mas para segurança, vamos registrar que o player tá tentando usar a carta com o ID do item.
	player:setStorageValue(80000, item.uid) -- Usado pelo CreatureScript pra checar/remover
	
	local window = ModalWindow(ACCOMPANY_MODAL_ID, "Spell Card: Accompany", "Select a player to fly to:")
	
	for _, targetPlayer in ipairs(onlinePlayers) do
		if targetPlayer:getId() ~= player:getId() then
			-- O id do choice será o GUID do player para ser mais seguro, ou apenas o CreatureID que muda por sessão. 
			-- CreatureID é seguro pra mesma sessão.
			window:addChoice(targetPlayer:getId(), targetPlayer:getName())
		end
	end
	
	window:addButton(1, "Accompany!")
	window:addButton(2, "Cancel")
	window:setDefaultEnterButton(1)
	window:setDefaultEscapeButton(2)
	window:sendToPlayer(player)
	
	return true
end
