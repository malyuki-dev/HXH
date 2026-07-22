#ifndef FS_STRESS_TEST_H
#define FS_STRESS_TEST_H

#include <cstdint>
#include <vector>
#include <memory>

class Player;

class StressTestManager {
public:
    static StressTestManager& getInstance() {
        static StressTestManager instance;
        return instance;
    }

    void startStressTest(uint32_t botCount);
    void stopStressTest();
    void simulationLoop();

private:
    StressTestManager() = default;
    ~StressTestManager();

    StressTestManager(const StressTestManager&) = delete;
    StressTestManager& operator=(const StressTestManager&) = delete;

    std::vector<Player*> ghostBots;
    bool isRunning = false;
    uint32_t taskId = 0;
};

#endif // FS_STRESS_TEST_H
