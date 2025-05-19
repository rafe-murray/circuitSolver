#include "branch.h"
#include "graph.h"
#include "math/expression.h"
#include "math/expressionNode.h"
#include "resistor.h"
#include "voltageSource.h"
#include <ostream>
#include <stdexcept>

class CircuitGraph {
public:
  CircuitGraph(Graph<Expression, Branch*>& graph);
  Expression getErrorExpression();
  void solveCircuit() {
    ceres::Problem problem;
    for (Expression node : graph.getVertices()) {
      Expression netCurrent = getNodeCurrents(node);
      netCurrent.print();
      vector<double*> unknowns = netCurrent.getUnknownVals();
      ceres::CostFunction* costFunction =
          netCurrent.getCostFunction(unknowns.size());
      double* x0 = new double[unknowns.size()];
      cout << "Starting error for this node is: "
           << netCurrent.root->compute(x0, *netCurrent.getMap()) << endl;
      problem.AddResidualBlock(costFunction, nullptr, unknowns);
    }
    for (Branch* branch : graph.getEdges()) {
      Expression constraint = branch->constraint();
      constraint.print();
      vector<double*> unknowns = constraint.getUnknownVals();
      ceres::CostFunction* costFunction =
          constraint.getCostFunction(unknowns.size());
      double* x0 = new double[unknowns.size()];
      cout << "Starting error for this branch is: "
           << constraint.root->compute(x0, *constraint.getMap()) << endl;
      problem.AddResidualBlock(costFunction, nullptr, unknowns);
    }
    ceres::Solver::Options options;
    options.linear_solver_type = ceres::DENSE_QR;
    options.minimizer_progress_to_stdout = true;
    ceres::Solver::Summary summary;
    Solve(options, &problem, &summary);

    std::cout << summary.FullReport() << "\n";
    /*Expression error = getErrorExpression();*/
    /*error.print();*/
    /*set<const Variable*> unknowns = error.getUnknowns();*/
    /*vector<double> solution(unknowns.size());*/
    /*for (unsigned i = 0; i < solution.size(); i++) {*/
    /*  solution[i] = 0.0;*/
    /*}*/
    /*expressionMap* map = error.getMap();*/
    /*for (auto entry : *map) {*/
    /*  entry.first->value = solution[entry.second];*/
    /*  entry.first->known = true;*/
    /*}*/
    /*delete map;*/
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
