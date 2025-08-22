cmake_minimum_required(VERSION 4.0)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # For clangd support

project(circuitSolver)

# TODO: change default when ready for release
option(COMPILE_TESTS "Compile a test executable" ON)

# Add the source code as a library so it is exposed to both main executable and
# tests
add_library(circuitSolver STATIC)
target_sources(
  circuitSolver
  PRIVATE src/circuitGraph.cpp src/expression.cpp src/expressionNode.cpp
          src/branch.cpp src/edge.cpp circuitGraphMessage.proto)

# target_include_directories(circuitSolver PUBLIC ${PROJECT_SOURCE_DIR}/include)

# Add external libraries
find_package(Ceres REQUIRED)

find_package(RapidJSON CONFIG REQUIRED)

# find_package(PkgConfig) pkg_check_modules(Pistache REQUIRED IMPORTED_TARGET
# libpistache)

find_package(Protobuf CONFIG REQUIRED)

# Generate protobuf code
if(Protobuf_FOUND)
  protobuf_generate(TARGET circuitSolver)
endif()

# generated protobuf headers will be in current (build) directory
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)
# PkgConfig::Pistache
target_link_libraries(circuitSolver PUBLIC Ceres::ceres protobuf::libprotobuf)

# Compile the main executable
add_executable(solver src/main.cpp)
target_link_libraries(solver PRIVATE circuitSolver)

if(COMPILE_TESTS)
  include(FetchContent)
  FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.17.0)
  # For Windows: Prevent overriding the parent project's compiler/linker
  # settings
  set(gtest_force_shared_crt
      ON
      CACHE BOOL "" FORCE)
  FetchContent_MakeAvailable(googletest)

  # configuration for the tests
  enable_testing()

  add_executable(circuitSolverTests test/math.cpp test/circuit.cpp
                                    test/utils.cpp)
  target_link_libraries(circuitSolverTests GTest::gtest_main circuitSolver)

  include(GoogleTest)
  gtest_discover_tests(circuitSolverTests)
endif()
