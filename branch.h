#include "math/expression.h"
#include "math/variable.h"
#include <nlopt.hpp>

using namespace std;

class Branch {
public:
  virtual ~Branch() {}
  // The voltage of one of the branch's nodes, in Volts
  Variable v1;

  // The voltage of the other node, in Volts
  Variable v2;

  /**
   * Returns an expression that represents the current through this branch, in
   * Amps
   */
  virtual Expression current() { return Expression(); }

  virtual Expression constraint() { return Expression(); }
  bool operator==(const Branch &rhs) const { return this == &rhs; }
};

namespace std {
template <> struct hash<Branch> {
  size_t operator()(const Branch &b) const {
    hash<const Branch *> pointerHash;
    return pointerHash(&b);
  }
};
} // namespace std
