#ifndef FS_BOUNTY_H
#define FS_BOUNTY_H

#include "player.h"
#include <map>
#include <mutex>
#include <vector>

struct Bounty {
    uint32_t targetId;
    uint32_t posterId;
    uint64_t reward;
};

class BountyManager {
public:
    static BountyManager& getInstance() {
        static BountyManager instance;
        return instance;
    }

    bool placeBounty(Player* poster, uint32_t targetId, uint64_t reward);
    void checkKill(Player* killer, Player* target);
    bool loadBounties();

private:
    BountyManager() = default;
    ~BountyManager() = default;

    BountyManager(const BountyManager&) = delete;
    BountyManager& operator=(const BountyManager&) = delete;

    std::mutex bountyMutex;
    std::vector<Bounty> bounties;

    // Anti-trade: killer IP -> target IP -> last kill time
    std::map<uint32_t, std::map<uint32_t, int64_t>> killHistory;
};

#endif
