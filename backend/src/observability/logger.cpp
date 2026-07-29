#include "logger.h"

#include <opentelemetry/instrumentation/spdlog/sink.h>
#include <spdlog/common.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/spdlog.h>

#include <initializer_list>
#include <memory>

#include "../config/config.h"

namespace circuitsolver::server::observability::logger {

void init(const config::Config& config) {
  auto consoleSink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
  auto otelSink = std::make_shared<spdlog::sinks::opentelemetry_sink_mt>();

  spdlog::set_level(config.logLevel);
  auto logger = std::make_shared<spdlog::logger>(
      name, spdlog::sinks_init_list{consoleSink, otelSink});
  spdlog::set_default_logger(logger);
}

}  // namespace circuitsolver::server::observability::logger
