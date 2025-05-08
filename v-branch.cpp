#include "v-branch.h"
Variable VoltageSource::current() {
  Variable current;
  current.known = false;
  return current;
}
