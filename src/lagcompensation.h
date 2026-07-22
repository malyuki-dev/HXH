#ifndef FS_LAGCOMPENSATION_H_
#define FS_LAGCOMPENSATION_H_

#include "position.h"
#include <unordered_map>
#include <deque>
#include <mutex>
#include <cstdint>

struct CreatureSnapshot {
    Position pos;
    // can add health, direction, etc.
};

struct ServerSnapshot {
    int64_t timestamp;
    std::unordered_map<uint32_t, CreatureSnapshot> creatures;
};

class LagCompensation {
public:
    static LagCompensation& getInstance() {
        static LagCompensation instance;
        return instance;
    }

    void startLoop();
    void takeSnapshot(int64_t currentTime);
    bool getHistoricPosition(uint32_t creatureId, int64_t timestamp, Position& outPos);

private:
    LagCompensation() = default;
    ~LagCompensation() = default;

    LagCompensation(const LagCompensation&) = delete;
    LagCompensation& operator=(const LagCompensation&) = delete;

    std::deque<ServerSnapshot> history;
    std::mutex historyMutex;

    // keep max 20 snapshots (e.g. 1 second at 50ms intervals)
    const size_t MAX_SNAPSHOTS = 20;
};

#endif // FS_LAGCOMPENSATION_H_
