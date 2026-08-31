#ifndef TEST_UTILS_H
#define TEST_UTILS_H
#include <gtest/gtest.h>
#include <stduuid/uuid.h>

#include "circuit_solver/proto.h"

// Backup for if this is not defined in the cmake file
#ifndef TEST_DATA_DIR
#define TEST_DATA_DIR "../test/data"
#endif

auto IsEqual(const char* actualExpression, const char* expectedExpression,
             const proto::CircuitGraph& actual,
             const proto::CircuitGraph& expected) -> testing::AssertionResult;
// NOTE: falls back to absolute tolerance if expected == 0.0
auto IsWithinRelativeTolerance(double expected, double actual,
                               double tol = 1e-4) -> testing::AssertionResult;

auto GetMessageFromJsonFile(const char* filename) -> proto::CircuitGraph;

auto getUuidGenerator() -> uuids::uuid_random_generator;

#endif  // TEST_UTILS_H
