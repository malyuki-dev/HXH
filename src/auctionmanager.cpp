#include "auctionmanager.h"
#include "databasemanager.h"
#include "game.h"
#include "scheduler.h"
#include "iologindata.h"
#include "tools.h"

extern Game g_game;
extern Scheduler g_scheduler;

void AuctionManager::startLoop() {
    checkExpiredAuctions();
    g_scheduler.addEvent(createSchedulerTask(60000, std::bind(&AuctionManager::startLoop, this)));
}

bool AuctionManager::createAuction(Player* player, Item* item, uint64_t startPrice, uint64_t buyoutPrice, uint32_t durationSeconds) {
    if (!player || !item) return false;

    // Serialize item attributes (concept)
    // We would serialize the item here to binary/JSON. For this skeleton, we use an empty string.
    std::string attributes = "";
    
    Database& db = Database::getInstance();
    std::ostringstream query;
    query << "INSERT INTO `auctions` (`player_id`, `item_id`, `item_count`, `item_attributes`, `start_price`, `buyout_price`, `end_time`) VALUES (";
    query << player->getGUID() << ", " << item->getID() << ", " << item->getItemCount() << ", " << db.escapeBlob(attributes.c_str(), attributes.length()) << ", ";
    query << startPrice << ", " << buyoutPrice << ", " << (time(nullptr) + durationSeconds) << ")";

    return db.executeQuery(query.str());
}

bool AuctionManager::placeBid(Player* player, uint32_t auctionId, uint64_t bidAmount) {
    if (!player) return false;

    std::lock_guard<std::mutex> lock(auctionMutex);
    Database& db = Database::getInstance();

    if (!db.beginTransaction()) {
        return false;
    }

    std::ostringstream query;
    query << "SELECT `current_bid`, `start_price`, `top_bidder`, `end_time` FROM `auctions` WHERE `id` = " << auctionId << " FOR UPDATE";
    
    DBResult_ptr result = db.storeQuery(query.str());
    if (!result) {
        db.rollback();
        return false;
    }

    uint64_t currentBid = result->getNumber<uint64_t>("current_bid");
    uint64_t startPrice = result->getNumber<uint64_t>("start_price");
    uint32_t topBidder = result->getNumber<uint32_t>("top_bidder");
    uint64_t endTime = result->getNumber<uint64_t>("end_time");

    uint64_t minBid = (currentBid == 0) ? startPrice : currentBid + 1; // Simplistic min bid

    if (bidAmount < minBid) {
        db.rollback();
        return false;
    }

    // JITTER ANTI-SNIPING: If less than 5 minutes remain, add 1-5 minutes randomly
    uint64_t currentTime = time(nullptr);
    if (endTime > currentTime && endTime - currentTime < 300) {
        endTime += uniform_random(60, 300);
    }

    // Refund previous bidder if any (concept, typically done via inbox/mail system in TFS)
    if (topBidder != 0) {
        // Send mail or add bank balance to topBidder
        std::ostringstream refundQuery;
        refundQuery << "UPDATE `players` SET `balance` = `balance` + " << currentBid << " WHERE `id` = " << topBidder;
        db.executeQuery(refundQuery.str());
    }

    // Deduct from current player
    // Note: Assuming player->removeMoney or similar. For true ACID, we do it in DB or game engine safely.
    if (!player->removeBankMoney(bidAmount)) {
        db.rollback();
        return false;
    }

    std::ostringstream updateQuery;
    updateQuery << "UPDATE `auctions` SET `current_bid` = " << bidAmount << ", `top_bidder` = " << player->getGUID() << ", `end_time` = " << endTime << " WHERE `id` = " << auctionId;
    if (!db.executeQuery(updateQuery.str())) {
        db.rollback();
        // Give money back
        player->addBankMoney(bidAmount);
        return false;
    }

    db.commit();
    return true;
}

bool AuctionManager::buyoutAuction(Player* player, uint32_t auctionId) {
    // Similar to placeBid, but automatically ends auction if amount == buyout_price
    return false;
}

void AuctionManager::checkExpiredAuctions() {
    std::lock_guard<std::mutex> lock(auctionMutex);
    Database& db = Database::getInstance();
    
    std::ostringstream query;
    query << "SELECT * FROM `auctions` WHERE `end_time` <= " << time(nullptr);
    DBResult_ptr result = db.storeQuery(query.str());
    
    if (!result) return;
    
    do {
        uint32_t id = result->getNumber<uint32_t>("id");
        int32_t sellerId = result->getNumber<int32_t>("player_id");
        int32_t topBidder = result->getNumber<int32_t>("top_bidder");
        uint64_t finalPrice = result->getNumber<uint64_t>("current_bid");
        uint16_t itemId = result->getNumber<uint16_t>("item_id");
        uint16_t itemCount = result->getNumber<uint16_t>("item_count");
        std::string attributes = result->getString("item_attributes");

        processAuctionEnd(id, sellerId, topBidder, finalPrice, itemId, itemCount, attributes);

        std::ostringstream deleteQuery;
        deleteQuery << "DELETE FROM `auctions` WHERE `id` = " << id;
        db.executeQuery(deleteQuery.str());
    } while (result->next());
}

void AuctionManager::processAuctionEnd(uint32_t auctionId, int32_t sellerId, int32_t topBidder, uint64_t finalPrice, uint16_t itemId, uint16_t itemCount, const std::string& attributes) {
    Database& db = Database::getInstance();
    if (topBidder == 0) {
        // Return item to seller (e.g. via Mail/Inbox)
    } else {
        // Send money to seller
        std::ostringstream sellerQuery;
        sellerQuery << "UPDATE `players` SET `balance` = `balance` + " << finalPrice << " WHERE `id` = " << sellerId;
        db.executeQuery(sellerQuery.str());
        
        // Send item to topBidder via Mail/Inbox
    }
}
