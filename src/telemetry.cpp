#include "telemetry.h"
#include "metrics.h"
#include <iostream>

ServerMetrics TelemetryServer::metrics;

TelemetryServer::TelemetryServer(uint16_t port)
    : port(port),
      acceptor(io_context, boost::asio::ip::tcp::endpoint(boost::asio::ip::tcp::v4(), port)) {
}

TelemetryServer::~TelemetryServer() {
    stop();
}

void TelemetryServer::start() {
    isRunning = true;
    acceptConnections();
    serverThread = std::thread([this]() {
        io_context.run();
    });
}

void TelemetryServer::stop() {
    if (isRunning) {
        isRunning = false;
        io_context.stop();
        if (serverThread.joinable()) {
            serverThread.join();
        }
    }
}

void TelemetryServer::acceptConnections() {
    if (!isRunning) return;

    auto socket = std::make_shared<boost::asio::ip::tcp::socket>(io_context);
    acceptor.async_accept(*socket, [this, socket](const boost::system::error_code& error) {
        if (!error) {
            handleRequest(socket);
        }
        acceptConnections();
    });
}

void TelemetryServer::handleRequest(std::shared_ptr<boost::asio::ip::tcp::socket> socket) {
    // Read the request minimally, just assume it's a GET /metrics
    auto buffer = std::make_shared<std::vector<char>>(1024);
    socket->async_read_some(boost::asio::buffer(*buffer), 
        [this, socket, buffer](const boost::system::error_code& error, std::size_t bytes_transferred) {
            if (!error) {
                // Prepare prometheus output
                std::string body = 
                    "# HELP aldebaran_active_players Number of players online\n"
                    "# TYPE aldebaran_active_players gauge\n"
                    "aldebaran_active_players " + std::to_string(metrics.activePlayers.load()) + "\n"
                    "# HELP aldebaran_skill_invocations_total Total number of skills used\n"
                    "# TYPE aldebaran_skill_invocations_total counter\n"
                    "aldebaran_skill_invocations_total " + std::to_string(metrics.totalSkillInvocations.load()) + "\n"
                    "# HELP aldebaran_active_duels Number of active duels\n"
                    "# TYPE aldebaran_active_duels gauge\n"
                    "aldebaran_active_duels " + std::to_string(metrics.activeDuels.load()) + "\n" +
                    Metrics::getInstance().getPrometheusMetrics();

                std::string response = 
                    "HTTP/1.1 200 OK\r\n"
                    "Content-Type: text/plain; version=0.0.4\r\n"
                    "Content-Length: " + std::to_string(body.size()) + "\r\n"
                    "Connection: close\r\n\r\n" + body;

                auto response_buffer = std::make_shared<std::string>(response);
                boost::asio::async_write(*socket, boost::asio::buffer(*response_buffer),
                    [socket, response_buffer](const boost::system::error_code&, std::size_t) {
                        socket->close();
                    });
            }
        });
}

void TelemetryServer::incrementActivePlayers() {
    metrics.activePlayers.fetch_add(1, std::memory_order_relaxed);
}

void TelemetryServer::decrementActivePlayers() {
    metrics.activePlayers.fetch_sub(1, std::memory_order_relaxed);
}

void TelemetryServer::incrementSkillUsage() {
    metrics.totalSkillInvocations.fetch_add(1, std::memory_order_relaxed);
}

void TelemetryServer::incrementActiveDuels() {
    metrics.activeDuels.fetch_add(1, std::memory_order_relaxed);
}

void TelemetryServer::decrementActiveDuels() {
    metrics.activeDuels.fetch_sub(1, std::memory_order_relaxed);
}
