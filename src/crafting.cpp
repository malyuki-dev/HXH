#include "crafting.h"
#include "game.h"
#include <iostream>

extern Game g_game;

void BlueprintRegistry::loadBlueprints() {
    // Para simplificar, faremos hardcode de uma receita base (Fase 26 inicial)
    // Em produção, isso leria de um arquivo XML ou JSON.
    Blueprint sword;
    sword.outputItemId = 2376; // Sword comum
    sword.requiredMaterials.push_back({5880, 2}); // 2 iron ores
    sword.baseMaterializationTime = 5.0f;
    blueprints[1] = sword;
    
    std::cout << ">> Loaded " << blueprints.size() << " crafting blueprints." << std::endl;
}

bool BlueprintRegistry::canCraft(Player* player, uint32_t blueprintId) {
    auto it = blueprints.find(blueprintId);
    if (it == blueprints.end()) {
        return false;
    }
    
    const Blueprint& bp = it->second;
    for (const auto& mat : bp.requiredMaterials) {
        if (player->getItemTypeCount(mat.first) < mat.second) {
            return false;
        }
    }
    return true;
}

bool BlueprintRegistry::craftItem(Player* player, uint32_t blueprintId) {
    auto it = blueprints.find(blueprintId);
    if (it == blueprints.end()) {
        return false;
    }
    
    if (!canCraft(player, blueprintId)) {
        return false;
    }
    
    const Blueprint& bp = it->second;
    
    // Consome atômicamente
    for (const auto& mat : bp.requiredMaterials) {
        g_game.removeItemOfType(player, mat.first, mat.second, -1);
    }
    
    // Injeta o item criado
    Item* item = Item::CreateItem(bp.outputItemId);
    if (item) {
        ReturnValue ret = g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
        if (ret != RETURNVALUE_NOERROR) {
            // Se o inventário estiver cheio, dropa no chão
            g_game.internalAddItem(player->getTile(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);
        }
        return true;
    }
    return false;
}
