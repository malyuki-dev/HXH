#include "metrics.h"
#include <fmt/core.h>

void Metrics::recordTick(int64_t duration) {
    lastTickTime = duration;
    totalTicks++;
    totalTickTime += duration;
    
    int64_t currentMax = maxTickTime.load();
    while (duration > currentMax && !maxTickTime.compare_exchange_weak(currentMax, duration)) {
        // loop until successful or duration is no longer greater
    }
}

std::string Metrics::getPrometheusMetrics() {
    return fmt::format(
        "# HELP tfs_tick_time_ms The time taken to process the last tick in milliseconds.\n"
        "# TYPE tfs_tick_time_ms gauge\n"
        "tfs_tick_time_ms {}\n"
        "# HELP tfs_max_tick_time_ms The maximum tick time observed.\n"
        "# TYPE tfs_max_tick_time_ms gauge\n"
        "tfs_max_tick_time_ms {}\n"
        "# HELP tfs_total_ticks The total number of ticks processed.\n"
        "# TYPE tfs_total_ticks counter\n"
        "tfs_total_ticks {}\n"
        "# HELP tfs_total_tick_time_ms The total time spent processing ticks.\n"
        "# TYPE tfs_total_tick_time_ms counter\n"
        "tfs_total_tick_time_ms {}\n",
        lastTickTime.load(),
        maxTickTime.load(),
        totalTicks.load(),
        totalTickTime.load()
    );
}
