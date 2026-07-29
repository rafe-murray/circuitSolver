#pragma once

#include "../config/config.h"

namespace circuitsolver::server::observability::logger {

/// name is the name of the global logger
inline constexpr std::string name = "CircuitSolverLogger";

/// init initializes the logger
void init(const config::Config& config);
}  // namespace circuitsolver::server::observability::logger
