#ifndef FS_SNAPSHOT_BUFFER_H
#define FS_SNAPSHOT_BUFFER_H

#include "position.h"
#include <unordered_map>
#include <deque>
#include <mutex>
#include <chrono>
#include <cstdint>

struct SnapshotEntry {
    int64_t timestamp;
    Position pos;
};

class SnapshotBuffer {
public:
    static SnapshotBuffer& getInstance() {
        static SnapshotBuffer instance;
        return instance;
    }

    // Stores a snapshot of the creature's position
    void recordPosition(uint32_t creatureId, const Position& pos);

    // Removes a creature from the buffer (e.g. when it dies/logs out)
    void removeCreature(uint32_t creatureId);

    // Retrieves the position of a creature at a specific time in the past
    // Returns true if a valid position was found, false otherwise
    bool getPastPosition(uint32_t creatureId, int64_t timestampMs, Position& outPos);

private:
    SnapshotBuffer() = default;
    ~SnapshotBuffer() = default;

    std::unordered_map<uint32_t, std::deque<SnapshotEntry>> snapshots;
    std::mutex bufferMutex;
    
    // Retain only last 3 seconds of snapshots (assuming ~20 updates per sec max = 60 entries max)
    static constexpr size_t MAX_SNAPSHOTS_PER_CREATURE = 60;
};

#endif // FS_SNAPSHOT_BUFFER_H
