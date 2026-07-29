#include "config.h"

#include <spdlog/common.h>

#include "configManager.h"
#include "configSource.h"

namespace circuitsolver::server::config {
auto Config::mergeFromAllSources() -> Config {
  auto configManager = ConfigManager{}.addSource(
      std::make_unique<EnvConfigSource>("CIRCUIT_SOLVER"))
      // .addSource(OptsConfigSource{})
      ;

  auto port = configManager.get<uint16_t>("port").value_or(8080);
  auto numThreads = configManager.get<unsigned>("numThreads").value_or(2);
  auto maxRequestSize =
      configManager.get<size_t>("maxRequestSize").value_or(32768);
  auto maxResponseSize =
      configManager.get<size_t>("maxResponseSize").value_or(32768);
  auto logLevel = spdlog::level::from_str(
      configManager.get<std::string>("logLevel").value_or("info"));

  return Config{.port = port,
                .numThreads = numThreads,
                .maxRequestSize = maxRequestSize,
                .maxResponseSize = maxResponseSize,
                .logLevel = logLevel};
}
}  // namespace circuitsolver::server::config
