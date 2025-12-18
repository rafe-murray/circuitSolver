#include "circuitGraph.h"

#include <google/protobuf/util/json_util.h>

#include <cassert>
#include <cstdio>
#include <iostream>
#include <limits>
#include <memory>
#include <ostream>
#include <random>
#include <unordered_set>
#include <vector>

#include "edge.h"
#include "expression.h"
#include "proto.h"
#include "uuid.h"
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
bool CircuitGraph::solveCircuit() {
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
    // None of the solutions were usable
    return false;
  }
  partitionSolution solution = solutions[bestIndex];
  if (solution.summary.message.find("Gradient tolerance") ==
          std::string::npos &&
      solution.summary.final_cost > 1e-15) {
    if (solveAttempts < maxSolveAttempts) {
      solveAttempts++;
      resetUnknowns();
      return solveCircuit();
    } else {
      // Exceeded max solve attempts
      return false;
    }
  }
  assert(solution.expressions.size() == solution.parameters.size());
  for (int i = 0; i < solution.expressions.size(); i++) {
    auto unknowns = solution.expressions[i].getMutableUnknowns();
    auto parameters = solution.parameters[i];
    for (int j = 0; j < unknowns.size(); j++) {
      *(unknowns[j]) = parameters[j];
    }
    solution.expressions[i].markKnown();
  }
  return true;
}

void CircuitGraph::resetUnknowns() {
  std::random_device rd;
  std::default_random_engine rng(rd());
  std::normal_distribution<> distrib(0.0, 2.0);

  auto expressions = getExpressions();
  for (auto expression : expressions) {
    auto unknowns = expression.getMutableUnknowns();
    for (auto unknown : unknowns) {
      *unknown = distrib(rng);
    }
  }
  auto discontinuities = getDiscontinuities();
  for (auto discontinuity : discontinuities) {
    *discontinuity = distrib(rng);
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

// Vertex CircuitGraph::getVertex(int id) { return *vertices.at(id); }
// Edge& CircuitGraph::getEdge(int id) { return *edges.at(id); }
bool CircuitGraph::hasVertex(const Vertex& v) {
  return vertices.find(v.getId()) != vertices.end();
}

bool CircuitGraph::hasEdge(const Edge& e) {
  return edges.find(e.getId()) != edges.end();
}

bool CircuitGraph::addVertex(const Vertex& v) {
  // Only add the vertex if it doesn't already exist
  if (!hasVertex(v)) {
    adjacencyList[v.getId()] = std::vector<uuids::uuid>();
    vertices[v.getId()] = std::make_unique<Vertex>(v);
    return true;
  }
  return false;
}

// TODO: remove this method
// bool CircuitGraph::removeVertex(const Vertex& v) {
//   if (!hasVertex(v)) return false;
//
//   // Remove from adjacencyList
//   adjacencyList[v.getId()] = std::vector<unsigned>();
//
//   // Remove the vertex itself
//   vertices[v.getId()] = nullptr;
//   return true;
// }

bool CircuitGraph::addEdge(std::unique_ptr<Edge> e) {
  if (hasEdge(*e)) return false;
  Vertex from = e->getFrom();
  Vertex to = e->getTo();
  if (!hasVertex(from) || !hasVertex(to)) return false;

  // Add the edge in both directions
  adjacencyList[from.getId()].push_back(e->getId());
  adjacencyList[to.getId()].push_back(e->getId());
  edges[e->getId()] = std::move(e);
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
    vertexList.push_back(*vertex.second);
  }
  return vertexList;
}

std::vector<Edge> CircuitGraph::getEdges() const {
  std::vector<Edge> edgeList;
  edgeList.reserve(edges.size());
  for (auto& edge : edges) {
    edgeList.push_back(*edge.second);
  }
  return edgeList;
}

bool CircuitGraph::operator==(const CircuitGraph& other) const {
  // TODO: fixme
  for (auto& entry : vertices) {
    if (other.vertices.find(entry.first) == other.vertices.end()) {
      return false;
    }
    auto& v = entry.second;
    auto& u = other.vertices.at(entry.first);
    if (v->getVoltage().isConstant() != u->getVoltage().isConstant()) {
      return false;
    }
    if (v->getVoltage().isConstant() && v->getVoltage() != u->getVoltage()) {
      return false;
    }
  }
  for (auto& entry : edges) {
    if (other.edges.find(entry.first) == other.edges.end()) {
      return false;
    }
    auto& e = entry.second;
    auto& f = other.edges.at(entry.first);
    if (e->getFrom().getId() != f->getFrom().getId()) {
      return false;
    }
    if (e->getTo().getId() != f->getTo().getId()) {
      return false;
    }
    // HACK: using existing logic to convert to protobuf messages to determine
    // edge type rather than creating an overloaded function
    auto eMsg = new proto::CircuitGraph::Edge();
    e->toProto(eMsg);
    auto fMsg = new proto::CircuitGraph::Edge();
    f->toProto(fMsg);
    if (eMsg->specific_branch_case() != fMsg->specific_branch_case()) {
      return false;
    }
  }
  return true;
}

proto::CircuitGraph CircuitGraph::toProto() const {
  proto::CircuitGraph proto;
  for (auto& vertex : getVertices()) {
    const std::string vertexId = uuids::to_string(vertex.getId());
    (*proto.mutable_vertices())[vertexId] = proto::Vertex();
    auto protoVertex = &proto.mutable_vertices()->at(vertexId);
    vertex.toProto(protoVertex);
  }
  for (auto& edge : getEdges()) {
    const std::string edgeId = uuids::to_string(edge.getId());
    (*proto.mutable_edges())[edgeId] = proto::Edge();
    auto protoEdge = &proto.mutable_edges()->at(edgeId);
    edge.toProto(protoEdge);
  }
  return proto;
}
proto::CircuitGraph CircuitGraph::toProto(const double* parameters) const {
  proto::CircuitGraph proto;
  for (auto& vertex : getVertices()) {
    const std::string vertexId = uuids::to_string(vertex.getId());
    (*proto.mutable_vertices())[vertexId] = proto::Vertex();
    auto protoVertex = &proto.mutable_vertices()->at(vertexId);
    vertex.toProto(protoVertex, parameters);
  }
  for (auto& edge : getEdges()) {
    const std::string edgeId = uuids::to_string(edge.getId());
    (*proto.mutable_edges())[edgeId] = proto::Edge();
    auto protoEdge = &proto.mutable_edges()->at(edgeId);
    edge.toProto(protoEdge, parameters);
  }
  return proto;
}
std::optional<std::unique_ptr<CircuitGraph>> CircuitGraph::fromProto(
    const proto::CircuitGraph& proto) {
  auto cg = std::make_unique<CircuitGraph>();
  for (auto protoVertex : proto.vertices()) {
    if (auto vertex = Vertex::fromProto(protoVertex.second);
        vertex.has_value()) {
      cg->addVertex(vertex.value());
    } else {
      return std::nullopt;
    }
  }
  for (auto protoEdge : proto.edges()) {
    if (auto edge = Edge::fromProto(protoEdge.second, cg->vertices);
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
