#ifndef FS_TELEMETRY_H
#define FS_TELEMETRY_H

#include <atomic>
#include <string>
#include <memory>
#include <thread>
#include <boost/asio.hpp>

struct ServerMetrics {
    std::atomic<uint32_t> activePlayers{0};
    std::atomic<float> cpuUsage{0.0f};
    std::atomic<uint64_t> totalSkillInvocations{0};
    std::atomic<uint64_t> activeDuels{0};
};

class TelemetryServer {
public:
    TelemetryServer(uint16_t port);
    ~TelemetryServer();

    void start();
    void stop();

    // Metric modifiers
    static void incrementActivePlayers();
    static void decrementActivePlayers();
    static void incrementSkillUsage();
    static void incrementActiveDuels();
    static void decrementActiveDuels();

    static ServerMetrics metrics;

private:
    void acceptConnections();
    void handleRequest(std::shared_ptr<boost::asio::ip::tcp::socket> socket);

    uint16_t port;
    boost::asio::io_context io_context;
    boost::asio::ip::tcp::acceptor acceptor;
    std::thread serverThread;
    bool isRunning = false;
};

#endif // FS_TELEMETRY_H
