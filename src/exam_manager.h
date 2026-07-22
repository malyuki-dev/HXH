#ifndef FS_EXAM_MANAGER_H
#define FS_EXAM_MANAGER_H

#include "player.h"

enum class ExamStage {
    PREPARATION,
    COMBAT_TEST,
    NEN_AFFINITY_TEST,
    FINAL_DUEL
};

class ExamManager {
public:
    static ExamManager& getInstance() {
        static ExamManager instance;
        return instance;
    }

    void onStageComplete(Player* player, ExamStage currentStage);
    void grantLicense(Player* player, const std::string& licenseName);
    bool hasLicense(Player* player, const std::string& licenseName);

private:
    ExamManager() = default;
    ~ExamManager() = default;
    
    ExamManager(const ExamManager&) = delete;
    ExamManager& operator=(const ExamManager&) = delete;
};

#endif // FS_EXAM_MANAGER_H
