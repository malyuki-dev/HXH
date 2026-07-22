-- Hunter System & Nen Database API
-- Metodos exportados para a classe Player interagindo diretamente com o MariaDB/MySQL

-- Nen Categories enum
NEN_CATEGORY_UNKNOWN = 0
NEN_CATEGORY_ENHANCER = 1
NEN_CATEGORY_TRANSMUTER = 2
NEN_CATEGORY_EMITTER = 3
NEN_CATEGORY_CONJURER = 4
NEN_CATEGORY_MANIPULATOR = 5
NEN_CATEGORY_SPECIALIST = 6

local NEN_NAMES = {
	[NEN_CATEGORY_ENHANCER] = "Enhancer",
	[NEN_CATEGORY_TRANSMUTER] = "Transmuter",
	[NEN_CATEGORY_EMITTER] = "Emitter",
	[NEN_CATEGORY_CONJURER] = "Conjurer",
	[NEN_CATEGORY_MANIPULATOR] = "Manipulator",
	[NEN_CATEGORY_SPECIALIST] = "Specialist"
}

function Player.getNenCategoryName(self)
	local category = self:getNenCategory()
	return NEN_NAMES[category] or "Unknown"
end

function Player.getHunterLicense(self)
	local resultId = db.storeQuery("SELECT `hunter_license_id` FROM `players` WHERE `id` = " .. self:getGuid())
	if resultId ~= false then
		local licenseId = result.getString(resultId, "hunter_license_id")
		result.free(resultId)
		return (licenseId ~= "") and licenseId or nil
	end
	return nil
end

function Player.setHunterLicense(self, licenseId)
	db.query("UPDATE `players` SET `hunter_license_id` = " .. db.escapeString(licenseId) .. " WHERE `id` = " .. self:getGuid())
end

function Player.getNenCategory(self)
	local resultId = db.storeQuery("SELECT `nen_category` FROM `players` WHERE `id` = " .. self:getGuid())
	if resultId ~= false then
		local category = result.getNumber(resultId, "nen_category")
		result.free(resultId)
		return category
	end
	return NEN_CATEGORY_UNKNOWN
end

function Player.setNenCategory(self, categoryId)
	db.query("UPDATE `players` SET `nen_category` = " .. categoryId .. " WHERE `id` = " .. self:getGuid())
end

function Player.getAuraCapacity(self)
	local resultId = db.storeQuery("SELECT `aura_capacity` FROM `players` WHERE `id` = " .. self:getGuid())
	if resultId ~= false then
		local cap = result.getNumber(resultId, "aura_capacity")
		result.free(resultId)
		return cap
	end
	return 100
end

function Player.setAuraCapacity(self, capacity)
	db.query("UPDATE `players` SET `aura_capacity` = " .. capacity .. " WHERE `id` = " .. self:getGuid())
end
