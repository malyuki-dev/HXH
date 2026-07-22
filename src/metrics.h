#ifndef FS_METRICS_H
#define FS_METRICS_H

#include <cstdint>
#include <atomic>
#include <string>

class Metrics {
public:
    static Metrics& getInstance() {
        static Metrics instance;
        return instance;
    }

    void recordTick(int64_t duration);
    std::string getPrometheusMetrics();

private:
    Metrics() = default;
    ~Metrics() = default;

    std::atomic<int64_t> lastTickTime{0};
    std::atomic<int64_t> maxTickTime{0};
    std::atomic<uint64_t> totalTicks{0};
    std::atomic<uint64_t> totalTickTime{0};
};

#endif
