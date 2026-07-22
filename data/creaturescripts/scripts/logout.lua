function onLogout(player)
	-- Remove Emperor Time if active
	local STORAGE_EMPEROR_TIME = 85000
	if player:getStorageValue(STORAGE_EMPEROR_TIME) > 0 then
		player:setStorageValue(STORAGE_EMPEROR_TIME, 0)
	end

	local nextUseStaminaTime = player:getStorageValue(Storage.Stamina)
	if nextUseStaminaTime ~= -1 then
		player:setStorageValue(Storage.Stamina, nextUseStaminaTime + 10)
	end

	return true
end
