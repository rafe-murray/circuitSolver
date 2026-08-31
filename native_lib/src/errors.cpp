#include "circuit_solver/errors.h"

#include <string>
#include <string_view>

namespace circuitsolver {
CircuitSolverError::CircuitSolverError(ErrorType type, std::string_view message)
    : _type(type), _message(message) {}

auto CircuitSolverError::message() const -> std::string { return _message; }
auto CircuitSolverError::type() const -> ErrorType { return _type; }
}  // namespace circuitsolver
