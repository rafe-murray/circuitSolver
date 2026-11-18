#include "circuit_solver/errors.h"

#include <string>
#include <string_view>

namespace circuitsolver::errors {
Error::Error(ErrorType type, std::string_view message)
    : _type(type), _message(message) {}

auto Error::message() const -> std::string { return _message; }
auto Error::type() const -> ErrorType { return _type; }
}  // namespace circuitsolver::errors
