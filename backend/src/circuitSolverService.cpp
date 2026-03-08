#include "circuitSolverService.h"
#include <circuit_solver/api.h>
#include <stdexcept>

void CircuitSolverService::configureRoutes() {
  Pistache::Rest::Routes::Post(
      router, "/solve",
      Pistache::Rest::Routes::bind(&CircuitSolverService::solveProtobuf, this));
  Pistache::Rest::Routes::Post(
      router, "/solve/json",
      Pistache::Rest::Routes::bind(&CircuitSolverService::solveJson, this));
}

void CircuitSolverService::solveProtobuf(const Request &request,
                                         Response response) {
  try {
    const std::string body = request.body();
    std::string output = solveGraphFromString(body);
    response.send(Pistache::Http::Code::Ok, output,
                  // Pistache doesn't support application/protobuf as a MIME
                  // type so we set it raw
                  Pistache::Http::Mime::MediaType(
                      "application/protobuf",
                      Pistache::Http::Mime::MediaType::DontParse));
    // TODO: figure out a good way to return a failure message
  } catch (const std::runtime_error &error) {
    response.send(Pistache::Http::Code::Not_Found, error.what(),
                  MIME(Text, Plain));
  } catch (const std::logic_error &error) {
    response.send(Pistache::Http::Code::Not_Found, error.what(),
                  MIME(Text, Plain));
  } catch (...) {
    response.send(Pistache::Http::Code::Internal_Server_Error, "Internal error",
                  MIME(Text, Plain));
  }
}

void CircuitSolverService::solveJson(const Request &request,
                                     Response response) {
  try {
    const std::string body = request.body();
    std::string output = solveGraphFromJson(body);
    response.send(Pistache::Http::Code::Ok, output, MIME(Application, Json));
  } catch (const std::runtime_error &error) {
    response.send(Pistache::Http::Code::Not_Found, error.what(),
                  MIME(Text, Plain));
  } catch (const std::logic_error &error) {
    response.send(Pistache::Http::Code::Not_Found, error.what(),
                  MIME(Text, Plain));
  } catch (...) {
    response.send(Pistache::Http::Code::Internal_Server_Error, "Internal error",
                  MIME(Text, Plain));
  }
}

void CircuitSolverService::run() {
  std::cout << "Starting on port " << port << " with " << numThreads
            << " threads.\n";
  endpoint->init(Pistache::Http::Endpoint::options().threads(numThreads));
  configureRoutes();
  endpoint->setHandler(router.handler());
  endpoint->serve();
}
