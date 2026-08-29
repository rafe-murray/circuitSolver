#pragma once
#include "../config/config.h"

namespace circuitsolver::server::observability::otel {

/// init initializes the OpenTelemetry SDK
///
/// @param config configuration for the service
void init(const config::Config& config);

/// initLogs initializes the logs
void initLogs();

/// initMetrics initializes metrics
void initMetrics();

/// initTraces initializes tracing
void initTraces();
}  // namespace circuitsolver::server::observability::otel
