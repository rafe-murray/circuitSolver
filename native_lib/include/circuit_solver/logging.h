#pragma once

#include <absl/base/log_severity.h>
#include <absl/log/log_sink.h>
#include <absl/log/log_sink_registry.h>
#include <glog/log_severity.h>
#include <glog/logging.h>
#include <spdlog/common.h>
#include <spdlog/logger.h>
#include <spdlog/spdlog.h>

#include <memory>
namespace circuitsolver::logging {

class GlogToSpdlogSink : public google::LogSink {
 public:
  GlogToSpdlogSink(std::shared_ptr<spdlog::logger> logger);
  auto send(google::LogSeverity severity, const char* full_filename,
            const char* /* base_filename */, int line,
            const google::LogMessageTime& /* time */, const char* message,
            size_t message_len) -> void override;

 private:
  std::shared_ptr<spdlog::logger> logger;
};

class AbseilToSpdlogSink : public absl::LogSink {
 public:
  AbseilToSpdlogSink(std::shared_ptr<spdlog::logger> logger);
  auto Send(const absl::LogEntry& entry) -> void override;

 private:
  std::shared_ptr<spdlog::logger> logger;
};

struct Loggers {
  std::shared_ptr<spdlog::logger> library = spdlog::default_logger();
  std::shared_ptr<spdlog::logger> absl = spdlog::default_logger();
  std::shared_ptr<spdlog::logger> glog = spdlog::default_logger();
};

struct LogSinkLoggers {
  LogSinkLoggers() = default;
  explicit LogSinkLoggers(const Loggers& loggers);
  std::shared_ptr<spdlog::logger> absl = spdlog::default_logger();
  std::shared_ptr<spdlog::logger> glog = spdlog::default_logger();
};

class LogSinkRegistrar {
 public:
  explicit LogSinkRegistrar(const LogSinkLoggers& loggers = {});
  LogSinkRegistrar(const LogSinkRegistrar& other) = delete;
  auto operator=(const LogSinkRegistrar& other) -> LogSinkRegistrar& = delete;
  LogSinkRegistrar(LogSinkRegistrar&& other) = default;
  auto operator=(LogSinkRegistrar&& other) -> LogSinkRegistrar& = default;
  ~LogSinkRegistrar();

 private:
  GlogToSpdlogSink glogSink;
  AbseilToSpdlogSink abslSink;
};

class Logging {
 public:
  [[nodiscard]] explicit Logging(const Loggers& loggers = {});
  static auto getLogger() -> std::shared_ptr<spdlog::logger>;

 private:
  LogSinkRegistrar registrar;
  std::shared_ptr<spdlog::logger> logger;
};

inline auto logger() -> std::shared_ptr<spdlog::logger> {
  auto logger = Logging::getLogger();
  if (logger != nullptr) {
    return logger;
  }
  return spdlog::default_logger();
}

}  // namespace circuitsolver::logging
