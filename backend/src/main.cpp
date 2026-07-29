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

static Pistache::Http::Endpoint* endpoint;

int main() {
  auto config = Config::mergeFromAllSources();

  otel::init(config);
  logger::init(config);

  spdlog::info("Starting up circuitsolver server");

  Pistache::Address address(Pistache::Ipv4::any(), Pistache::Port(config.port));
  endpoint = new Pistache::Http::Endpoint(address);
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
