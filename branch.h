#ifndef BRANCH_H
#define BRANCH_H
#include "math/expression.h"
#include "math/variable.h"
#include <nlopt.hpp>

using namespace std;

class Branch {
public:
  virtual ~Branch() {}
  // TODO: fix passing by reference; want v1 and v2 to point to the original
  // locations in memory!
  Branch(const Expression& v1, const Expression& v2) : v1(v1), v2(v2) {}
  Branch() : v1(Expression()), v2(Expression()) {}
  // The voltage of one of the branch's nodes, in Volts
  Expression v1;

  // The voltage of the other node, in Volts
  Expression v2;

  /**
   * Returns an expression that represents the current through this branch, in
   * Amps
   */
  virtual Expression getCurrent() { return Expression(); }

  virtual Expression constraint() const { return Expression(0.0); }
  bool operator==(const Branch& rhs) const { return this == &rhs; }
};

namespace std {
template <> struct hash<Branch> {
  size_t operator()(const Branch& b) const {
    hash<const Branch*> pointerHash;
    return pointerHash(&b);
  }
};
} // namespace std
#endif
