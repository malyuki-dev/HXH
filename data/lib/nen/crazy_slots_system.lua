-- Kite's Crazy Slots System
-- Weapon Roulette with Equip Lock

CrazySlots = {}
CrazySlots.Storage = 80162 -- Armazena o Número Tirado (1 a 3)

CrazySlots.Weapons = {
	[1] = 2376, -- Espada (Sword genérica)
	[2] = 2550, -- Foice (Scythe genérica)
	[3] = 2399  -- Throwing Star (Simulando uma arma de longo alcance)
}

function CrazySlots.rollWeapon(player)
	-- Se já tem maldição rodando, não pode girar de novo!
	if player:getStorageValue(CrazySlots.Storage) > 0 then
		player:sendCancelMessage("Bad roll! You cannot roll again until you make a kill.")
		return false
	end

	local randNumber = math.random(1, 3)
	local weaponItemId = CrazySlots.Weapons[randNumber]
	
	-- Remove a arma e o escudo atuais do jogador e joga no chão ou destrói
	-- Por questões de segurança, vamos tentar jogar pra mochila, se não der joga pro chão.
	local leftHand = player:getSlotItem(CONST_SLOT_LEFT)
	if leftHand then player:addItemEx(leftHand, true, CONST_SLOT_BACKPACK) end
	
	local rightHand = player:getSlotItem(CONST_SLOT_RIGHT)
	if rightHand then player:addItemEx(rightHand, true, CONST_SLOT_BACKPACK) end
	
	-- Cria a arma conjurada direto no Slot Esquerdo (Mão Primária)
	local conjuredWeapon = Game.createItem(weaponItemId, 1)
	if conjuredWeapon then
		local ret = player:addItemEx(conjuredWeapon, false, CONST_SLOT_LEFT)
		if ret ~= RETURNVALUE_NOERROR then
			-- Se falhou em equipar, destrói e aborta
			conjuredWeapon:remove()
			player:sendCancelMessage("Please free your hands first.")
			return false
		end
	end
	
	-- Trava a Maldição
	player:setStorageValue(CrazySlots.Storage, randNumber)
	
	-- Lore
	player:say("Number " .. randNumber .. "!", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Crazy Slots has conjured Weapon No. " .. randNumber .. ". You cannot remove it until you draw blood.")

	return true
end

function CrazySlots.releaseCurse(player)
	if player:getStorageValue(CrazySlots.Storage) <= 0 then
		return false
	end

	-- Limpa a Storage
	local currentWeaponNum = player:getStorageValue(CrazySlots.Storage)
	player:setStorageValue(CrazySlots.Storage, 0)
	
	-- Localiza a arma conjurada nas mãos do jogador e desintegra ela
	local weaponId = CrazySlots.Weapons[currentWeaponNum]
	
	local leftHand = player:getSlotItem(CONST_SLOT_LEFT)
	if leftHand and leftHand:getId() == weaponId then
		leftHand:remove()
	else
		local rightHand = player:getSlotItem(CONST_SLOT_RIGHT)
		if rightHand and rightHand:getId() == weaponId then
			rightHand:remove()
		end
	end
	
	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Blood drawn. The Crazy Slots curse has been lifted. You may roll again.")
	
	return true
end
