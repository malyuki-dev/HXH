local STORAGE_EXAM_STATUS = 20002
local STORAGE_HAS_VOTED = 20004
local ELECTION_MODAL_ID = 1000

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Checa se passou no Exame Hunter
	if player:getStorageValue(STORAGE_EXAM_STATUS) < 1 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Only licensed Hunters can participate in the Election.")
		return true
	end

	-- Checa se já votou
	if player:getStorageValue(STORAGE_HAS_VOTED) > 0 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have already cast your vote.")
		return true
	end

	-- Cria a Janela Modal
	local window = ModalWindow(ELECTION_MODAL_ID, "13th Hunter Chairman Election", "Select your candidate:")
	
	-- Adiciona as escolhas (ID, Nome)
	window:addChoice(1, "Pariston Hill")
	window:addChoice(2, "Cheadle Yorkshire")
	window:addChoice(3, "Leorio Paradinight")

	-- Adiciona os botões
	window:addButton(1, "Vote")
	window:addButton(2, "Cancel")
	window:setDefaultEnterButton(1)
	window:setDefaultEscapeButton(2)

	-- Envia para o cliente
	window:sendToPlayer(player)
	
	return true
end
