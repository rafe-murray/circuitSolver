#ifndef CONDITION_H
#define CONDITION_H

#include "expressionNode.h"
#include <memory>
using namespace std;
enum class ConditionType { LT, LEQ, EQ, NEQ, GEQ, GT };
class Condition {
public:
  Condition(ConditionType op, shared_ptr<ExpressionNode> lhs,
            shared_ptr<ExpressionNode> rhs)
      : op(op), lhs(lhs), rhs(rhs) {}
  bool compute(const double* const values, const expressionMap& map) {
    switch (op) {
    case ConditionType::LT:
      return lhs->compute(values, map) < rhs->compute(values, map);
    case ConditionType::LEQ:
      return lhs->compute(values, map) <= rhs->compute(values, map);
    case ConditionType::EQ:
      return lhs->compute(values, map) == rhs->compute(values, map);
    case ConditionType::NEQ:
      return lhs->compute(values, map) != rhs->compute(values, map);
    case ConditionType::GEQ:
      return lhs->compute(values, map) >= rhs->compute(values, map);
    case ConditionType::GT:
      return lhs->compute(values, map) > rhs->compute(values, map);
    }
  }
  void getUnknowns(set<VariableNode*>& unknowns) {
    lhs->getUnknowns(unknowns);
    rhs->getUnknowns(unknowns);
  }

  bool passed;

private:
  ConditionType op;
  shared_ptr<ExpressionNode> lhs;
  shared_ptr<ExpressionNode> rhs;
  friend ostream& operator<<(ostream& out, const Condition& c);
};

#endif
