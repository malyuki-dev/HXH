#ifndef FS_AUCTIONMANAGER_H
#define FS_AUCTIONMANAGER_H

#include "player.h"
#include "item.h"
#include <mutex>

class AuctionManager {
public:
    static AuctionManager& getInstance() {
        static AuctionManager instance;
        return instance;
    }

    bool createAuction(Player* player, Item* item, uint64_t startPrice, uint64_t buyoutPrice, uint32_t durationSeconds);
    bool placeBid(Player* player, uint32_t auctionId, uint64_t bidAmount);
    bool buyoutAuction(Player* player, uint32_t auctionId);
    void checkExpiredAuctions();

    void startLoop();

private:
    AuctionManager() = default;
    ~AuctionManager() = default;

    AuctionManager(const AuctionManager&) = delete;
    AuctionManager& operator=(const AuctionManager&) = delete;

    std::mutex auctionMutex;
    
    void processAuctionEnd(uint32_t auctionId, int32_t sellerId, int32_t topBidder, uint64_t finalPrice, uint16_t itemId, uint16_t itemCount, const std::string& attributes);
};

#endif
