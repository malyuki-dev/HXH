#include "territory.h"
#include "databasemanager.h"
#include "scheduler.h"
#include "game.h"
#include "guild.h"

extern Scheduler g_scheduler;

void TerritoryManager::startLoop() {
    processYields();
    // Execute yields every hour (3600000 ms)
    g_scheduler.addEvent(createSchedulerTask(3600000, std::bind(&TerritoryManager::startLoop, this)));
}

bool TerritoryManager::loadTerritories() {
    Database& db = Database::getInstance();
    DBResult_ptr result = db.storeQuery("SELECT `id`, `name`, `owner_guild_id`, `yield_gold` FROM `territories`");
    
    if (!result) return false;

    do {
        TerritoryNode node;
        node.id = result->getNumber<uint32_t>("id");
        node.name = result->getString("name");
        node.ownerGuildId = result->getNumber<uint32_t>("owner_guild_id");
        node.yieldGold = result->getNumber<uint32_t>("yield_gold");
        nodes[node.id] = node;
    } while (result->next());

    return true;
}

void TerritoryManager::setOwner(uint32_t territoryId, uint32_t guildId) {
    auto it = nodes.find(territoryId);
    if (it != nodes.end()) {
        it->second.ownerGuildId = guildId;
        
        Database& db = Database::getInstance();
        std::ostringstream query;
        query << "UPDATE `territories` SET `owner_guild_id` = " << guildId << " WHERE `id` = " << territoryId;
        db.executeQuery(query.str());
    }
}

uint32_t TerritoryManager::getOwner(uint32_t territoryId) const {
    auto it = nodes.find(territoryId);
    if (it != nodes.end()) {
        return it->second.ownerGuildId;
    }
    return 0;
}

void TerritoryManager::processYields() {
    Database& db = Database::getInstance();
    
    // For each territory, add yieldGold to the Guild's bank balance
    for (const auto& pair : nodes) {
        if (pair.second.ownerGuildId != 0 && pair.second.yieldGold > 0) {
            std::ostringstream query;
            query << "UPDATE `guilds` SET `balance` = `balance` + " << pair.second.yieldGold << " WHERE `id` = " << pair.second.ownerGuildId;
            db.executeQuery(query.str());
        }
    }
}

void TerritoryManager::updateCaptureProgress(uint32_t territoryId, Player* invader) {
    auto it = nodes.find(territoryId);
    if (it != nodes.end()) {
        TerritoryNode& node = it->second;
        Guild* guild = invader->getGuild();
        if (!guild) return;
        
        uint32_t guildId = guild->getId();
        if (node.ownerGuildId == guildId) return; // Already owns it
        
        // Nen Lock mechanics
        if (invader->hasCondition(CONDITION_AURA_REN) || invader->hasCondition(CONDITION_AURA_EN) || invader->hasCondition(CONDITION_AURA_GYO)) {
            if (node.capturingGuildId != guildId) {
                node.capturingGuildId = guildId;
                node.influencePoints = 0.0f;
            }
            
            // Progress proportional to player's level / 100
            node.influencePoints += (invader->getLevel() * 0.01f);
            
            if (node.influencePoints >= 100.0f) {
                setOwner(territoryId, guildId);
                node.influencePoints = 0.0f;
                node.capturingGuildId = 0;
                std::cout << ">> Territory " << node.name << " captured by guild ID " << guildId << std::endl;
            }
        }
    }
}
