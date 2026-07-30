cmake_minimum_required(VERSION 3.16)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # For clangd support
set(CIRCUITSOLVER_BUILD_TESTS OFF)
set(BUILD_SHARED_LIBS
    OFF
    CACHE BOOL "Build all libraries as static" FORCE)

add_compile_options(-Wall -Wextra -Wpedantic -Wconversion -Wno-sign-conversion
  -Wno-missing-field-initializers
  # abseil generates a lot of warnings with nullability extensions but it is
  # fine as they are gated behind compiler-specific macros
  -Wno-nullability-extension
)

project(circuitSolverApp)
set(PKG_CONFIG_ARGN "--static" CACHE STRING "Import static PkgConfig libraries")
find_package(PkgConfig)
pkg_check_modules(Pistache REQUIRED IMPORTED_TARGET libpistache)

find_package(opentelemetry-cpp CONFIG REQUIRED)
find_package(spdlog REQUIRED)
find_package(opentelemetry_spdlog_sink REQUIRED)

# build dir is relative to the build dir of this target
add_subdirectory(../native_lib ../../native_lib/build)
add_executable(circuit-solver
  src/config/config.cpp
  src/config/configManager.cpp
  src/config/configSource.cpp
  src/main.cpp
  src/observability/logger.cpp
  src/observability/otel.cpp
  src/services/circuitSolverService.cpp
  src/services/service.cpp
)
target_include_directories(circuit-solver PRIVATE ../native_lib/build)
target_link_libraries(circuit-solver PRIVATE
  PkgConfig::Pistache
  circuitSolverLib
  opentelemetry-cpp::api
  opentelemetry-cpp::ext
  opentelemetry-cpp::logs
  opentelemetry-cpp::otlp_grpc_client
  opentelemetry-cpp::otlp_grpc_exporter
  opentelemetry-cpp::otlp_grpc_log_record_exporter
  opentelemetry-cpp::otlp_grpc_metrics_exporter
  opentelemetry-cpp::proto_grpc
  opentelemetry-cpp::sdk
  opentelemetry-cpp::trace
  opentelemetry_spdlog_sink::opentelemetry_spdlog_sink
  spdlog::spdlog
)
