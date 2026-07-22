local STORAGE_DEVOUR_HP = 84000
local STORAGE_DEVOUR_MP = 84001
local STORAGE_DEVOUR_SPEED = 84002

function onSay(player, words, param)
	local pos = player:getPosition()
	local tile = Tile(pos)
	if not tile then return false end
	
	local corpseItem = nil
	local items = tile:getItems()
	if items then
		for _, item in ipairs(items) do
			local itType = ItemType(item:getId())
			if itType and itType:isCorpse() then
				corpseItem = item
				break
			end
		end
	end
	
	if not corpseItem then
		player:sendCancelMessage("There is no corpse here to devour.")
		return false
	end
	
	-- Destrói o cadáver
	corpseItem:remove(1)
	
	-- Rolagem matemática da mutação (Fagocênese)
	local r = math.random(1, 100)
	local mutationMsg = ""
	
	if r <= 50 then
		-- Mutação de HP (+10)
		local cur = player:getStorageValue(STORAGE_DEVOUR_HP)
		local newVal = (cur > 0 and cur or 0) + 10
		player:setStorageValue(STORAGE_DEVOUR_HP, newVal)
		player:setMaxHealth(player:getMaxHealth() + 10)
		player:addHealth(10)
		mutationMsg = "You devoured the corpse and assimilated its vitality! (+10 Max Health)"
		
	elseif r <= 85 then
		-- Mutação de Mana (+5)
		local cur = player:getStorageValue(STORAGE_DEVOUR_MP)
		local newVal = (cur > 0 and cur or 0) + 5
		player:setStorageValue(STORAGE_DEVOUR_MP, newVal)
		player:setMaxMana(player:getMaxMana() + 5)
		player:addMana(5)
		mutationMsg = "You devoured the corpse and assimilated its aura! (+5 Max Aura)"
		
	else
		-- Mutação rara de Speed (+2)
		local cur = player:getStorageValue(STORAGE_DEVOUR_SPEED)
		local newVal = (cur > 0 and cur or 0) + 2
		player:setStorageValue(STORAGE_DEVOUR_SPEED, newVal)
		player:changeSpeed(2)
		mutationMsg = "You devoured the corpse and mutated your leg muscles! (+2 Speed)"
	end
	
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, mutationMsg)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:say("Phagogenesis!", TALKTYPE_MONSTER_SAY)
	
	return false
end
