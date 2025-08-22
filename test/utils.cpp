#include "utils.h"

testing::AssertionResult IsWithinRelativeTolerance(double expected,
                                                   double actual, double tol) {
  bool succeeded;
  if (expected == 0) {
    succeeded = fabs(expected - actual) <= tol;
  } else {
    succeeded = fabs(expected - actual) / fabs(expected) <= tol;
  }
  if (succeeded) {
    return testing::AssertionSuccess();
  } else {
    return testing::AssertionFailure()
           << "Expected " << expected << " but got " << actual
           << " which was not within the relative tolerance of " << tol;
  }
}
