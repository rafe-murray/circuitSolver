#include <pistache/endpoint.h>
#include <pistache/net.h>
#include <pistache/tcp.h>
#include <spdlog/spdlog.h>

#include <memory>

#include "config/config.h"
#include "endpointHandler.h"
#include "observability/logger.h"
#include "observability/otel.h"
#include "services/circuitSolverService.h"

using circuitsolver::server::EndpointHandler;
using circuitsolver::server::config::Config;
using circuitsolver::server::services::CircuitSolverService;
namespace logger = circuitsolver::server::observability::logger;
namespace otel = circuitsolver::server::observability::otel;

#ifdef __linux__
/// sigHandler cleans up the endpoint and exits gracefully
///
/// @param sig the signal to handle
static void sigHandler [[noreturn]] (int sig) {
  switch (sig) {
    case SIGINT:
    case SIGQUIT:
    case SIGTERM:
    case SIGHUP:
    default:
      EndpointHandler::shutdown();
      break;
  }
  exit(0);
}

/// setUpUnixSignals sets up signal handlers for unix signals
///
/// @param quitSignals list of signals to cause the application to quit
static void setUpUnixSignals(const std::vector<int>& quitSignals) {
  sigset_t blocking_mask;
  sigemptyset(&blocking_mask);
  for (auto sig : quitSignals) {
    sigaddset(&blocking_mask, sig);
  }

  // NOLINTBEGIN(readability-identifier-length)
  struct sigaction sa{};
  // NOLINTEND(readability-identifier-length)
  sa.sa_handler = sigHandler;
  sa.sa_mask = blocking_mask;
  sa.sa_flags = 0;

  for (auto sig : quitSignals) {
    sigaction(sig, &sa, nullptr);
  }
}
#endif

// NOLINTBEGIN(bugprone-exception-escape)
// It's fine if uncought exceptions crash main; these should only be
// memory-allocation issues, which we should crash for

/// main runs the application
auto main() -> int {
#ifdef __linux__
  std::vector<int> sigs{SIGQUIT, SIGINT, SIGTERM, SIGHUP};
  setUpUnixSignals(sigs);
#endif

  auto config = Config::mergeFromAllSources();

  otel::init(config);
  auto logging = logger::Logging{config};

  spdlog::info("Starting up circuitsolver server");

  EndpointHandler::init(config);
  auto* endpoint = EndpointHandler::getEndpoint();
  auto router = std::make_shared<Pistache::Rest::Router>();

  auto opts = Pistache::Http::Endpoint::options()
                  .threads(config.numThreads)
                  .flags(Pistache::Tcp::Options::ReuseAddr)
                  .maxRequestSize(config.maxRequestSize)
                  .maxResponseSize(config.maxResponseSize);
  endpoint->init(opts);

  auto circuitSolverService = std::make_shared<CircuitSolverService>(router);
  circuitSolverService->init();

  endpoint->setHandler(router->handler());
  spdlog::info("Listening on port {}", config.port);
  endpoint->serve();
  EndpointHandler::shutdown();
  spdlog::info("Bye");
}
// NOLINTEND(bugprone-exception-escape)
