cmake_minimum_required(VERSION 3.16)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # For clangd support

project(circuitsolver)

option(CIRCUITSOLVER_BUILD_TESTS "Compile a test executable" OFF)

# Build and link to static libraries only
# set(BUILD_SHARED_LIBS
#     OFF
#     CACHE BOOL "Build all libraries as static" FORCE)

add_compile_options(-Wall -Wextra -Wpedantic -Wconversion -Wno-sign-conversion
  -Wno-missing-field-initializers
  # abseil generates a lot of warnings with nullability extensions but it is
  # fine as they are gated behind compiler-specific macros
  -Wno-nullability-extension)

# Add the source code as a library so it is exposed to both main executable and
# tests
add_library(circuitsolver)
target_sources(
  circuitsolver
  PRIVATE
    src/api.cpp
    src/branch.cpp
    src/circuitGraph.cpp
    src/edge.cpp
    src/expression.cpp
    src/expressionNode.cpp
    src/logging.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../proto/circuit_solver/v1alpha1/circuit_graph_message.proto
)
target_include_directories(circuitsolver PUBLIC include)

include(FetchContent)

find_package(Ceres CONFIG REQUIRED)
find_package(Protobuf CONFIG REQUIRED)
find_package(stduuid CONFIG REQUIRED)
find_package(glog CONFIG REQUIRED)
find_package(absl CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

# Generate protobuf code
protobuf_generate(
  TARGET circuitsolver
  IMPORT_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/../proto)

# install(FILES "${CMAKE_CURRENT_BINARY_DIR}/circuit_solver/v1alpha1/circuit_graph_message.pb.h"
#   DESTINATION include
# )

# generated protobuf headers will be in current (build) directory
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)

# TODO: make some headers private
target_link_libraries(circuitsolver PRIVATE stduuid Ceres::ceres)

target_link_libraries(circuitsolver PUBLIC
  protobuf::libprotobuf
  absl::log
  glog::glog
  spdlog::spdlog
)

install(TARGETS circuitsolver
    ARCHIVE DESTINATION lib    # For static libraries (.a, .lib)
    LIBRARY DESTINATION lib    # For shared libraries (.so, .dylib)
    RUNTIME DESTINATION bin    # For DLLs on Windows (.dll)
)

install(DIRECTORY include DESTINATION include)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/circuit_solver/v1alpha1/circuit_graph_message.pb.h" DESTINATION include)

# Compile the main executable add_executable(solver src/main.cpp)
# target_link_libraries(solver PRIVATE circuitsolver)

if(CIRCUITSOLVER_BUILD_TESTS)
  find_package(gtest CONFIG REQUIRED)

  # configuration for the tests
  enable_testing()

  add_executable(circuitsolverTests test/math.cpp test/circuit.cpp
                                       test/utils.cpp)
  target_link_libraries(circuitsolverTests PRIVATE GTest::gtest_main
                                                      circuitsolver
                                                      Ceres::ceres
                                                    )

  # Add a compiler macro for test data file directory
  set(TEST_DATA_DIR "${CMAKE_SOURCE_DIR}/test/data")
  target_compile_definitions(circuitsolverTests
                             PRIVATE TEST_DATA_DIR="${TEST_DATA_DIR}")
  include(GoogleTest)
  gtest_discover_tests(circuitsolverTests)
endif()
