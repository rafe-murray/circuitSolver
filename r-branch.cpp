#include "r-branch.h"
Variable Resistor::current() {
  return (v1.value - v2.value) / resistance.value;
}
