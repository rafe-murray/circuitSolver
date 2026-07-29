#pragma once

#include <spdlog/common.h>

#include <cstdint>

namespace circuitsolver::server::config {
/// Config is the config for a CircuitSolver instance
struct Config {
  /// port is the port to serve traffic on
  uint16_t port = 8080;
  /// numThreads is the number of threads to use
  unsigned numThreads = 2;
  /// maxRequestSize is the maximum request size, in bytes
  size_t maxRequestSize = 32768;
  /// maxResponseSize is the maximum response size, in bytes
  size_t maxResponseSize = 32768;
  /// logLevel is the global log level
  spdlog::level::level_enum logLevel;
  /// mergeFromAllSources merges config from all available sources. Currently
  /// only environment variables and defaults are supported.
  static auto mergeFromAllSources() -> Config;
};
}  // namespace circuitsolver::server::config
