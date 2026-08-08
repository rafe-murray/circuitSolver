#include "logger.h"

#include <circuit_solver/logging.h>
#include <opentelemetry/instrumentation/spdlog/sink.h>
#include <spdlog/common.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/spdlog.h>

#include <initializer_list>
#include <memory>

#include "../config/config.h"

namespace circuitsolver::server::observability::logger {
using config::Config;

Logging::Logging(const Config& config) {
  auto consoleSink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
  auto otelSink = std::make_shared<spdlog::sinks::opentelemetry_sink_mt>();

  spdlog::set_level(config.logLevel);
  auto sinks = spdlog::sinks_init_list{consoleSink, otelSink};
  auto libraryLogger =
      std::make_shared<spdlog::logger>(libraryLoggerName, sinks);
  auto abslLogger = std::make_shared<spdlog::logger>(abslLoggerName, sinks);
  auto glogLogger = std::make_shared<spdlog::logger>(glogLoggerName, sinks);
  auto appLogger = std::make_shared<spdlog::logger>(appLoggerName, sinks);
  logging = circuitsolver::logging::Logging{
      {.library = libraryLogger, .absl = abslLogger, .glog = glogLogger}};
  spdlog::set_default_logger(appLogger);
}

const std::string Logging::libraryLoggerName = "circuitsolver.library";
const std::string Logging::abslLoggerName = "circuitsolver.library.absl";
const std::string Logging::glogLoggerName = "circuitsolver.library.glog";
const std::string Logging::appLoggerName = "circuitsolver.app";

}  // namespace circuitsolver::server::observability::logger
