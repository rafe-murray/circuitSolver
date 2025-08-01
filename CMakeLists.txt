cmake_minimum_required(VERSION 4.0)
project(circuitSolver)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
add_executable(solver src/main.cpp src/math/expression.cpp src/circuitGraph.cpp
                      src/components/edge.cpp)
include_directories(${PROJECT_SOURCE_DIR}/include)

# Add ceres
find_package(Ceres REQUIRED)
include_directories(${CERES_INCLUDE_DIRS})
find_library(CERES libceres.dylib)
target_link_libraries(solver ${CERES_LIBRARIES})

# Add RapidJSON
find_package(RapidJSON CONFIG REQUIRED)

# Add pistache
find_package(PkgConfig)
pkg_check_modules(Pistache REQUIRED IMPORTED_TARGET libpistache)
target_link_libraries(solver PkgConfig::Pistache)
# target_compile_options(solver PRIVATE -std=c++17 -c -g)
# target_compile_options(solver PRIVATE -std=c++17 -c -g -Wall -Wextra
# -pedantic) add_link_options(-std=c++17) add_link_options(-std=c++17 -lpthread
# -lm -lnlopt)

# GoogleTest requires at least C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG v1.17.0)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt
    ON
    CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# configuration for the tests
enable_testing()

add_executable(math_test test/math_test.cpp)
target_link_libraries(math_test GTest::gtest_main)

include(GoogleTest)
gtest_discover_tests(math_test)
