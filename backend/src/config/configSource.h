#pragma once

#include <expected>
#include <string>
#include <string_view>

#include "error.h"

namespace circuitsolver::server::config {

/// ConfigSource defines the interface that classes implement to provide
/// configuration info
class ConfigSource {
 public:
  /// get retrieves a value from this ConfigSource with the associated key
  ///
  /// @param key the key to look up
  /// @return the value retrieved, or a `ConfigError` if something went wrong
  /// @see ConfigError
  virtual std::expected<std::string, ConfigError> get(std::string_view key) = 0;
  virtual ~ConfigSource() = default;
};

/// ConfigKey enforces our canonical string representation of a given key
class ConfigKey {
 public:
  /// Constructs a new ConfigKey.
  ConfigKey(std::string_view key);
  /// name gets the canonical name of the ConfigKey
  std::string name();

 private:
  /// key is the actual string representation of the ConfigKey
  std::string key;
};

/// EnvConfigSource is a ConfigSource that reads from environment variables
class EnvConfigSource : public ConfigSource {
 public:
  /// Constructs a new EnvConfigSource, where `prefix` is prepended to each
  /// environment variable before fetching it
  EnvConfigSource(std::string_view prefix) : prefix(prefix) {}
  ~EnvConfigSource() override = default;
  /// prefix is the prefix to prepend to each environment variable name before
  /// fetching them
  std::string prefix = "";
  std::expected<std::string, ConfigError> get(std::string_view key) override;

 private:
  /// envVarName retrieves the name of an environment variable associated with
  /// the given key
  /// @param key the key to get the environment variable name for
  /// @return the associated environment variable name
  static std::expected<std::string, ConfigError> envVarName(ConfigKey key);
};

/// OptsConfigSource is a ConfigSource that reads from arguments passed on the
/// command line
class OptsConfigSource : public ConfigSource {
 public:
  ~OptsConfigSource() override = default;
  std::expected<std::string, ConfigError> get(std::string_view key) override;
};

}  // namespace circuitsolver::server::config
