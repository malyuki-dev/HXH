#include "bounty.h"
#include "databasemanager.h"
#include "iologindata.h"
#include "game.h"

extern Game g_game;

bool BountyManager::loadBounties() {
    Database& db = Database::getInstance();
    DBResult_ptr result = db.storeQuery("SELECT `target_id`, `poster_id`, `reward` FROM `bounties`");
    
    if (!result) return false;

    do {
        Bounty b;
        b.targetId = result->getNumber<uint32_t>("target_id");
        b.posterId = result->getNumber<uint32_t>("poster_id");
        b.reward = result->getNumber<uint64_t>("reward");
        bounties.push_back(b);
    } while (result->next());

    return true;
}

bool BountyManager::placeBounty(Player* poster, uint32_t targetId, uint64_t reward) {
    if (!poster) return false;
    
    if (poster->getGUID() == targetId) {
        poster->sendTextMessage(MESSAGE_STATUS_SMALL, "You cannot place a bounty on yourself.");
        return false;
    }

    if (!poster->removeBankMoney(reward)) {
        poster->sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough money in your bank.");
        return false;
    }

    std::lock_guard<std::mutex> lock(bountyMutex);
    
    Database& db = Database::getInstance();
    std::ostringstream query;
    query << "INSERT INTO `bounties` (`target_id`, `poster_id`, `reward`) VALUES (" 
          << targetId << ", " << poster->getGUID() << ", " << reward << ")";
          
    if (db.executeQuery(query.str())) {
        bounties.push_back({targetId, poster->getGUID(), reward});
        poster->sendTextMessage(MESSAGE_INFO_DESCR, "Bounty successfully placed.");
        return true;
    }

    // Refund
    poster->addBankMoney(reward);
    return false;
}

void BountyManager::checkKill(Player* killer, Player* target) {
    if (!killer || !target) return;

    uint32_t killerIp = killer->getIP();
    uint32_t targetIp = target->getIP();

    std::lock_guard<std::mutex> lock(bountyMutex);

    // Anti-trade: Same IP check
    if (killerIp == targetIp) return;

    // Anti-trade: Farm limit check (1 kill per hour allowed per IP pair for bounty)
    int64_t now = time(nullptr);
    if (now - killHistory[killerIp][targetIp] < 3600) {
        return;
    }

    uint32_t targetId = target->getGUID();
    uint64_t totalReward = 0;

    auto it = bounties.begin();
    while (it != bounties.end()) {
        if (it->targetId == targetId) {
            totalReward += it->reward;
            
            // Delete from DB
            Database& db = Database::getInstance();
            std::ostringstream query;
            query << "DELETE FROM `bounties` WHERE `target_id` = " << targetId << " AND `poster_id` = " << it->posterId;
            db.executeQuery(query.str());

            it = bounties.erase(it);
        } else {
            ++it;
        }
    }

    if (totalReward > 0) {
        killer->addBankMoney(totalReward);
        killer->sendTextMessage(MESSAGE_EVENT_ADVANCE, "You claimed a bounty of " + std::to_string(totalReward) + " gold!");
        killHistory[killerIp][targetIp] = now;
    }
}
