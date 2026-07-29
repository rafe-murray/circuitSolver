#pragma once

#include <charconv>
#include <concepts>
#include <memory>
#include <optional>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

#include "configSource.h"
#include "error.h"

namespace circuitsolver::server::config {

/// Numeric is a numeric type
template <typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

/// ConfigManager manages getting and merging config values from multiple
/// sources
/// @see ConfigSource
class ConfigManager {
 public:
  // TODO: maybe add support for setting config from filesystem

  /// addSource adds a source to this ConfigManager
  ///
  /// Config retrieved by this ConfigManager will be merged so that earlier
  /// source have higher precedence; i.e., when looking up a key, if it is found
  /// in a source that was added previously, that value will be used, even if
  /// the key exists in other sources.
  /// @param source the source to add
  /// @return this
  auto addSource(std::shared_ptr<ConfigSource> source) -> ConfigManager&;

  /// get retrieves a value from the ConfigManager
  ///
  /// @param key the key for the config to retrieve. This value will be
  /// normalized before lookup
  /// @tparam T the type of the value to retrieve. This type will be constructed
  /// from a `std::string`
  /// @return an optional value that is present if the key was found, or
  /// `std::nullopt` if not
  template <std::constructible_from<std::string> T>
  auto get(std::string_view key) -> std::optional<T> {
    for (const auto& source : sources) {
      auto maybe_value = source->get(key);
      if (maybe_value) {
        return T(maybe_value.value());
      }
      if (maybe_value.error().type == ErrorType::InvalidKey) {
        throw std::invalid_argument{maybe_value.error().error};
      }
    }
    return std::nullopt;
  }

  /// get retrieves a value from the ConfigManager
  ///
  /// @param key the key for the config to retrieve. This value will be
  /// normalized before lookup
  /// @tparam T the type of the value to retrieve. This value will be
  /// constructed using `std::from_chars`
  /// @return an optional value that is present if the key was found, or
  /// `std::nullopt` if not
  /// @see std::from_chars()
  template <Numeric T>
  auto get(std::string_view key) -> std::optional<T> {
    for (const auto& source : sources) {
      auto maybe_value = source->get(key);
      if (maybe_value) {
        T val;
        auto [ptr, ec] = std::from_chars(key.begin(), key.end(), val);
        if (ptr == key.end() && ec == std::errc{}) {
          return val;
        }
      } else {
        // TODO: can this be checked at compile time?
        if (maybe_value.error().type == ErrorType::InvalidKey) {
          throw std::invalid_argument{maybe_value.error().error};
        }
      }
    }
    return std::nullopt;
  }

 private:
  /// sources is the list of sources this ConfigManager manages
  std::vector<std::shared_ptr<ConfigSource>> sources;
};
}  // namespace circuitsolver::server::config
