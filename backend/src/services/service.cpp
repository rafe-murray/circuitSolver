#include "service.h"

#include <pistache/router.h>

#include <memory>

namespace circuitsolver::server::services {

Service::Service(const std::shared_ptr<Pistache::Rest::Router>& router)
    : router(router) {}
void Service::handleException(
    const std::exception& exception,
    Pistache::Http::ResponseWriter& response) const noexcept {
  response.send(Pistache::Http::Code::Internal_Server_Error, exception.what());
}
}  // namespace circuitsolver::server::services
