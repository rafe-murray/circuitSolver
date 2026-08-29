#pragma once

#include <spdlog/common.h>

#include <cstdint>

namespace circuitsolver::server::config {

constexpr uint16_t defaultPort = 8080;
constexpr int defaultNumThreads = 2;
constexpr size_t defaultMaxRequestSize = 32768;
constexpr size_t defaultMaxResponseSize = 32768;
constexpr spdlog::level::level_enum defaultLogLevel = spdlog::level::info;

/// Config is the config for a CircuitSolver instance
struct Config {
  /// port is the port to serve traffic on
  uint16_t port = defaultPort;
  /// numThreads is the number of threads to use
  int numThreads = defaultNumThreads;
  /// maxRequestSize is the maximum request size, in bytes
  size_t maxRequestSize = defaultMaxRequestSize;
  /// maxResponseSize is the maximum response size, in bytes
  size_t maxResponseSize = defaultMaxResponseSize;
  /// logLevel is the global log level
  spdlog::level::level_enum logLevel = defaultLogLevel;
  /// mergeFromAllSources merges config from all available sources. Currently
  /// only environment variables and defaults are supported.
  static auto mergeFromAllSources() -> Config;
};
}  // namespace circuitsolver::server::config
