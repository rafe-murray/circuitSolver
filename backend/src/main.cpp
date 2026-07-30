#include <pistache/endpoint.h>
#include <pistache/net.h>
#include <pistache/tcp.h>
#include <spdlog/spdlog.h>

#include <memory>

#include "config/config.h"
#include "observability/logger.h"
#include "observability/otel.h"
#include "services/circuitSolverService.h"

using circuitsolver::server::config::Config;
using circuitsolver::server::services::CircuitSolverService;
namespace logger = circuitsolver::server::observability::logger;
namespace otel = circuitsolver::server::observability::otel;

// #ifdef __linux__
// static void sigHandler [[noreturn]] (int sig) {
//   switch (sig) {
//     case SIGINT:
//     case SIGQUIT:
//     case SIGTERM:
//     case SIGHUP:
//     default:
//       httpEndpoint->shutdown();
//       break;
//   }
//   exit(0);
// }
//
// static void setUpUnixSignals(std::vector<int> quitSignals) {
//   sigset_t blocking_mask;
//   sigemptyset(&blocking_mask);
//   for (auto sig : quitSignals) sigaddset(&blocking_mask, sig);
//
//   struct sigaction sa;
//   sa.sa_handler = sigHandler;
//   sa.sa_mask = blocking_mask;
//   sa.sa_flags = 0;
//
//   for (auto sig : quitSignals) sigaction(sig, &sa, nullptr);
// }
// #endif

// NOLINTBEGIN(bugprone-exception-escape)
auto main() -> int {
  // #ifdef __linux__
  //   std::vector<int> sigs{SIGQUIT, SIGINT, SIGTERM, SIGHUP};
  //   setUpUnixSignals(sigs);
  // #endif
  auto config = Config::mergeFromAllSources();

  otel::init(config);
  logger::init(config);

  spdlog::info("Starting up circuitsolver server");

  Pistache::Address address(Pistache::Ipv4::any(), Pistache::Port(config.port));
  auto endpoint = std::make_unique<Pistache::Http::Endpoint>(address);
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
  endpoint->shutdown();
  spdlog::info("Bye");
}
// NOLINTEND(bugprone-exception-escape)
