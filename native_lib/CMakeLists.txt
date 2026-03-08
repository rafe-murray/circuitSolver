cmake_minimum_required(VERSION 3.16)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # For clangd support

project(circuitSolverLib)

option(CIRCUITSOLVER_BUILD_TESTS "Compile a test executable" ON)

# Build and link to static libraries only
set(BUILD_SHARED_LIBS
    OFF
    CACHE BOOL "Build all libraries as static" FORCE)

add_compile_options(-Wall -Wextra -Wpedantic -Wconversion -Wno-sign-conversion
                    -Wno-missing-field-initializers)

# Add the source code as a library so it is exposed to both main executable and
# tests
add_library(circuitSolverLib STATIC)
target_sources(
  circuitSolverLib
  PRIVATE src/circuitGraph.cpp src/expression.cpp src/expressionNode.cpp
          src/branch.cpp src/edge.cpp
          ./circuit_solver/v1/circuit_graph_message.proto)
target_include_directories(circuitSolverLib PUBLIC include)

include(FetchContent)

# We don't need to build ceres' tests
set(BUILD_TESTING
    OFF
    CACHE BOOL "" FORCE)
set(BUILD_EXAMPLES
    OFF
    CACHE BOOL "" FORCE)
set(BUILD_BENCHMARKS
    OFF
    CACHE BOOL "" FORCE)

# Disable protobuf's tests too
set(protobuf_BUILD_TESTS
    OFF
    CACHE BOOL "" FORCE)
set(protobuf_BUILD_EXAMPLES
    OFF
    CACHE BOOL "" FORCE)

find_package(Ceres CONFIG)
if(NOT Ceres_FOUND)
  message("Ceres not found. Downloading from source...")
  FetchContent_Declare(
    ceres_solver
    GIT_REPOSITORY https://github.com/ceres-solver/ceres-solver.git
    GIT_TAG f9b7b6651b108136a16df44d91fb31735645f5a7 # Eigen 5 support
    GIT_SHALLOW OFF)
  FetchContent_MakeAvailable(ceres_solver)
  if(NOT TARGET Ceres::ceres)
    add_library(Ceres::ceres ALIAS ceres)
  endif()
endif()

find_package(Protobuf CONFIG)

if(NOT Protobuf_FOUND)
  message("Protobuf not found. Downloading from source...")
  FetchContent_Declare(
    protobuf
    GIT_REPOSITORY https://github.com/protocolbuffers/protobuf.git
    GIT_TAG v33.2
    GIT_SHALLOW true)

  FetchContent_MakeAvailable(protobuf)
  # include the cmake definition for protobuf_generate()
  FetchContent_GetProperties(protobuf SOURCE_DIR PROTOBUF_SOURCE_DIR)
  include(${PROTOBUF_SOURCE_DIR}/cmake/protobuf-generate.cmake)
endif()

# Generate protobuf code
protobuf_generate(TARGET circuitSolverLib)

# generated protobuf headers will be in current (build) directory
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)

FetchContent_Declare(
  stduuid
  GIT_REPOSITORY https://github.com/mariusbancila/stduuid.git
  GIT_TAG v1.2.3)

FetchContent_MakeAvailable(stduuid)

target_link_libraries(circuitSolverLib PUBLIC protobuf::libprotobuf stduuid
                                              Ceres::ceres)

if(CIRCUITSOLVER_BUILD_TESTS)
  FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.17.0
    GIT_SHALLOW true)
  # For Windows: Prevent overriding the parent project's compiler/linker
  # settings
  set(gtest_force_shared_crt
      ON
      CACHE BOOL "" FORCE)
  FetchContent_MakeAvailable(googletest)

  # configuration for the tests
  enable_testing()

  add_executable(circuitSolverLibTests test/math.cpp test/circuit.cpp
                                       test/utils.cpp)
  target_link_libraries(circuitSolverLibTests PRIVATE GTest::gtest_main
                                                      circuitSolverLib)

  # Add a compiler macro for test data file directory
  set(TEST_DATA_DIR "${CMAKE_SOURCE_DIR}/test/data")
  target_compile_definitions(circuitSolverLibTests
                             PRIVATE TEST_DATA_DIR="${TEST_DATA_DIR}")
  include(GoogleTest)
  gtest_discover_tests(circuitSolverLibTests)
endif()
