#pragma once

#include <pistache/endpoint.h>

#include "config/config.h"
namespace circuitsolver::server {

/// EndpointHandler manages the lifecycle of an endpoint
class EndpointHandler {
 public:
  /// init initializes an endpoint
  ///
  /// @param config the configuration to use for the endpoint
  static auto init(const config::Config& config) -> void;

  /// getEndpoint gets the managed endpoint
  ///
  /// @return a non-owning view of the managed endpoint
  static auto getEndpoint() -> Pistache::Http::Endpoint*;

  /// shutdown shuts down and cleans up the managed endpoint
  static auto shutdown() -> void;

 private:
  /// endpoint is the endpoint being managed
  static std::unique_ptr<Pistache::Http::Endpoint> endpoint;
};
}  // namespace circuitsolver::server
