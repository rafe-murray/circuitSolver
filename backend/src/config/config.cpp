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

  auto port = configManager.get<uint16_t>("port").value_or(defaultPort);
  auto numThreads =
      configManager.get<int>("numThreads").value_or(defaultNumThreads);
  auto maxRequestSize = configManager.get<size_t>("maxRequestSize")
                            .value_or(defaultMaxRequestSize);
  auto maxResponseSize = configManager.get<size_t>("maxResponseSize")
                             .value_or(defaultMaxResponseSize);
  auto logLevel = spdlog::level::from_str(
      configManager.get<std::string>("logLevel")
          .value_or(spdlog::level::to_short_c_str(defaultLogLevel)));

  return Config{.port = port,
                .numThreads = numThreads,
                .maxRequestSize = maxRequestSize,
                .maxResponseSize = maxResponseSize,
                .logLevel = logLevel};
}
}  // namespace circuitsolver::server::config
