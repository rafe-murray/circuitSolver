#include "configManager.h"

namespace circuitsolver::server::config {
auto ConfigManager::addSource(std::shared_ptr<ConfigSource> source)
    -> ConfigManager& {
  sources.push_back(std::move(source));
  return *this;
}
}  // namespace circuitsolver::server::config
