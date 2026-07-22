local LICENSE_MODAL_ID = 4001
local STORAGE_SELLOUT = 83000

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Se o jogador já vendeu a licença antes (e achou uma no chão/comprou)
	if player:getStorageValue(STORAGE_SELLOUT) == 1 then
		player:sendCancelMessage("You have pawned your honor. This license does not recognize you.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end
	
	local window = ModalWindow(LICENSE_MODAL_ID, "Hunter License", "Select a License Network option:")
	
	window:addChoice(1, "Access Hunter HQ (Teleport)")
	window:addChoice(2, "Pawn License (Sell for 100M Zennis)")
	
	window:addButton(1, "Select")
	window:addButton(2, "Cancel")
	window:setDefaultEnterButton(1)
	window:setDefaultEscapeButton(2)
	window:sendToPlayer(player)
	
	return true
end
