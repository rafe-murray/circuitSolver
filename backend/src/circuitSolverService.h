#include <pistache/endpoint.h>
#include <pistache/router.h>
#include <thread>

using Request = Pistache::Rest::Request;
using Response = Pistache::Http::ResponseWriter;
using Endpoint = Pistache::Http::Endpoint;
using Router = Pistache::Rest::Router;
class CircuitSolverService {
public:
  CircuitSolverService(
      unsigned port = 8000,
      unsigned numThreads = std::thread::hardware_concurrency())
      : port(port), numThreads(numThreads), address("localhost", port),
        endpoint(std::make_shared<Pistache::Http::Endpoint>(address)) {}

  void run();

private:
  void configureRoutes();

  void solveProtobuf(const Request &request, Response response);
  void solveJson(const Request &request, Response response);

  unsigned port;
  unsigned numThreads;
  Pistache::Address address;
  std::shared_ptr<Endpoint> endpoint;
  Router router;
};
