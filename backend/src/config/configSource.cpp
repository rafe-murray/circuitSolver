#include "configSource.h"

#include <cctype>
#include <cstdlib>
#include <expected>
#include <format>
#include <string_view>

#include "error.h"

namespace circuitsolver::server::config {
ConfigKey::ConfigKey(std::string_view key) : key(key) {}
std::string ConfigKey::name() { return key; }

std::expected<std::string, ConfigError> EnvConfigSource::get(
    std::string_view key) {
  auto configKey = ConfigKey{key};
  auto name = envVarName(configKey);
  if (!name) {
    return std::unexpected(name.error());
  }
  auto env = std::getenv(name.value().c_str());
  if (env != nullptr) {
    return std::string{env};
  } else {
    return std::unexpected<ConfigError>{{
        ErrorType::NoSuchEnvironmentVariable,
    }};
  }
}

std::expected<std::string, ConfigError> EnvConfigSource::envVarName(
    ConfigKey key) {
  auto original = key.name();
  auto env = original;
  for (size_t i = 0; i < original.size(); i++) {
    auto c = original[i];
    if (std::isalpha(c)) {
      env[i] = static_cast<char>(std::toupper(c));
    } else if (c == '-') {
      env[i] = '_';
    } else {
      return std::unexpected<ConfigError>{
          {ErrorType::InvalidKey,
           std::format("Invalid character {} at position {} of config key {}",
                       c, i, original)}};
    }
  }
  return env;
}
}  // namespace circuitsolver::server::config
