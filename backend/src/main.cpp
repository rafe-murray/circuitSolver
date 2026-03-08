#include "circuitSolverService.h"
int main() {
  try {
    CircuitSolverService service(8000, 1);
    service.run();
  } catch (const std::exception &error) {
    std::cerr << error.what() << '\n';
    return 1;
  } catch (...) {
    return 1;
  }

  return 0;
}
