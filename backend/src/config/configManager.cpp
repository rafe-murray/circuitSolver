#include "configManager.h"

namespace circuitsolver::server::config {
ConfigManager& ConfigManager::addSource(std::shared_ptr<ConfigSource> source) {
  sources.push_back(std::move(source));
  return *this;
}
}  // namespace circuitsolver::server::config
