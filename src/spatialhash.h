#ifndef FS_SPATIALHASH_H_
#define FS_SPATIALHASH_H_

#include "position.h"
#include <vector>
#include <unordered_map>
#include <unordered_set>
#include <mutex>

class Creature;

struct SpatialCell {
    std::unordered_set<Creature*> entities;
};

class SpatialHash {
public:
    static SpatialHash& getInstance() {
        static SpatialHash instance;
        return instance;
    }

    void insert(Creature* entity);
    void remove(Creature* entity);
    void update(Creature* entity, const Position& oldPos, const Position& newPos);

    void checkCollision(Creature* a);
    std::vector<SpatialCell*> getSurroundingCells(const Position& pos, int32_t radius = 1);

private:
    SpatialHash() = default;
    ~SpatialHash() = default;

    SpatialHash(const SpatialHash&) = delete;
    SpatialHash& operator=(const SpatialHash&) = delete;

    uint64_t hashPosition(const Position& pos) const;
    bool isColliding(Creature* a, Creature* b) const;
    void resolveCollision(Creature* a, Creature* b);

    std::unordered_map<uint64_t, SpatialCell> grid;
    std::mutex gridMutex;
};

#endif // FS_SPATIALHASH_H_
