#pragma once

#include <pistache/router.h>

#include <memory>

namespace circuitsolver::server::services {
/// Service is a base class for all services. It provides utility functions and
/// an interface to implement, but should not be used on its own
class Service {
 public:
  /// Constructs a new `Service`
  /// @param router the router for the `Service`
  explicit Service(const std::shared_ptr<Pistache::Rest::Router>& router);
  virtual ~Service() = default;

  /// Initialize the service. Implementing classes should do all of their
  /// routing logic here
  virtual void init() = 0;

  /// handleException is provided as a default way to handle exceptions thrown
  /// by services. It sends a 500 error with `exception.what()` as a body in
  /// `response`
  /// @param exception the exception to handle
  /// @param response the response to write back to
  virtual void handleException(
      const std::exception& exception,
      Pistache::Http::ResponseWriter& response) const noexcept;

 protected:
  /// router is the router for this `Service`
  const std::shared_ptr<Pistache::Rest::Router> router;
};

}  // namespace circuitsolver::server::services
