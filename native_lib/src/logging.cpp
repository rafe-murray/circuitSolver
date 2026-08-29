#include <absl/base/log_severity.h>
#include <absl/log/log_sink.h>
#include <absl/log/log_sink_registry.h>
#include <circuit_solver/logging.h>
#include <glog/log_severity.h>
#include <glog/logging.h>
#include <spdlog/common.h>
#include <spdlog/spdlog.h>

namespace circuitsolver::logging {
GlogToSpdlogSink::GlogToSpdlogSink(std::shared_ptr<spdlog::logger> logger)
    : logger(std::move(logger)) {}
void GlogToSpdlogSink::send(google::LogSeverity severity,
                            const char* full_filename,
                            const char* /* base_filename */, int line,
                            const google::LogMessageTime& /* time */,
                            const char* message, size_t message_len) {
  std::string_view msg{message, message_len};
  spdlog::source_loc source{full_filename, line, "Function name not available"};
  spdlog::level::level_enum level{};
  switch (severity) {
    case google::GLOG_INFO:
      level = spdlog::level::info;
      break;
    case google::GLOG_WARNING:
      level = spdlog::level::warn;
      break;
    case google::GLOG_ERROR:
      level = spdlog::level::err;
      break;
    case google::GLOG_FATAL:
      level = spdlog::level::critical;
      break;
  }
  logger->log(source, level, msg);
};

AbseilToSpdlogSink::AbseilToSpdlogSink(std::shared_ptr<spdlog::logger> logger)
    : logger(std::move(logger)) {}
auto AbseilToSpdlogSink::Send(const absl::LogEntry& entry) -> void {
  std::string_view msg = entry.text_message();
  spdlog::source_loc source{std::string(entry.source_filename()).c_str(),
                            entry.source_line(), "Function name not available"};
  spdlog::level::level_enum level{};
  switch (entry.log_severity()) {
    case absl::LogSeverity::kInfo:
      level = spdlog::level::info;
      break;
    case absl::LogSeverity::kWarning:
      level = spdlog::level::warn;
      break;
    case absl::LogSeverity::kError:
      level = spdlog::level::err;
      break;
    case absl::LogSeverity::kFatal:
      level = spdlog::level::critical;
      break;
  }
  logger->log(source, level, msg);
}

LogSinkRegistrar::LogSinkRegistrar(const LogSinkLoggers& loggers)
    : glogSink(loggers.glog), abslSink(loggers.absl) {
  google::AddLogSink(&glogSink);
  absl::AddLogSink(&abslSink);
}

LogSinkRegistrar::~LogSinkRegistrar() {
  google::RemoveLogSink(&glogSink);
  absl::RemoveLogSink(&abslSink);
}

LogSinkLoggers::LogSinkLoggers(const Loggers& loggers)
    : absl(loggers.absl), glog(loggers.glog) {}

Logging::Logging(const Loggers& loggers)
    : registrar({LogSinkLoggers{loggers}}), logger(loggers.library) {}

}  // namespace circuitsolver::logging
