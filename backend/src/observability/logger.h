#pragma once

#include <circuit_solver/logging.h>

#include "../config/config.h"

namespace circuitsolver::server::observability::logger {

using config::Config;
class Logging {
 public:
  explicit Logging(const Config& config);

  circuitsolver::logging::Logging logging;
  static const std::string appLoggerName;
  static const std::string libraryLoggerName;
  static const std::string abslLoggerName;
  static const std::string glogLoggerName;
};
/// name is the name of the global logger
inline const std::string name = "CircuitSolverLogger";
}  // namespace circuitsolver::server::observability::logger
