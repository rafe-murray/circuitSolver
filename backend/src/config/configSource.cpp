#include "configSource.h"

#include <cctype>
#include <cstdlib>
#include <expected>
#include <format>
#include <string_view>

#include "error.h"

namespace circuitsolver::server::config {
ConfigKey::ConfigKey(std::string_view key) : key(key) {}
auto ConfigKey::name() -> std::string { return key; }

auto EnvConfigSource::get(std::string_view key)
    -> std::expected<std::string, ConfigError> {
  auto configKey = ConfigKey{key};
  auto name = envVarName(configKey);
  if (!name) {
    return std::unexpected(name.error());
  }
  auto* env = std::getenv(name.value().c_str());
  if (env != nullptr) {
    return std::string{env};
  }
  return std::unexpected<ConfigError>{{
      .type = ErrorType::NoSuchEnvironmentVariable,
  }};
}

auto EnvConfigSource::envVarName(ConfigKey key)
    -> std::expected<std::string, ConfigError> {
  auto original = key.name();
  auto env = original;
  for (size_t i = 0; i < original.size(); i++) {
    auto character = original.at(i);
    if (std::isalpha(character) != 0) {
      env.at(i) = static_cast<char>(std::toupper(character));
    } else if (character == '-') {
      env.at(i) = '_';
    } else {
      return std::unexpected<ConfigError>{
          {.type = ErrorType::InvalidKey,
           .error = std::format(
               "Invalid character {} at position {} of config key {}",
               character, i, original)}};
    }
  }
  return env;
}
}  // namespace circuitsolver::server::config
