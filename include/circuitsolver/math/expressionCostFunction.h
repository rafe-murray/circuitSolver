#ifndef EXPRESSION_COST_FUNCTION_H
#define EXPRESSION_COST_FUNCTION_H
#include "expressionNode.h"
#include "variable.h"
#include <ceres/ceres.h>
class ExpressionCostFunction : public ceres::CostFunction {
public:
  ExpressionCostFunction(expressionMap* map, shared_ptr<ExpressionNode> root)
      : map(map), root(root) {
    set_num_residuals(1);
    *mutable_parameter_block_sizes() = std::vector<int32_t>();
    for (size_t i = 0; i < map->size(); i++) {
      mutable_parameter_block_sizes()->push_back(1);
    }
  }
  virtual ~ExpressionCostFunction() { /*delete map;*/
  }
  virtual bool Evaluate(double const* const* parameters, double* residuals,
                        double** jacobians) const {
    auto val = root->compute(parameters[0], *map);
    if (val >= 1000) {
      cout << "Value was " << val << endl;
    }
    residuals[0] = val;
    /*residuals[0] = root->compute(parameters[0], *map);*/
    root->gradient = 1.0;
    root->updateChildrenGradient();
    if (jacobians != nullptr && jacobians[0] != nullptr) {
      for (auto entry : *map) {
        jacobians[0][entry.second] = entry.first->gradient;
      }
    }
    cout << "Parameters: ";
    for (int i = 0; i < map->size(); i++) {
      cout << parameters[0][i] << ", ";
    }
    cout << endl;

    cout << "Residual: " << residuals[0] << endl;

    if (jacobians != nullptr && jacobians[0] != nullptr) {
      cout << "Gradient: ";
      for (int i = 0; i < map->size(); i++) {
        cout << jacobians[0][i] << ", ";
      }
      cout << endl;
    }

    return true;

    /*const double x = parameters[0][0];*/
    /*residuals[0] = 1;*/
    /**/
    /*// Compute the Jacobian if asked for.*/
    /*if (jacobians != nullptr && jacobians[0] != nullptr) {*/
    /*  jacobians[0][0] = -1;*/
    /*}*/
    /*return true;*/
  }

private:
  expressionMap* map;
  shared_ptr<ExpressionNode> root;
};

#endif
