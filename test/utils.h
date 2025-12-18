#ifndef TEST_UTILS_H
#define TEST_UTILS_H
#include <gtest/gtest.h>

#include "../src/proto.h"
#include "uuid.h"

// Backup for if this is not defined in the cmake file
#ifndef TEST_DATA_DIR
#define TEST_DATA_DIR "../test/data"
#endif

// NOTE: falls back to absolute tolerance if expected == 0.0
testing::AssertionResult IsWithinRelativeTolerance(double expected,
                                                   double actual,
                                                   double tol = 1e-4);

proto::CircuitGraph GetMessageFromJsonFile(const char* filename);

uuids::uuid_random_generator getUuidGenerator();

#endif  // TEST_UTILS_H
