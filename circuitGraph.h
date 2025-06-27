#include "branch.h"
#include "graph.h"
#include "math/expression.h"
#include "math/expressionCostFunction.h"
#include "math/expressionNode.h"
#include "resistor.h"
#include "voltageSource.h"
#include <ostream>
#include <stdexcept>

// TODO: refactor this and graph.h to be the same file and class
class CircuitGraph {
public:
  CircuitGraph(Graph<Expression, Branch*>& graph);
  Expression getErrorExpression();
  void solveCircuit() {
    ceres::Problem problem;
    cout << "Current expressions: " << endl;
    for (Expression node : graph.getVertices()) {
      Expression netCurrent = getNodeCurrents(node);
      vector<double*> unknowns = netCurrent.getUnknownVals();
      ceres::CostFunction* costFunction = netCurrent.getCostFunction();
      problem.AddResidualBlock(costFunction, nullptr, unknowns);
      cout << netCurrent << endl;
    }
    cout << "Constraint expressions: " << endl;
    for (Branch* branch : graph.getEdges()) {
      Expression constraint = branch->constraint();
      vector<double*> unknowns = constraint.getUnknownVals();
      ceres::CostFunction* costFunction = constraint.getCostFunction();
      problem.AddResidualBlock(costFunction, nullptr, unknowns);
      cout << constraint << endl;
    }
    ceres::Solver::Options options;
    options.linear_solver_type = ceres::DENSE_QR;
    options.use_nonmonotonic_steps = true;
    options.minimizer_progress_to_stdout = true;
    ceres::Solver::Summary summary;
    Solve(options, &problem, &summary);
    cout << summary.FullReport() << endl;

    // Uncomment for debugging
    /*std::cout << summary.FullReport() << "\n";*/
  }

private:
  /**
   * Get the sum of the currents going into/out of a node
   * @param node - the node to get the currents for
   * @param unknowns - a vector containing the unknowns for the graph
   * @return a function object for a function that takes in the necessary
   * arguments and return net current into the node
   * @pre node is in this.graph
   */
  Expression getNodeCurrents(Expression node);
  Graph<Expression, Branch*> graph;
};
