#ifndef FS_BLUEPRINTMANAGER_H
#define FS_BLUEPRINTMANAGER_H

#include "player.h"
#include <map>
#include <vector>
#include <string>

struct BlueprintRequirement {
    uint16_t itemId;
    uint16_t count;
};

struct Blueprint {
    uint32_t id;
    std::string name;
    uint16_t resultItemId;
    uint16_t resultCount;
    std::vector<BlueprintRequirement> requirements;
};

class BlueprintManager {
public:
    static BlueprintManager& getInstance() {
        static BlueprintManager instance;
        return instance;
    }

    bool loadFromXml(const std::string& filename);
    const Blueprint* getBlueprint(uint32_t id) const;
    bool craft(Player* player, uint32_t blueprintId);

private:
    BlueprintManager() = default;
    ~BlueprintManager() = default;

    BlueprintManager(const BlueprintManager&) = delete;
    BlueprintManager& operator=(const BlueprintManager&) = delete;

    std::map<uint32_t, Blueprint> blueprints;
};

#endif
