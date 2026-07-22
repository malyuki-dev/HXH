#include "stress_test.h"
#include "player.h"
#include "game.h"
#include "scheduler.h"
#include <iostream>

extern Game g_game;
extern Scheduler g_scheduler;

StressTestManager::~StressTestManager() {
    stopStressTest();
}

void StressTestManager::startStressTest(uint32_t botCount) {
    if (isRunning) return;
    
    std::cout << ">> Starting Stress Test with " << botCount << " Ghost Bots..." << std::endl;
    isRunning = true;
    
    for (uint32_t i = 0; i < botCount; ++i) {
        Player* bot = new Player(nullptr);
        bot->setName("GhostBot_" + std::to_string(i));
        // Configurar posições, stats, etc
        Position pos(1000 + (rand() % 100), 1000 + (rand() % 100), 7);
        g_game.internalPlaceCreature(bot, g_game.getMap().getTile(pos));
        ghostBots.push_back(bot);
    }
    
    // Inicia o simulation loop via scheduler
    taskId = g_scheduler.addEvent(createSchedulerTask(1000, std::bind(&StressTestManager::simulationLoop, this)));
}

void StressTestManager::stopStressTest() {
    if (!isRunning) return;
    
    std::cout << ">> Stopping Stress Test..." << std::endl;
    isRunning = false;
    
    if (taskId != 0) {
        g_scheduler.stopEvent(taskId);
        taskId = 0;
    }
    
    for (Player* bot : ghostBots) {
        g_game.removeCreature(bot);
        // Deletar bots gerenciados
        delete bot;
    }
    ghostBots.clear();
}

void StressTestManager::simulationLoop() {
    if (!isRunning) return;
    
    // Move os bots aleatoriamente
    for (Player* bot : ghostBots) {
        if (!bot->isRemoved()) {
            Direction dir = static_cast<Direction>(rand() % 4);
            g_game.internalMoveCreature(bot, dir);
            
            // Simular uso de magia/ataque...
        }
    }
    
    // Roda a cada 500ms
    taskId = g_scheduler.addEvent(createSchedulerTask(500, std::bind(&StressTestManager::simulationLoop, this)));
}
