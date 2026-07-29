#pragma once

#include <pistache/router.h>

#include <memory>
#include <string>

#include "service.h"

namespace circuitsolver::server::services {
/// CircuitSolverService is a `Service` that can accept json- or
/// protobuf-encoded http requests and solve the associated circuits
class CircuitSolverService : public Service {
 public:
  /// Constructs a new CircuitSolverService
  /// @param router the router to bind the routes to
  explicit CircuitSolverService(
      const std::shared_ptr<Pistache::Rest::Router>& router);
  ~CircuitSolverService() override = default;
  void init() override;

  /// base is the base path that all `CircuitSolverService` routes are bound to.
  static const std::string base;

 private:
  /// configureRoutes binds the routes to the router
  void configureRoutes();

  /// solveProtobuf manages requests for protobuf-encoded circuits
  /// @param request the request to handle. Does not need to have been validated
  /// @param response the response to write back to
  void solveProtobuf(const Pistache::Rest::Request& request,
                     Pistache::Http::ResponseWriter response);

  /// solveJson manages requests for json-encoded circuits
  /// @param request the request to handle. Does not need to have been validated
  /// @param response the response to write back to
  void solveJson(const Pistache::Rest::Request& request,
                 Pistache::Http::ResponseWriter response);
};
}  // namespace circuitsolver::server::services
