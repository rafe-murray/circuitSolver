#include "branch.h"
#include "graph.h"

class CircuitGraph {
public:
  /**
   * Gets a function that takes parameters for the unknowns in the circuit, e.g.
   * voltages or resistances, and computes how far these must be from the actual
   * values
   */
  nlopt::vfunc getErrorFunc();

  /**
   * Gets a vector of Variables that correspond to the unknowns in the circuit.
   * This can be used to determine which values should be updated after solving
   * a circuit
   */
  vector<Variable> getUnknowns();

private:
  /**
   * Get the sum of the currents going into/out of a node
   * @param node - the node to get the currents for
   * @param unknowns - a vector containing the unknowns for the graph
   * @return a function object for a function that takes in the necessary
   * arguments and return net current into the node
   * @pre node is in this.graph
   * @post unknowns now contains all the unknowns needed to solve the returned
   * function
   */
  function<double(vector<double>)> getNodeCurrents(Variable node,
                                                   vector<Variable> unknowns);
  // TODO: Figure out how to keep track of which unknowns should be used with
  // which function
  Graph<Variable, Branch> graph;
};
