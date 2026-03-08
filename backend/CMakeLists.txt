cmake_minimum_required(VERSION 3.16)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # For clangd support
set(CIRCUITSOLVER_BUILD_TESTS OFF)
set(BUILD_SHARED_LIBS
    OFF
    CACHE BOOL "Build all libraries as static" FORCE)

project(circuitSolverApp)
find_package(PkgConfig)
pkg_check_modules(Pistache REQUIRED IMPORTED_TARGET libpistache)

# build dir is relative to the build dir of this target
add_subdirectory(../native_lib ../../native_lib/build)
add_executable(circuit-solver src/main.cpp)
target_link_libraries(circuit-solver PRIVATE circuitSolverLib)
