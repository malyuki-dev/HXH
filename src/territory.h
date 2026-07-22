#ifndef FS_TERRITORY_H
#define FS_TERRITORY_H

#include <string>
#include <map>
#include <cstdint>

struct TerritoryNode {
    uint32_t id;
    std::string name;
    uint32_t ownerGuildId;
    uint32_t yieldGold;
    float influencePoints = 0.0f; // Acumulado por ocupacao (Nen Lock)
    uint32_t capturingGuildId = 0;
};

class TerritoryManager {
public:
    static TerritoryManager& getInstance() {
        static TerritoryManager instance;
        return instance;
    }

    bool loadTerritories();
    void setOwner(uint32_t territoryId, uint32_t guildId);
    uint32_t getOwner(uint32_t territoryId) const;
    void processYields();
    void updateCaptureProgress(uint32_t territoryId, class Player* invader);
    void startLoop();

private:
    TerritoryManager() = default;
    ~TerritoryManager() = default;

    TerritoryManager(const TerritoryManager&) = delete;
    TerritoryManager& operator=(const TerritoryManager&) = delete;

    std::map<uint32_t, TerritoryNode> nodes;
};

#endif
