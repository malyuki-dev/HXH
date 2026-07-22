#include "exam_manager.h"
#include <iostream>

void ExamManager::onStageComplete(Player* player, ExamStage currentStage) {
    if (!player) return;

    switch(currentStage) {
        case ExamStage::PREPARATION:
            std::cout << ">> " << player->getName() << " started COMBAT_TEST." << std::endl;
            // Update storage/database for player state
            break;
            
        case ExamStage::COMBAT_TEST:
            // Validacao: Jogador deve ter precisao ou matar monstros
            // Se passar:
            std::cout << ">> " << player->getName() << " passed COMBAT_TEST." << std::endl;
            break;
            
        case ExamStage::NEN_AFFINITY_TEST:
            std::cout << ">> " << player->getName() << " passed NEN_AFFINITY_TEST." << std::endl;
            break;
            
        case ExamStage::FINAL_DUEL:
            std::cout << ">> " << player->getName() << " passed FINAL_DUEL and became a Hunter!" << std::endl;
            grantLicense(player, "HUNTER_LICENSE");
            break;
    }
}

void ExamManager::grantLicense(Player* player, const std::string& licenseName) {
    if (!player) return;
    
    // In TFS, storage keys are uint32_t. We can map "HUNTER_LICENSE" to a key like 10001
    uint32_t key = 10001; // HUNTER_LICENSE key
    player->addStorageValue(key, 1);
    
    std::cout << ">> Granted license " << licenseName << " to " << player->getName() << std::endl;
}

bool ExamManager::hasLicense(Player* player, const std::string& licenseName) {
    if (!player) return false;
    
    uint32_t key = 10001; // HUNTER_LICENSE key
    int32_t value;
    if (player->getStorageValue(key, value)) {
        return value == 1;
    }
    return false;
}
