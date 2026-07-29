#pragma once

#include <string>

namespace circuitsolver::server::config {
/// ErrorType is the type of config error that occurred
enum class ErrorType {
  /// InvalidKey indicates that the desired key was malformed
  InvalidKey,
  /// NoSuchEnvironmentVariable indicates that an environment variable with a
  /// matching name (after normalization) was not found
  NoSuchEnvironmentVariable,
};

/// ConfigError is used to indicate an error occurred while reading config
struct ConfigError {
  /// type is the type of error
  ErrorType type;
  /// error is the error message
  std::string error;
};

}  // namespace circuitsolver::server::config
