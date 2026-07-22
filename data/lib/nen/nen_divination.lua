-- Nen Awakening (Water Divination System)
-- The 6 Categories of Nen

NenDivination = {}

-- Enum das categorias
NEN_CATEGORY_ENHANCER = 1
NEN_CATEGORY_EMITTER = 2
NEN_CATEGORY_TRANSMUTER = 3
NEN_CATEGORY_CONJURER = 4
NEN_CATEGORY_MANIPULATOR = 5
NEN_CATEGORY_SPECIALIST = 6

NenDivination.Lores = {
	[NEN_CATEGORY_ENHANCER] = {
		name = "Enhancer (Reforço)",
		message = "The volume of the water increases and overflows! You are an ENHANCER.",
		effect = CONST_ME_LOSEENERGY -- Efeito de respingo
	},
	[NEN_CATEGORY_EMITTER] = {
		name = "Emitter (Emissão)",
		message = "The color of the water changes abruptly! You are an EMITTER.",
		effect = CONST_ME_MAGIC_RED
	},
	[NEN_CATEGORY_TRANSMUTER] = {
		name = "Transmuter (Transformação)",
		message = "The taste of the water becomes sweet! You are a TRANSMUTER.",
		effect = CONST_ME_STUN
	},
	[NEN_CATEGORY_CONJURER] = {
		name = "Conjurer (Materialização)",
		message = "Impurities and crystals form inside the water! You are a CONJURER.",
		effect = CONST_ME_ICEAREA
	},
	[NEN_CATEGORY_MANIPULATOR] = {
		name = "Manipulator (Manipulação)",
		message = "The leaf floats and moves in circles! You are a MANIPULATOR.",
		effect = CONST_ME_POFF
	},
	[NEN_CATEGORY_SPECIALIST] = {
		name = "Specialist (Especialização)",
		message = "The leaf wilts and turns to ash! You are a SPECIALIST.",
		effect = CONST_ME_FIREAREA
	}
}

function Player.getNenCategory(self)
	local resultId = db.storeQuery("SELECT `nen_category` FROM `players` WHERE `id` = " .. self:getGuid())
	if resultId ~= false then
		local cat = result.getNumber(resultId, "nen_category")
		result.free(resultId)
		if cat > 0 then return cat end
	end
	return nil
end

function Player.setNenCategory(self, categoryId)
	if categoryId < 1 or categoryId > 6 then return false end
	db.query("UPDATE `players` SET `nen_category` = " .. categoryId .. " WHERE `id` = " .. self:getGuid())
	return true
end

-- Roda a Roleta de Matemática
function NenDivination.rollCategory()
	local rand = math.random(1, 100)
	
	-- Probabilidades (Soma 100)
	-- Enhancer: 25%
	-- Emitter: 20%
	-- Transmuter: 20%
	-- Conjurer: 15%
	-- Manipulator: 15%
	-- Specialist: 5%
	
	if rand <= 25 then return NEN_CATEGORY_ENHANCER
	elseif rand <= 45 then return NEN_CATEGORY_EMITTER
	elseif rand <= 65 then return NEN_CATEGORY_TRANSMUTER
	elseif rand <= 80 then return NEN_CATEGORY_CONJURER
	elseif rand <= 95 then return NEN_CATEGORY_MANIPULATOR
	else return NEN_CATEGORY_SPECIALIST
	end
end
