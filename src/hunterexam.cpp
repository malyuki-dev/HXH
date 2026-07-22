#include "hunterexam.h"

void HunterExamManager::setState(ExamState state) {
    std::lock_guard<std::mutex> lock(examMutex);
    currentState = state;
}

ExamState HunterExamManager::getState() const {
    return currentState;
}

bool HunterExamManager::registerCandidate(Player* player) {
    if (!player) return false;
    std::lock_guard<std::mutex> lock(examMutex);
    
    if (currentState != ExamState::REGISTRATION) {
        player->sendTextMessage(MESSAGE_STATUS_SMALL, "The Hunter Exam registration is closed.");
        return false;
    }

    uint32_t guid = player->getGUID();
    if (candidates.find(guid) != candidates.end()) {
        player->sendTextMessage(MESSAGE_STATUS_SMALL, "You are already registered.");
        return false;
    }

    candidates[guid] = ExamState::REGISTRATION;
    player->sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have successfully registered for the Hunter Exam.");
    return true;
}

bool HunterExamManager::advanceCandidate(Player* player, ExamState nextPhase) {
    if (!player) return false;
    std::lock_guard<std::mutex> lock(examMutex);

    uint32_t guid = player->getGUID();
    auto it = candidates.find(guid);
    
    if (it != candidates.end()) {
        it->second = nextPhase;
        return true;
    }
    
    return false;
}

bool HunterExamManager::isAuthorized(Player* player, ExamState requiredState) const {
    if (!player) return false;

    // Check if the exam itself is running
    if (currentState == ExamState::IDLE) return false;

    // Check candidate state
    uint32_t guid = player->getGUID();
    auto it = candidates.find(guid);
    
    if (it != candidates.end()) {
        // Simple middleware: candidate state must be equal or higher than required to enter
        return it->second >= requiredState;
    }
    
    return false;
}
