#include "branch.h"
#include "math/expression.h"
#include "math/expressionCostFunction.h"
#include "math/expressionNode.h"
#include "resistor.h"
#include "voltageSource.h"
#include <ostream>
#include <stdexcept>

// TODO: add error handling for:
//  - Cases where there are too few equations for the number of unknowns
//  - Cases where there is no solution (e.g. no possible intersection)
//  - Maybe include the relative tolerance in the printed results

// TODO: replace Branch* with Branch in method signatures
class CircuitGraph {
public:
  Expression getErrorExpression();
  void solveCircuit() {
    ceres::Problem problem;
    cout << "Current expressions: " << endl;
    for (Expression node : getVertices()) {
      if (node.isConstant())
        continue;
      Expression netCurrent = getNodeCurrents(node);
      vector<double*> unknowns = netCurrent.getUnknownVals();
      ceres::CostFunction* costFunction = netCurrent.getCostFunction();
      problem.AddResidualBlock(costFunction, nullptr, unknowns);
      cout << netCurrent << endl;
    }
    cout << "Constraint expressions: " << endl;
    for (Branch* branch : getEdges()) {
      Expression constraint = branch->constraint();
      vector<double*> unknowns = constraint.getUnknownVals();
      ceres::CostFunction* costFunction = constraint.getCostFunction();
      problem.AddResidualBlock(costFunction, nullptr, unknowns);
      cout << constraint << endl;
    }
    ceres::Solver::Options options;
    options.linear_solver_type = ceres::DENSE_QR;
    options.minimizer_type = ceres::TRUST_REGION;
    /*options.use_nonmonotonic_steps = true;*/
    options.logging_type = ceres::SILENT;
    /*options.minimizer_progress_to_stdout = true;*/
    options.function_tolerance = 0;
    options.gradient_tolerance = 0;
    options.parameter_tolerance = 0;
    /*options.max_num_iterations = INT_MAX;*/
    ceres::Solver::Summary summary;
    Solve(options, &problem, &summary);
    cout << summary.FullReport() << endl;
  }

  /**
   * Creates a new graph instance
   */
  CircuitGraph()
      : adjacencyList(
            unordered_map<Expression, unordered_map<Expression, Branch*>>()) {}

  /**
   * Adds a vertex to the graph
   * @param v - the vertex to add
   * @return true on succesful insertion
   */
  bool addVertex(const Expression& v) {
    // Only add the vertex if it doesn't already exist
    if (adjacencyList.count(v) == 0) {
      adjacencyList[v] = unordered_map<Expression, Branch*>();
      return true;
    }
    return false;
  }

  /**
   * Removes a vertex from the graph
   * @param v - the vertex to remove
   * @return true if the vertex was part of the graph before and it is no longer
   */
  bool removeVertex(const Expression& v) {
    if (adjacencyList.count(v) == 0)
      return false;

    // Remove the vertex from all adjacency lists
    for (auto it = adjacencyList.begin(); it != adjacencyList.end(); it++) {
      it->second.erase(v);
    }

    // Remove the vertex itself
    adjacencyList.erase(v);
    return true;
  }

  /**
   * Adds an edge to the graph
   * @param e - the edge to add
   * @return true if the edge was not part of the graph before and now it is
   */
  bool addEdge(Branch* e) {
    Expression v1 = e->v1;
    Expression v2 = e->v2;

    // If either vertex is not present return false
    if (!adjacencyList.count(v1) || !adjacencyList.count(v2))
      return false;

    // If the edge already exists, return false
    if (adjacencyList[v1].count(v2) > 0)
      return false;

    // Add the edge in both directions
    adjacencyList[v1][v2] = e;
    adjacencyList[v2][v1] = e;
    return true;
  }

  /**
   * Removes an edge from the graph
   * @param e - the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  bool removeEdge(const Branch*& e) { return removeEdge(e->v1, e->v2); }

  /**
   * Removes an edge from the graph
   * @param v1 - one endpoint of the edge to remove
   * @param v2 - the other endpoint of the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  bool removeEdge(const Expression& v1, const Expression& v2) {
    if (adjacencyList.count(v1) && adjacencyList[v1].count(v2)) {
      adjacencyList[v1].erase(v2);
      adjacencyList[v2].erase(v1);
      return true;
    }
    return false;
  }

  /**
   * Gets all edges incident on a vertex. An edge is considered incident on a
   * vertex v if one of the edge's endpoints is v
   * @param v - the vertex which the edges are incident on
   * @return a vector containing all incident edges
   */
  vector<Branch*> getIncident(const Expression& v) {
    vector<Branch*> edges;
    auto it1 = adjacencyList.find(v);
    if (it1 != adjacencyList.end()) {
      unordered_map<Expression, Branch*> edgeMap = it1->second;
      for (auto it2 = edgeMap.begin(); it2 != edgeMap.end(); it2++) {
        edges.push_back(it2->second);
      }
    }
    return edges;
  }

  /**
   * Gets all vertices in the graph
   * @return a vector containing all the vertices in the graph
   */
  vector<Expression> getVertices() const {
    vector<Expression> vertices;
    for (auto it = adjacencyList.begin(); it != adjacencyList.end(); it++) {
      vertices.push_back(it->first);
    }
    return vertices;
  }

  unordered_set<Branch*> getEdges() const {
    unordered_set<Branch*> edges;
    for (auto it1 = adjacencyList.begin(); it1 != adjacencyList.end(); it1++) {
      for (auto it2 = it1->second.begin(); it2 != it1->second.end(); it2++) {
        edges.insert(it2->second);
      }
    }
    return edges;
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

  /**
   * Get the reference node for the graph
   */
  Expression getRef();
  /**
   * An adjacency list representation of the graph
   */
  unordered_map<Expression, unordered_map<Expression, Branch*>> adjacencyList;
};
