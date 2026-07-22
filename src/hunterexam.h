#ifndef FS_HUNTEREXAM_H
#define FS_HUNTEREXAM_H

#include "player.h"
#include <map>
#include <mutex>

enum class ExamState {
    IDLE = 0,
    REGISTRATION = 1,
    PHASE_1 = 2,
    PHASE_2 = 3,
    PHASE_3 = 4,
    COMPLETED = 5
};

class HunterExamManager {
public:
    static HunterExamManager& getInstance() {
        static HunterExamManager instance;
        return instance;
    }

    void setState(ExamState state);
    ExamState getState() const;

    bool registerCandidate(Player* player);
    bool advanceCandidate(Player* player, ExamState nextPhase);
    
    // Middleware de Autorizacao
    bool isAuthorized(Player* player, ExamState requiredState) const;

private:
    HunterExamManager() = default;
    ~HunterExamManager() = default;

    HunterExamManager(const HunterExamManager&) = delete;
    HunterExamManager& operator=(const HunterExamManager&) = delete;

    ExamState currentState = ExamState::IDLE;
    std::mutex examMutex;
    
    // player ID -> Their current Exam Phase
    std::map<uint32_t, ExamState> candidates;
};

#endif
