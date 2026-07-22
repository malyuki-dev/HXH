#ifndef FS_CRAFTING_H
#define FS_CRAFTING_H

#include <vector>
#include <unordered_map>
#include <cstdint>
#include <utility>
#include "player.h"

struct Blueprint {
    uint32_t outputItemId;
    std::vector<std::pair<uint32_t, uint32_t>> requiredMaterials; // {itemId, quantity}
    float baseMaterializationTime; // Proporcional a habilidade
};

class BlueprintRegistry {
public:
    static BlueprintRegistry& getInstance() {
        static BlueprintRegistry instance;
        return instance;
    }

    void loadBlueprints();
    bool canCraft(Player* player, uint32_t blueprintId);
    bool craftItem(Player* player, uint32_t blueprintId);

private:
    BlueprintRegistry() = default;
    ~BlueprintRegistry() = default;

    std::unordered_map<uint32_t, Blueprint> blueprints;
};

#endif // FS_CRAFTING_H
