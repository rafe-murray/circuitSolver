#include "circuitGraph.h"
#include <nlopt.hpp>
#include <vector>

// TODO: add a linear solver for faster solving time on linear problems

namespace Solver {
/**
 * Returns a vector with the solved values of the unkown variables in the
 * function Takes the function to solve as an argument. errFunc is a function
 * that describes the total error or deviation from the correct values
 */
std::vector<double> solve(nlopt::vfunc errFunc);
void solveCircuit(CircuitGraph graph);

} // namespace Solver
