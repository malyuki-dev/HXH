#include "lagcompensation.h"
#include "game.h"
#include "creature.h"
#include "scheduler.h"

extern Game g_game;
extern Scheduler g_scheduler;

void LagCompensation::startLoop() {
    takeSnapshot(OTSYS_TIME());
    g_scheduler.addEvent(createSchedulerTask(50, std::bind(&LagCompensation::startLoop, this)));
}

void LagCompensation::takeSnapshot(int64_t currentTime) {
    std::lock_guard<std::mutex> lock(historyMutex);
    
    ServerSnapshot snapshot;
    snapshot.timestamp = currentTime;

    // We iterate over all active creatures and save their positions
    // Note: in a highly optimized server, we only save creatures that moved since last snapshot
    // But for this alpha version, we capture all active players/monsters
    for (const auto& it : g_game.getPlayers()) {
        if (it.second) {
            snapshot.creatures[it.second->getID()] = {it.second->getPosition()};
        }
    }

    history.push_front(std::move(snapshot));
    
    if (history.size() > MAX_SNAPSHOTS) {
        history.pop_back();
    }
}

bool LagCompensation::getHistoricPosition(uint32_t creatureId, int64_t targetTimestamp, Position& outPos) {
    std::lock_guard<std::mutex> lock(historyMutex);
    
    if (history.empty()) return false;

    // Find the closest snapshot to targetTimestamp
    for (const auto& snapshot : history) {
        // Since it's sorted descending (push_front), we find the first one <= targetTimestamp
        // or just closest. For simplicity, we just check if it's within 100ms.
        if (std::abs(snapshot.timestamp - targetTimestamp) <= 100) {
            auto it = snapshot.creatures.find(creatureId);
            if (it != snapshot.creatures.end()) {
                outPos = it->second.pos;
                return true;
            }
        }
    }
    return false;
}
