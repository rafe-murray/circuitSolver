cmake_minimum_required(VERSION 3.16)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # For clangd support

# This needs to be before the call to project() so vcpkg can include the correct manifests
option(CIRCUITSOLVER_BUILD_TESTS "Compile a test executable" OFF)
if (CIRCUITSOLVER_BUILD_TESTS)
  list(APPEND VCPKG_MANIFEST_FEATURES "test")
endif()
option(CIRCUITSOLVER_TEST_COVERAGE "Build targets with coverage included" OFF)
project(circuitsolver)

# Build and link to static libraries only
# set(BUILD_SHARED_LIBS
#     OFF
#     CACHE BOOL "Build all libraries as static" FORCE)

add_compile_options(
  -Wall
  -Wextra
  -Wpedantic
  -Wconversion
  -Wno-sign-conversion
  -Wno-missing-field-initializers
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
  add_compile_options(
      # abseil generates a lot of warnings with nullability extensions but it is
      # fine as they are gated behind compiler-specific macros
      -Wno-nullability-extension
  )
endif()

if(CIRCUITSOLVER_TEST_COVERAGE)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # Flags specific to GCC
    add_compile_options(--coverage)
    add_link_options(--coverage)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    # Flags specific to Clang or Apple Clang
    add_compile_options(
      -fprofile-instr-generate
      -fcoverage-mapping
      -fcoverage-compilation-dir=native_lib/..
      -fcoverage-prefix-map=${CMAKE_CURRENT_SOURCE_DIR}=./circuitsolver/native_lib
    )
    add_link_options(
      -fprofile-instr-generate
      -fcoverage-mapping
      -fcoverage-compilation-dir=native_lib/..
      -fcoverage-prefix-map=${CMAKE_CURRENT_SOURCE_DIR}=./circuitsolver/native_lib
    )
  endif()
endif()

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
    src/errors.cpp
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
target_link_libraries(circuitsolver PRIVATE Ceres::ceres)

target_link_libraries(circuitsolver PUBLIC
  protobuf::libprotobuf
  absl::log
  glog::glog
  spdlog::spdlog
  stduuid
)

target_compile_definitions(circuitsolver PRIVATE
    $<$<CONFIG:Debug>:SPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_DEBUG>
    $<$<NOT:$<CONFIG:Debug>>:SPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_INFO>
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
  find_package(GTest CONFIG REQUIRED)

  # configuration for the tests
  enable_testing()
  add_executable(circuitsolverTests
    test/cApi.cpp
    test/circuit.cpp
    test/cppApi.cpp
    test/math.cpp
    test/utils.cpp
  )
  target_compile_definitions(circuitsolverTests PRIVATE
      $<$<CONFIG:Debug>:SPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_DEBUG>
      $<$<NOT:$<CONFIG:Debug>>:SPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_INFO>
  )
  find_program(GCOV NAMES gcov)
  set(CTEST_COVERAGE_COMMAND "${GCOV}")

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
