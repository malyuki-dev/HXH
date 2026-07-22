-- Hunter License & Exam System
-- Requer data/lib/nen/hunter_system.lua para manipular o banco de dados

function onSay(player, words, param)
	-- O Exame Hunter (!takeexam)
	if words == "!takeexam" then
		if player:getLevel() < 50 then
			player:sendCancelMessage("You must be at least level 50 to take the Hunter Exam.")
			return false
		end

		if player:getHunterLicense() then
			player:sendCancelMessage("You already passed the Hunter Exam and have a license.")
			return false
		end

		-- Gera um ID no formato HXH-ABCD-1234
		local charset1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		local charset2 = "0123456789"
		
		local function randomString(length, charset)
			local str = ""
			for i = 1, length do
				local rand = math.random(1, #charset)
				str = str .. string.sub(charset, rand, rand)
			end
			return str
		end
		
		local newLicenseId = "HXH-" .. randomString(4, charset1) .. "-" .. randomString(4, charset2)
		
		-- Sorteia a Categoria de Nen nativa (Exclui Especialista que é raro)
		local randomCategory = math.random(1, 5)

		-- Salva Oficialmente no Banco de Dados (Persistência Real)
		player:setHunterLicense(newLicenseId)
		player:setNenCategory(randomCategory)

		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Congratulations! You passed the Hunter Exam.")
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your official Hunter License ID is: " .. newLicenseId)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Water Divination Test reveals your Nen Category is: " .. player:getNenCategoryName())
		
		player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
		player:say("I am a Hunter!", TALKTYPE_MONSTER_SAY)
		return false
	end

	-- A Identidade Oficial (!license)
	if words == "!license" then
		local licenseId = player:getHunterLicense()
		
		if not licenseId then
			player:sendCancelMessage("You are not a licensed Hunter.")
			return false
		end

		local nenName = player:getNenCategoryName()
		local auraCap = player:getAuraCapacity()

		local msg = "==== PRO HUNTER LICENSE ====\n"
		msg = msg .. "Name: " .. player:getName() .. "\n"
		msg = msg .. "License ID: " .. licenseId .. "\n"
		msg = msg .. "Nen Category: " .. nenName .. "\n"
		msg = msg .. "Aura Capacity: " .. auraCap .. " AAP\n"
		msg = msg .. "============================="

		-- Exibe o Popup Textual para o jogador
		player:showTextDialog(2000, msg) -- O itemID 2000 é um scroll generico
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		return false
	end

	return false
end
