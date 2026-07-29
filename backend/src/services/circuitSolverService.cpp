#include "circuitSolverService.h"

#include <pistache/http_defs.h>

// We undefine unreachable here to fix abseil macro collisions downstream
#ifdef unreachable
#undef unreachable
#endif

#include <circuit_solver/api.h>

#include <memory>
#include <string>

#include "service.h"

namespace circuitsolver::server::services {

CircuitSolverService::CircuitSolverService(
    const std::shared_ptr<Pistache::Rest::Router>& router)
    : Service(router) {}

void CircuitSolverService::init() { configureRoutes(); }

void CircuitSolverService::configureRoutes() {
  using namespace Pistache::Rest;
  // TODO: should we remove this route in favour of supporting gRPC directly?
  Routes::Post(*getRouter(), base + "/solve",
               Routes::bind(&CircuitSolverService::solveProtobuf, this));
  Routes::Post(*getRouter(), base + "/solve/json",
               Routes::bind(&CircuitSolverService::solveJson, this));
}

void CircuitSolverService::solveProtobuf(
    const Pistache::Rest::Request& request,
    Pistache::Http::ResponseWriter response) {
  try {
    const std::string& body = request.body();
    auto maybeOutput = solveGraphFromString(body);
    if (maybeOutput) {
      const auto& output = maybeOutput.value();
      response.send(Pistache::Http::Code::Ok, output,
                    // Pistache doesn't support application/protobuf as a MIME
                    // type so we set it raw
                    // TODO: extract to a constant
                    Pistache::Http::Mime::MediaType(
                        "application/protobuf",
                        Pistache::Http::Mime::MediaType::DontParse));
    } else {
      const auto& error = maybeOutput.error();
      switch (error.type()) {
        case ErrorType::InvalidInput:
          response.send(Pistache::Http::Code::Bad_Request, error.message());
          break;
        case ErrorType::NoSolution:
          response.send(Pistache::Http::Code::Unprocessable_Entity,
                        error.message());
          break;
        case ErrorType::FailedSerialization:
        default:
          response.send(Pistache::Http::Code::Internal_Server_Error,
                        error.message());
      }
    }
  } catch (Pistache::Http::HttpError& e) {
    response.send(static_cast<Pistache::Http::Code>(e.code()), e.what());
  } catch (const std::exception& e) {
    handleException(e, response);
  }
}

void CircuitSolverService::solveJson(const Pistache::Rest::Request& request,
                                     Pistache::Http::ResponseWriter response) {
  try {
    const std::string& body = request.body();
    auto maybeOutput = solveGraphFromJson(body);
    if (maybeOutput) {
      const auto& output = maybeOutput.value();
      response.send(Pistache::Http::Code::Ok, output, MIME(Application, Json));
    } else {
      const auto& error = maybeOutput.error();
      switch (error.type()) {
        case ErrorType::InvalidInput:
          response.send(Pistache::Http::Code::Bad_Request, error.message());
          break;
        case ErrorType::NoSolution:
          response.send(Pistache::Http::Code::Unprocessable_Entity,
                        error.message());
          break;
        case ErrorType::FailedSerialization:
        default:
          response.send(Pistache::Http::Code::Internal_Server_Error,
                        error.message());
      }
    }
  } catch (Pistache::Http::HttpError& e) {
    response.send(static_cast<Pistache::Http::Code>(e.code()), e.what());
  } catch (const std::exception& e) {
    handleException(e, response);
  }
}
}  // namespace circuitsolver::server::services
