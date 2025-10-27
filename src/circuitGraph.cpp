#include "circuitGraph.h"

#include <google/protobuf/util/json_util.h>

#include <cassert>
#include <limits>
#include <memory>
#include <ostream>
#include <stdexcept>
#include <unordered_set>
#include <vector>

#include "circuitGraphMessage.pb.h"
#include "edge.h"
#include "expression.h"
#include "vertex.h"

// TODO: reorganize this file

// TODO: ensure that ternaryOpNodes will always add an expression that equates
// the basis with a valid expression as its constraint method
partitionSolution CircuitGraph::solvePartition(
    const std::vector<double*>& basis, const std::vector<bool>& isHigh) {
  // std::cout << "Starting state:";
  // print(std::cout, *this, getUnknowns());
  ceres::Problem problem;
  std::vector<Expression> expressions = getExpressions();
  for (auto expression : expressions) {
    expression.addToProblem(problem);
  }
  assert(basis.size() == isHigh.size());
  for (size_t i = 0; i < basis.size(); i++) {
    if (isHigh[i]) {
      // std::cout << "Setting lower limit on " << basis[i] << " to 0"
      //           << std::endl;
      problem.SetParameterLowerBound(basis[i], 0, 0);
    } else {
      // std::cout << "Setting upper limit on " << basis[i] << " to 0"
      //           << std::endl;
      problem.SetParameterUpperBound(basis[i], 0, 0);
    }
  }
  // std::cout << std::endl;
  ceres::Solver::Options options = getDefaultOptions();
  ceres::Solver::Summary summary;
  ceres::Solve(options, &problem, &summary);
  std::vector<std::vector<double>> allParameters;
  std::unordered_set<const double*> allUnknowns;
  for (auto& expression : expressions) {
    auto unknowns = expression.getMutableUnknowns();
    std::vector<double> parameters;
    for (auto unknown : unknowns) {
      parameters.push_back(*unknown);
    }
    allParameters.push_back(parameters);
    auto constUnknowns = expression.getUnknowns();
    allUnknowns.merge(constUnknowns);
  }
  // std::cout << "Cost: " << summary.final_cost << summary.message <<
  // std::endl; print(std::cout, *this, allUnknowns);
  partitionSolution solution{summary, expressions, allParameters};
  return solution;
}

/**
 * At start we have:
 * - The unknowns, as an array of double*'s
 * - We can get the values by dereferencing the pointers
 * We need:
 * - The actual values of the unknowns
 * - A way to set the values of the unknowns from this array
 */

// TODO: fix case of no discontinuities
ceres::Solver::Summary CircuitGraph::solveCircuit() {
  std::vector<double*> basis = getDiscontinuities();
  int basisSize = basis.size();
  int numPartitions;
  if (basisSize > 0) {
    numPartitions = 1 << basisSize;
  } else {
    numPartitions = 1;
  }
  std::vector<partitionSolution> solutions(numPartitions);
  std::vector<std::vector<bool>> isHigh;
  for (int i = 0; i < numPartitions; i++) {
    isHigh.push_back(std::vector<bool>(basisSize));
    for (int j = 0; j < basisSize; j++) {
      isHigh[i][j] = (i >> j) & 1;
    }
    solutions[i] = solvePartition(basis, isHigh[i]);
    resetUnknowns();
  }
  double minError = std::numeric_limits<double>::max();
  int bestIndex = -1;
  for (int i = 0; i < solutions.size(); i++) {
    if (!solutions[i].summary.IsSolutionUsable()) {
      continue;
    }
    if (solutions[i].summary.final_cost < minError) {
      minError = solutions[i].summary.final_cost;
      bestIndex = i;
    }
  }
  if (bestIndex == -1) {
    throw std::runtime_error("No solution found\n");  // TODO: fail gracefully
  }
  partitionSolution solution = solutions[bestIndex];
  assert(solution.expressions.size() == solution.parameters.size());
  for (int i = 0; i < solution.expressions.size(); i++) {
    auto unknowns = solution.expressions[i].getMutableUnknowns();
    auto parameters = solution.parameters[i];
    for (int j = 0; j < unknowns.size(); j++) {
      *(unknowns[j]) = parameters[j];
    }
    solution.expressions[i].markKnown();
  }
  return solutions[bestIndex].summary;
}
void CircuitGraph::resetUnknowns() {
  auto expressions = getExpressions();
  for (auto expression : expressions) {
    auto unknowns = expression.getMutableUnknowns();
    for (auto unknown : unknowns) {
      *unknown = 1;
    }
  }
  auto discontinuities = getDiscontinuities();
  for (auto discontinuity : discontinuities) {
    *discontinuity = 1;
  }
}

std::unordered_set<const double*> CircuitGraph::getUnknowns() {
  std::unordered_set<const double*> unknowns;
  auto expressions = getExpressions();
  for (auto expression : expressions) {
    unknowns.merge(expression.getUnknowns());
  }
  return unknowns;
}

std::vector<Expression> CircuitGraph::getExpressions() {
  std::vector<Expression> expressions;
  for (Vertex& node : getVertices()) {
    if (node.getVoltage().isConstant()) continue;
    Expression netCurrent = getNodeCurrents(node);
    expressions.push_back(netCurrent);
  }
  for (Edge& edge : getEdges()) {
    Expression constraint = edge.getConstraint();
    expressions.push_back(constraint);
  }
  return expressions;
}

Expression CircuitGraph::getNodeCurrents(Vertex node) {
  Expression nodeCurrents = 0;
  for (Edge& branch : getIncident(node)) {
    Expression current = branch.getCurrent();
    if (branch.getFrom() == node) {
      nodeCurrents -= current;
    } else {
      nodeCurrents += current;
    }
  }
  return nodeCurrents;
}

Vertex CircuitGraph::getVertex(int id) { return *vertices.at(id); }
Edge& CircuitGraph::getEdge(int id) { return *edges.at(id); }
bool CircuitGraph::hasVertex(const Vertex& v) {
  return vertices.size() > v.getId() && vertices[v.getId()] != nullptr;
}

bool CircuitGraph::hasEdge(const Edge& e) {
  return edges.size() > e.getId() && edges[e.getId()] != nullptr;
}

bool CircuitGraph::addVertex(const Vertex& v) {
  // Only add the vertex if it doesn't already exist
  if (!hasVertex(v)) {
    adjacencyList.insert(adjacencyList.begin() + v.getId(),
                         std::vector<unsigned>());
    vertices.insert(vertices.begin() + v.getId(), std::make_unique<Vertex>(v));
    return true;
  }
  return false;
}

// TODO: remove this method
bool CircuitGraph::removeVertex(const Vertex& v) {
  if (!hasVertex(v)) return false;

  // Remove from adjacencyList
  adjacencyList[v.getId()] = std::vector<unsigned>();

  // Remove the vertex itself
  vertices[v.getId()] = nullptr;
  return true;
}

bool CircuitGraph::addEdge(std::unique_ptr<Edge> e) {
  if (hasEdge(*e)) return false;
  Vertex from = e->getFrom();
  Vertex to = e->getTo();
  if (!hasVertex(from) || !hasVertex(to)) return false;

  // Add the edge in both directions
  adjacencyList[from.getId()].push_back(e->getId());
  adjacencyList[to.getId()].push_back(e->getId());
  edges.insert(edges.begin() + e->getId(), std::move(e));
  return true;
}

// NOTE: this is probably slightly less efficient since we have to fetch the
// Edge again, but it is easier to maintain
// @pre this.hasEdge(e) == true
// bool CircuitGraph::removeEdge(const Edge& e) {
//   adjacencyList[e.getFrom().getId()].erase(adjacencyList.find()
//   return removeEdge(e.getFrom(), e.getTo());
// }

// bool CircuitGraph::removeEdge(const Vertex& from, const Vertex& to) {
//   if (hasVertex(from) && ) {
//     int id = adjacencyList[v1][v2]->getId();
//     adjacencyList[v1].erase(v2);
//     adjacencyList[v2].erase(v1);
//     edges.erase(id);
//     return true;
//   }
//   return false;
// }

std::vector<Edge> CircuitGraph::getIncident(const Vertex& v) {
  std::vector<Edge> incidentEdges;
  auto edgeIds = adjacencyList[v.getId()];
  incidentEdges.reserve(edgeIds.size());
  for (auto id : edgeIds) {
    incidentEdges.push_back(*edges[id]);
  }
  return incidentEdges;
}

std::vector<Vertex> CircuitGraph::getVertices() const {
  std::vector<Vertex> vertexList;
  vertexList.reserve(vertices.size());
  for (auto& vertex : vertices) {
    vertexList.push_back(*vertex);
  }
  return vertexList;
}

std::vector<Edge> CircuitGraph::getEdges() const {
  std::vector<Edge> edgeList;
  edgeList.reserve(edges.size());
  for (auto& edge : edges) {
    edgeList.push_back(*edge);
  }
  return edgeList;
}

bool CircuitGraph::operator==(const CircuitGraph& other) const {
  // TODO: fixme
  for (auto& v : vertices) {
    if (v->getId() >= other.vertices.size()) return false;
    auto& u = other.vertices[v->getId()];
    if (v->getVoltage().isConstant() != u->getVoltage().isConstant()) {
      return false;
    }
    if (v->getVoltage().isConstant() && v->getVoltage() != u->getVoltage()) {
      return false;
    }
  }
  for (auto& e : edges) {
    if (e->getId() >= other.edges.size()) return false;
    auto& f = other.edges[e->getId()];
    if (e->getFrom().getId() != f->getFrom().getId()) {
      return false;
    }
    if (e->getTo().getId() != f->getTo().getId()) {
      return false;
    }
    // HACK: using existing logic to convert to protobuf messages to determine
    // edge type rather than creating an overloaded function
    auto eMsg = new circuitsolver::CircuitGraphMessage::Edge();
    e->toProto(eMsg);
    auto fMsg = new circuitsolver::CircuitGraphMessage::Edge();
    f->toProto(fMsg);
    if (eMsg->specificBranch_case() != fMsg->specificBranch_case()) {
      return false;
    }
  }
  return true;
}

circuitsolver::CircuitGraphMessage CircuitGraph::toProto() const {
  circuitsolver::CircuitGraphMessage proto;
  for (auto& vertex : getVertices()) {
    auto protoVertices = proto.add_vertices();
    vertex.toProto(protoVertices);
  }
  for (auto& edge : getEdges()) {
    auto protoEdge = proto.add_edges();
    edge.toProto(protoEdge);
  }
  return proto;
}
circuitsolver::CircuitGraphMessage CircuitGraph::toProto(
    const double* parameters) const {
  circuitsolver::CircuitGraphMessage proto;
  for (auto& vertex : getVertices()) {
    auto protoVertices = proto.add_vertices();
    vertex.toProto(protoVertices, parameters);
  }
  for (auto& edge : getEdges()) {
    auto protoEdge = proto.add_edges();
    edge.toProto(protoEdge, parameters);
  }
  return proto;
}
std::optional<std::unique_ptr<CircuitGraph>> CircuitGraph::fromProto(
    const circuitsolver::CircuitGraphMessage& proto) {
  auto cg = std::make_unique<CircuitGraph>();
  for (auto protoVertex : proto.vertices()) {
    if (auto vertex = Vertex::fromProto(protoVertex); vertex.has_value()) {
      cg->addVertex(vertex.value());
    } else {
      return std::nullopt;
    }
  }
  for (auto protoEdge : proto.edges()) {
    if (auto edge = Edge::fromProto(protoEdge, cg->vertices);
        edge.has_value()) {
      cg->addEdge(std::make_unique<Edge>(std::move(edge.value())));
    } else {
      return std::nullopt;
    }
  }
  return cg;
}
std::vector<double*> CircuitGraph::getDiscontinuities() {
  std::unordered_set<double*> discontinuities;
  auto expressions = getExpressions();
  for (auto expression : expressions) {
    discontinuities.merge(expression.getDiscontinuities());
  }
  std::vector<double*> discontinuitiesVector;
  for (auto el : discontinuities) {
    discontinuitiesVector.push_back(el);
  }
  return discontinuitiesVector;
}

std::ostream& operator<<(std::ostream& out, const CircuitGraph& cg) {
  std::string output;
  (void)google::protobuf::json::MessageToJsonString(cg.toProto(), &output);
  out << output << std::endl;
  return out;
}

void CircuitGraph::print(std::ostream& out, const CircuitGraph& cg,
                         std::unordered_set<const double*> parameters) {
  size_t parameterSize = parameters.size();
  double* paramArray = new double[parameterSize];
  int i = 0;
  for (auto parameter : parameters) {
    paramArray[i] = *parameter;
    i++;
  }
  std::string output;
  (void)google::protobuf::json::MessageToJsonString(cg.toProto(paramArray),
                                                    &output);
  out << output << std::endl;
}
