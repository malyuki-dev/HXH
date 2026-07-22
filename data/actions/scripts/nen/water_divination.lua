local STORAGE_NEN_TYPE = 20003

local nenTypes = {
	[1] = {name = "Enhancer (Reforço)", effectMsg = "The water volume increases and overflows!", magicEffect = CONST_ME_MAGIC_BLUE, weight = 30},
	[2] = {name = "Transmuter (Transformação)", effectMsg = "The water tastes sweet...", magicEffect = CONST_ME_HEARTS, weight = 20},
	[3] = {name = "Emitter (Emissão)", effectMsg = "The color of the water changes!", magicEffect = CONST_ME_MAGIC_RED, weight = 20},
	[4] = {name = "Manipulator (Manipulação)", effectMsg = "The leaf moves on the surface of the water!", magicEffect = CONST_ME_LOSEENERGY, weight = 15},
	[5] = {name = "Conjurer (Materialização)", effectMsg = "Impurities appear inside the water!", magicEffect = CONST_ME_POISONAREA, weight = 10},
	[6] = {name = "Specialist (Especialização)", effectMsg = "The leaf withers and dies...", magicEffect = CONST_ME_MORTAREA, weight = 5}
}

local function getRandomNenType()
	local totalWeight = 0
	for _, typeData in ipairs(nenTypes) do
		totalWeight = totalWeight + typeData.weight
	end

	local rand = math.random(1, totalWeight)
	local currentWeight = 0

	for id, typeData in ipairs(nenTypes) do
		currentWeight = currentWeight + typeData.weight
		if rand <= currentWeight then
			return id
		end
	end
	return 1 -- Default fallback
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local currentNen = player:getStorageValue(STORAGE_NEN_TYPE)
	
	if currentNen > 0 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You have already discovered your Nen affinity: " .. nenTypes[currentNen].name)
		return true
	end

	-- Executa a adivinhação
	local nenId = getRandomNenType()
	local nenData = nenTypes[nenId]
	
	player:setStorageValue(STORAGE_NEN_TYPE, nenId)
	
	-- Efeitos visuais e mensagens canônicas
	player:getPosition():sendMagicEffect(nenData.magicEffect)
	player:say(nenData.effectMsg, TALKTYPE_MONSTER_SAY)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Congratulations! You discovered your Nen Affinity: " .. nenData.name)
	
	return true
end
