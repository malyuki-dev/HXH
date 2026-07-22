local STORAGE_DEVOUR_HP = 84000
local STORAGE_DEVOUR_MP = 84001
local STORAGE_DEVOUR_SPEED = 84002

function onLogin(player)
	-- Lê todo o DNA devorado que está salvo no Banco de Dados (Storages)
	local extraHP = player:getStorageValue(STORAGE_DEVOUR_HP)
	local extraMP = player:getStorageValue(STORAGE_DEVOUR_MP)
	local extraSpeed = player:getStorageValue(STORAGE_DEVOUR_SPEED)
	
	-- Injeta a mutação direto na memória do motor (C++) para garantir persistência
	if extraHP > 0 then
		player:setMaxHealth(player:getMaxHealth() + extraHP)
		-- Só cura se não for logar morto, pro tibia não dar crash
		if player:getHealth() > 0 then
			player:addHealth(extraHP)
		end
	end
	
	if extraMP > 0 then
		player:setMaxMana(player:getMaxMana() + extraMP)
		player:addMana(extraMP)
	end
	
	if extraSpeed > 0 then
		player:changeSpeed(extraSpeed)
	end
	
	-- Aviso de login
	if extraHP > 0 or extraMP > 0 or extraSpeed > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your Chimera Ant mutations have been restored based on the DNA you consumed.")
	end

	return true
end
