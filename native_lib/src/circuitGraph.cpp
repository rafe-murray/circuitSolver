#include "circuit_solver/circuitGraph.h"

#include <ceres/problem.h>
#include <ceres/solver.h>
#include <fmt/format.h>
#include <google/protobuf/json/json.h>
#include <google/protobuf/util/json_util.h>
#include <spdlog/spdlog.h>
#include <uuid.h>

#include <bitset>
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <expected>
#include <functional>
#include <iostream>
#include <limits>
#include <memory>
#include <optional>
#include <ostream>
#include <random>
#include <string>
#include <unordered_set>
#include <utility>
#include <vector>

#include "absl/strings/match.h"
#include "circuit_solver/config.h"
#include "circuit_solver/edge.h"
#include "circuit_solver/errors.h"
#include "circuit_solver/expression.h"
#include "circuit_solver/proto.h"
#include "circuit_solver/vertex.h"

using circuitsolver::CircuitSolverError;
using circuitsolver::constants::solutionCostThreshold;
using circuitsolver::constants::unknownSeedStdDeviation;

// TODO: reorganize this file

// TODO: ensure that ternaryOpNodes will always add an expression that equates
// the basis with a valid expression as its constraint method
auto CircuitGraph::solvePartition(const std::vector<double*>& basis,
                                  const std::vector<bool>& isHigh)
    -> partitionSolution {
  // std::cout << "Starting state:";
  // print(std::cout, *this, getUnknowns());
  ceres::Problem problem;
  std::vector<Expression> expressions = getExpressions();
  for (auto expression : expressions) {
    expression.addToProblem(problem);
  }
  assert(basis.size() == isHigh.size());
  for (size_t i = 0; i < basis.size(); i++) {
    if (isHigh.at(i)) {
      // std::cout << "Setting lower limit on " << basis[i] << " to 0"
      //           << std::endl;
      problem.SetParameterLowerBound(basis.at(i), 0, 0);
    } else {
      // std::cout << "Setting upper limit on " << basis[i] << " to 0"
      //           << std::endl;
      problem.SetParameterUpperBound(basis.at(i), 0, 0);
    }
  }
  // std::cout << std::endl;
  ceres::Solver::Options options = getDefaultOptions();
  ceres::Solver::Summary summary;
  ceres::Solve(options, &problem, &summary);
  std::vector<std::vector<double>> allParameters;
  // std::unordered_set<const double*> allUnknowns;
  for (auto& expression : expressions) {
    auto unknowns = expression.getUnknowns();
    std::vector<double> parameters;
    parameters.reserve(unknowns.size());
    for (auto* unknown : unknowns) {
      parameters.push_back(*unknown);
    }
    allParameters.push_back(parameters);
    // auto constUnknowns = expression.getUnknowns();
    // allUnknowns.merge(constUnknowns);
  }
  // std::cout << "Cost: " << summary.final_cost << summary.message <<
  // std::endl; print(std::cout, *this, allUnknowns);
  partitionSolution solution{.summary = summary,
                             .expressions = expressions,
                             .parameters = allParameters};
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
auto CircuitGraph::solveCircuit()
    -> std::expected<std::reference_wrapper<CircuitGraph>, CircuitSolverError> {
  // TODO: Find a non-exponential solution for discontinuities
  constexpr int maxBasisSize = 32;
  std::vector<double*> basis = getDiscontinuities();
  int basisSize = static_cast<int>(basis.size());
  if (basisSize >= maxBasisSize) {
    return std::unexpected{CircuitSolverError{
        circuitsolver::ErrorType::TooManyDiscontinuities,
        fmt::format("Cannot solve circuit since it has too many elements with "
                    "discontinuous behaviour. The max is {}; you had {}",
                    maxBasisSize, basisSize)}};
  }
  uint32_t numPartitions = 0;
  if (basisSize > 0) {
    // 2^n partitions: combinations for each discontinuity's high and low case
    numPartitions = uint32_t{1} << basisSize;
  } else {
    numPartitions = 1;
  }
  SPDLOG_DEBUG("numPartitions: {}, basisSize: {}", numPartitions, basisSize);
  std::vector<partitionSolution> solutions(numPartitions);
  std::vector<std::vector<bool>> isHigh;
  for (uint32_t i = 0; i < numPartitions; i++) {
    isHigh.emplace_back(basisSize);
    for (int j = 0; j < basisSize; j++) {
      auto bits = std::bitset<maxBasisSize>(i);
      isHigh.at(i).at(j) = bits[j];
    }
    solutions.insert(solutions.begin() + i,
                     solvePartition(basis, isHigh.at(i)));
    resetUnknowns();
  }
  double minError = std::numeric_limits<double>::max();
  // use a flag over a sentinel value to avoid integer overflow concerns
  bool isSolutionUsable = false;
  size_t bestIndex = 0;
  for (size_t i = 0; i < solutions.size(); i++) {
    if (!solutions.at(i).summary.IsSolutionUsable()) {
      continue;
    }
    if (solutions.at(i).summary.final_cost < minError) {
      minError = solutions.at(i).summary.final_cost;
      bestIndex = i;
      isSolutionUsable = true;
    }
  }
  if (!isSolutionUsable) {
    return std::unexpected{CircuitSolverError{
        circuitsolver::ErrorType::NoSolution, "No usable solution found"}};
  }

  partitionSolution solution = solutions.at(bestIndex);
  if (!absl::StrContains(solution.summary.message, "Gradient tolerance") &&
      solution.summary.final_cost > solutionCostThreshold) {
    if (solveAttempts < maxSolveAttempts) {
      solveAttempts++;
      resetUnknowns();
      return solveCircuit();
    }  // Exceeded max solve attempts
    return std::unexpected{CircuitSolverError{
        circuitsolver::ErrorType::NoSolution,
        fmt::format("Exceeded maximum solve attempts of {}. No solution was "
                    "within cost threshold {}",
                    maxSolveAttempts, solutionCostThreshold)}};
  }
  assert(solution.expressions.size() == solution.parameters.size());
  for (size_t i = 0; i < solution.expressions.size(); i++) {
    auto unknowns = solution.expressions.at(i).getUnknowns();
    auto parameters = solution.parameters.at(i);
    for (size_t j = 0; j < unknowns.size(); j++) {
      *(unknowns.at(j)) = parameters.at(j);
    }
    solution.expressions.at(i).markKnown();
  }
  return *this;
}

void CircuitGraph::resetUnknowns() {
  std::random_device rd;
  std::default_random_engine rng(rd());
  std::normal_distribution<> distrib(0.0, unknownSeedStdDeviation);

  auto expressions = getExpressions();
  for (auto expression : expressions) {
    auto unknowns = expression.getUnknowns();
    for (auto* unknown : unknowns) {
      *unknown = distrib(rng);
    }
  }
  auto discontinuities = getDiscontinuities();
  for (auto* discontinuity : discontinuities) {
    *discontinuity = distrib(rng);
  }
}

// std::unordered_set<const double*> CircuitGraph::getUnknowns() {
//   std::unordered_set<const double*> unknowns;
//   auto expressions = getExpressions();
//   for (auto expression : expressions) {
//     unknowns.merge(expression.getUnknowns());
//   }
//   return unknowns;
// }

auto CircuitGraph::getExpressions() -> std::vector<Expression> {
  std::vector<Expression> expressions;
  for (Vertex& node : getVertices()) {
    if (node.getVoltage().isConstant()) {
      continue;
    }
    Expression netCurrent = getNodeCurrents(node);
    expressions.push_back(netCurrent);
  }
  for (Edge& edge : getEdges()) {
    Expression constraint = edge.getConstraint();
    expressions.push_back(constraint);
  }
  return expressions;
}

auto CircuitGraph::getNodeCurrents(const Vertex& node) -> Expression {
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
auto CircuitGraph::hasVertex(const Vertex& v) -> bool {
  return vertices.contains(v.getId());
}

auto CircuitGraph::hasEdge(const Edge& e) -> bool {
  return edges.contains(e.getId());
}

auto CircuitGraph::addVertex(const Vertex& v) -> bool {
  // Only add the vertex if it doesn't already exist
  if (!hasVertex(v)) {
    adjacencyList.insert_or_assign(v.getId(), std::vector<uuids::uuid>());
    vertices.insert_or_assign(v.getId(), std::make_unique<Vertex>(v));
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

auto CircuitGraph::addEdge(std::unique_ptr<Edge> e) -> bool {
  if (hasEdge(*e)) {
    return false;
  }
  Vertex from = e->getFrom();
  Vertex to = e->getTo();
  if (!hasVertex(from) || !hasVertex(to)) {
    return false;
  }

  // Add the edge in both directions
  adjacencyList.at(from.getId()).push_back(e->getId());
  adjacencyList.at(to.getId()).push_back(e->getId());
  edges.insert_or_assign(e->getId(), std::move(e));
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

auto CircuitGraph::getIncident(const Vertex& v) -> std::vector<Edge> {
  std::vector<Edge> incidentEdges;
  auto edgeIds = adjacencyList.at(v.getId());
  incidentEdges.reserve(edgeIds.size());
  for (auto id : edgeIds) {
    incidentEdges.push_back(*edges.at(id));
  }
  return incidentEdges;
}

auto CircuitGraph::getVertices() const -> std::vector<Vertex> {
  std::vector<Vertex> vertexList;
  vertexList.reserve(vertices.size());
  for (const auto& vertex : vertices) {
    vertexList.push_back(*vertex.second);
  }
  return vertexList;
}

auto CircuitGraph::getEdges() const -> std::vector<Edge> {
  std::vector<Edge> edgeList;
  edgeList.reserve(edges.size());
  for (const auto& edge : edges) {
    edgeList.push_back(*edge.second);
  }
  return edgeList;
}

auto CircuitGraph::operator==(const CircuitGraph& other) const -> bool {
  // TODO: fixme
  for (const auto& entry : vertices) {
    if (!other.vertices.contains(entry.first)) {
      return false;
    }
    const auto& v = entry.second;
    const auto& u = other.vertices.at(entry.first);
    if (v->getVoltage().isConstant() != u->getVoltage().isConstant()) {
      return false;
    }
    if (v->getVoltage().isConstant() && v->getVoltage() != u->getVoltage()) {
      return false;
    }
  }
  for (const auto& entry : edges) {
    if (!other.edges.contains(entry.first)) {
      return false;
    }
    const auto& e = entry.second;
    const auto& f = other.edges.at(entry.first);
    if (e->getFrom().getId() != f->getFrom().getId()) {
      return false;
    }
    if (e->getTo().getId() != f->getTo().getId()) {
      return false;
    }
    // HACK: using existing logic to convert to protobuf messages to determine
    // edge type rather than creating an overloaded function
    auto eMsg = std::make_unique<proto::CircuitGraph::Edge>();
    e->toProto(eMsg.get());
    auto fMsg = std::make_unique<proto::CircuitGraph::Edge>();
    f->toProto(fMsg.get());
    if (eMsg->specific_branch_case() != fMsg->specific_branch_case()) {
      return false;
    }
  }
  return true;
}

auto CircuitGraph::toProto() const -> proto::CircuitGraph {
  proto::CircuitGraph proto;
  for (auto& vertex : getVertices()) {
    const std::string vertexId = uuids::to_string(vertex.getId());
    (*proto.mutable_vertices()).insert({vertexId, proto::Vertex()});
    auto* protoVertex = &proto.mutable_vertices()->at(vertexId);
    vertex.toProto(protoVertex);
  }
  for (auto& edge : getEdges()) {
    const std::string edgeId = uuids::to_string(edge.getId());
    (*proto.mutable_edges()).insert({edgeId, proto::Edge()});
    auto* protoEdge = &proto.mutable_edges()->at(edgeId);
    edge.toProto(protoEdge);
  }
  return proto;
}
auto CircuitGraph::toProto(std::span<const double> parameters) const
    -> proto::CircuitGraph {
  proto::CircuitGraph proto;
  for (auto& vertex : getVertices()) {
    const std::string vertexId = uuids::to_string(vertex.getId());
    (*proto.mutable_vertices()).insert({vertexId, proto::Vertex()});
    auto* protoVertex = &proto.mutable_vertices()->at(vertexId);
    vertex.toProto(protoVertex, parameters);
  }
  for (auto& edge : getEdges()) {
    const std::string edgeId = uuids::to_string(edge.getId());
    (*proto.mutable_edges()).insert({edgeId, proto::Edge()});
    auto* protoEdge = &proto.mutable_edges()->at(edgeId);
    edge.toProto(protoEdge, parameters);
  }
  return proto;
}
auto CircuitGraph::fromProto(const proto::CircuitGraph& proto)
    -> std::optional<std::unique_ptr<CircuitGraph>> {
  auto cg = std::make_unique<CircuitGraph>();
  for (const auto& protoVertex : proto.vertices()) {
    if (auto vertex = Vertex::fromProto(protoVertex.second);
        vertex.has_value()) {
      cg->addVertex(vertex.value());
    } else {
      return std::nullopt;
    }
  }
  for (const auto& protoEdge : proto.edges()) {
    if (auto edge = Edge::fromProto(protoEdge.second, cg->vertices);
        edge.has_value()) {
      cg->addEdge(std::make_unique<Edge>(std::move(edge.value())));
    } else {
      return std::nullopt;
    }
  }
  return cg;
}
auto CircuitGraph::getDiscontinuities() -> std::vector<double*> {
  std::unordered_set<double*> discontinuities;
  auto expressions = getExpressions();
  for (auto expression : expressions) {
    discontinuities.merge(expression.getDiscontinuities());
  }
  std::vector<double*> discontinuitiesVector;
  discontinuitiesVector.reserve(discontinuities.size());
  // Solving algorithm is already non-deterministic
  // NOLINTBEGIN(bugprone-nondeterministic-pointer-iteration-order)
  for (auto* el : discontinuities) {
    discontinuitiesVector.push_back(el);
  }
  // NOLINTEND(bugprone-nondeterministic-pointer-iteration-order)
  return discontinuitiesVector;
}

auto operator<<(std::ostream& out, const CircuitGraph& cg) -> std::ostream& {
  std::string output;
  (void)google::protobuf::json::MessageToJsonString(cg.toProto(), &output);
  out << output << '\n';
  return out;
}

void CircuitGraph::print(std::ostream& out, const CircuitGraph& cg,
                         std::span<const double> parameters) {
  std::string output;
  (void)google::protobuf::json::MessageToJsonString(cg.toProto(parameters),
                                                    &output);
  out << output << '\n';
}
