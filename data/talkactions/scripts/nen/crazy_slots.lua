-- Crazy Slots (Kite's Nen Ability) - Conjuration
local STORAGE_CRAZY_SLOTS = 80110

-- ID das Armas Físicas a serem equipadas temporariamente (Mockadas)
local WEAPON_SCYTHE = 3318  -- ID de uma foice
local WEAPON_MACE = 2436    -- ID de uma clava
local WEAPON_CARBINE = 2456 -- ID de um arco/arma de fogo

local weapons = {
	[2] = {id = WEAPON_SCYTHE, name = "Scythe (Silent Waltz)"},
	[3] = {id = WEAPON_MACE, name = "Mace"},
	[4] = {id = WEAPON_CARBINE, name = "Carbine"}
}

function onSay(player, words, param)
	-- Verifica Restrição: Não pode roletar novamente se já tiver uma arma
	if player:getStorageValue(STORAGE_CRAZY_SLOTS) > 0 then
		player:sendCancelMessage("Bad roll! You cannot dismiss a Crazy Slot weapon without using it.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	-- Sorteia a Arma (No anime, números 1 a 9, mas Kite só mostrou algumas. Vamos simular 2, 3 e 4)
	local roll = math.random(2, 4)
	local weaponData = weapons[roll]

	-- Bloqueia o uso na memória (Storage Vow)
	player:setStorageValue(STORAGE_CRAZY_SLOTS, roll)

	-- Cria a arma física e equipa na mão esquerda (Equipamento Temporário)
	local currentWeapon = player:getSlotItem(CONST_SLOT_LEFT)
	if currentWeapon then
		-- Desequipa a arma atual do jogador jogando pra mochila
		player:addItem(currentWeapon:getId(), 1)
		currentWeapon:remove(1)
	end

	player:addItem(weaponData.id, 1, false, 1, CONST_SLOT_LEFT)

	-- Efeitos Visuais
	player:say("Crazy Slots: Number " .. roll .. "!", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You conjured a " .. weaponData.name .. ". You must cast it to release the slot.")

	return false
end
