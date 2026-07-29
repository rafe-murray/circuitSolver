#include "otel.h"

#include <opentelemetry/exporters/otlp/otlp_grpc_exporter_factory.h>
#include <opentelemetry/exporters/otlp/otlp_grpc_exporter_options.h>
#include <opentelemetry/exporters/otlp/otlp_grpc_log_record_exporter_factory.h>
#include <opentelemetry/exporters/otlp/otlp_grpc_log_record_exporter_options.h>
#include <opentelemetry/exporters/otlp/otlp_grpc_metric_exporter_factory.h>
#include <opentelemetry/exporters/otlp/otlp_grpc_metric_exporter_options.h>
#include <opentelemetry/logs/provider.h>
#include <opentelemetry/metrics/provider.h>
#include <opentelemetry/sdk/logs/logger_provider_factory.h>
#include <opentelemetry/sdk/logs/processor.h>
#include <opentelemetry/sdk/logs/simple_log_record_processor_factory.h>
#include <opentelemetry/sdk/metrics/aggregation/default_aggregation.h>
#include <opentelemetry/sdk/metrics/export/periodic_exporting_metric_reader.h>
#include <opentelemetry/sdk/metrics/export/periodic_exporting_metric_reader_factory.h>
#include <opentelemetry/sdk/metrics/meter_context_factory.h>
#include <opentelemetry/sdk/metrics/meter_provider.h>
#include <opentelemetry/sdk/metrics/meter_provider_factory.h>
#include <opentelemetry/sdk/trace/batch_span_processor_factory.h>
#include <opentelemetry/sdk/trace/batch_span_processor_options.h>
#include <opentelemetry/sdk/trace/processor.h>
#include <opentelemetry/sdk/trace/tracer_provider.h>
#include <opentelemetry/sdk/trace/tracer_provider_factory.h>
#include <opentelemetry/trace/provider.h>
#include <spdlog/common.h>

#include "../config/config.h"

namespace otlp = opentelemetry::exporter::otlp;
namespace logs_api = opentelemetry::logs;
namespace logs_sdk = opentelemetry::sdk::logs;
namespace metric_sdk = opentelemetry::sdk::metrics;
namespace metrics_api = opentelemetry::metrics;
namespace trace_api = opentelemetry::trace;
namespace trace_sdk = opentelemetry::sdk::trace;

namespace circuitsolver::server::observability::otel {
void init(const config::Config& config) {
  if (config.logLevel != spdlog::level::off) {
    initLogs();
  }
  initMetrics();
  initTraces();
}

void initLogs() {
  // Use default options (reads from environment variables)
  // TODO: if we want to support a config file add support for that here
  otlp::OtlpGrpcLogRecordExporterOptions opts{};
  auto exporter = otlp::OtlpGrpcLogRecordExporterFactory::Create(opts);
  auto processor =
      logs_sdk::SimpleLogRecordProcessorFactory::Create(std::move(exporter));

  std::shared_ptr<logs_api::LoggerProvider> provider(
      logs_sdk::LoggerProviderFactory::Create(std::move(processor)));

  logs_api::Provider::SetLoggerProvider(provider);
}

void initMetrics() {
  // TODO: see above
  otlp::OtlpGrpcMetricExporterOptions opts;
  auto exporter = otlp::OtlpGrpcMetricExporterFactory::Create(opts);
  metric_sdk::PeriodicExportingMetricReaderOptions reader_options{};
  auto reader = metric_sdk::PeriodicExportingMetricReaderFactory::Create(
      std::move(exporter), reader_options);
  auto context = metric_sdk::MeterContextFactory::Create();
  context->AddMetricReader(std::move(reader));
  auto u_provider =
      metric_sdk::MeterProviderFactory::Create(std::move(context));
  std::shared_ptr<opentelemetry::metrics::MeterProvider> provider(
      std::move(u_provider));
  metrics_api::Provider::SetMeterProvider(provider);
}

void initTraces() {
  // TODO: see above
  trace_sdk::BatchSpanProcessorOptions bspOpts{};
  opentelemetry::exporter::otlp::OtlpGrpcExporterOptions opts;
  auto exporter = otlp::OtlpGrpcExporterFactory::Create(opts);
  auto processor = trace_sdk::BatchSpanProcessorFactory::Create(
      std::move(exporter), bspOpts);
  std::shared_ptr<trace_api::TracerProvider> provider =
      trace_sdk::TracerProviderFactory::Create(std::move(processor));
  // Set the global trace provider
  trace_api::Provider::SetTracerProvider(provider);
}
}  // namespace circuitsolver::server::observability::otel
