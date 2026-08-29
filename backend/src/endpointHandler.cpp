#include "endpointHandler.h"

#include <pistache/endpoint.h>

namespace circuitsolver::server {
auto EndpointHandler::init(const config::Config& config) -> void {
  Pistache::Address address(Pistache::Ipv4::any(), Pistache::Port(config.port));
  endpoint = std::make_unique<Pistache::Http::Endpoint>(address);
}
auto EndpointHandler::getEndpoint() -> Pistache::Http::Endpoint* {
  return endpoint.get();
}

auto EndpointHandler::shutdown() -> void {
  if (endpoint != nullptr) {
    endpoint->shutdown();
  }
  // This will probably only be called once, but in case it gets called
  // multiple times
  endpoint = nullptr;
}

}  // namespace circuitsolver::server
