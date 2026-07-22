#include "spatialhash.h"
#include "creature.h"

uint64_t SpatialHash::hashPosition(const Position& pos) const {
    // Assuming map max is 65535, we can pack x, y, z into a uint64_t
    return (static_cast<uint64_t>(pos.x) << 32) |
           (static_cast<uint64_t>(pos.y) << 16) |
           static_cast<uint64_t>(pos.z);
}

void SpatialHash::insert(Creature* entity) {
    if (!entity) return;
    std::lock_guard<std::mutex> lock(gridMutex);
    uint64_t hash = hashPosition(entity->getPosition());
    grid[hash].entities.insert(entity);
}

void SpatialHash::remove(Creature* entity) {
    if (!entity) return;
    std::lock_guard<std::mutex> lock(gridMutex);
    uint64_t hash = hashPosition(entity->getPosition());
    auto it = grid.find(hash);
    if (it != grid.end()) {
        it->second.entities.erase(entity);
        if (it->second.entities.empty()) {
            grid.erase(it);
        }
    }
}

void SpatialHash::update(Creature* entity, const Position& oldPos, const Position& newPos) {
    if (!entity) return;
    
    uint64_t oldHash = hashPosition(oldPos);
    uint64_t newHash = hashPosition(newPos);
    
    if (oldHash == newHash) return;

    std::lock_guard<std::mutex> lock(gridMutex);
    
    // Remove from old
    auto it = grid.find(oldHash);
    if (it != grid.end()) {
        it->second.entities.erase(entity);
        if (it->second.entities.empty()) {
            grid.erase(it);
        }
    }
    
    // Add to new
    grid[newHash].entities.insert(entity);
}

std::vector<SpatialCell*> SpatialHash::getSurroundingCells(const Position& pos, int32_t radius) {
    std::vector<SpatialCell*> cells;
    std::lock_guard<std::mutex> lock(gridMutex);
    
    for (int32_t x = -radius; x <= radius; ++x) {
        for (int32_t y = -radius; y <= radius; ++y) {
            Position checkPos(pos.x + x, pos.y + y, pos.z);
            uint64_t hash = hashPosition(checkPos);
            auto it = grid.find(hash);
            if (it != grid.end()) {
                cells.push_back(&it->second);
            }
        }
    }
    return cells;
}

bool SpatialHash::isColliding(Creature* a, Creature* b) const {
    if (!a || !b || a == b) return false;
    // Simple position equality check for grid-based MMORPG
    return a->getPosition() == b->getPosition();
}

void SpatialHash::resolveCollision(Creature* a, Creature* b) {
    // Basic resolution: for now just log or block movement
    // Custom HxH mechanics will go here
}

void SpatialHash::checkCollision(Creature* a) {
    if (!a) return;
    auto cells = getSurroundingCells(a->getPosition(), 1);
    for (auto cell : cells) {
        for (auto other : cell->entities) {
            if (isColliding(a, other)) {
                resolveCollision(a, other);
            }
        }
    }
}
