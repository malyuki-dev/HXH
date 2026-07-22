#include "snapshot_buffer.h"

int64_t getCurrentTimeMs() {
    auto now = std::chrono::steady_clock::now();
    return std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();
}

void SnapshotBuffer::recordPosition(uint32_t creatureId, const Position& pos) {
    std::lock_guard<std::mutex> lock(bufferMutex);
    auto& deque = snapshots[creatureId];
    
    SnapshotEntry entry;
    entry.timestamp = getCurrentTimeMs();
    entry.pos = pos;
    
    deque.push_back(entry);
    
    // Maintain maximum buffer size
    if (deque.size() > MAX_SNAPSHOTS_PER_CREATURE) {
        deque.pop_front();
    }
}

void SnapshotBuffer::removeCreature(uint32_t creatureId) {
    std::lock_guard<std::mutex> lock(bufferMutex);
    snapshots.erase(creatureId);
}

bool SnapshotBuffer::getPastPosition(uint32_t creatureId, int64_t timestampMs, Position& outPos) {
    std::lock_guard<std::mutex> lock(bufferMutex);
    auto it = snapshots.find(creatureId);
    if (it == snapshots.end()) {
        return false;
    }
    
    const auto& deque = it->second;
    if (deque.empty()) {
        return false;
    }
    
    // Linearly search for the closest timestamp (could be optimized with binary search if perfectly ordered)
    // We look backwards because the time is usually recent
    for (auto rit = deque.rbegin(); rit != deque.rend(); ++rit) {
        if (rit->timestamp <= timestampMs) {
            outPos = rit->pos;
            return true;
        }
    }
    
    // If all snapshots are newer than timestamp, return the oldest one we have
    outPos = deque.front().pos;
    return true;
}
