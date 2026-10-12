#include "circuit_solver/circuitGraph.h"

#include <ceres/problem.h>
#include <ceres/solver.h>
#include <fmt/format.h>
#include <google/protobuf/json/json.h>
#include <google/protobuf/util/json_util.h>
#include <spdlog/spdlog.h>
#include <uuid.h>

#include <cassert>
#include <expected>
#include <functional>
#include <iostream>
#include <memory>
#include <optional>
#include <ostream>
#include <span>
#include <string>
#include <utility>
#include <vector>

#include "circuit_solver/config.h"
#include "circuit_solver/edge.h"
#include "circuit_solver/errors.h"
#include "circuit_solver/expression.h"
#include "circuit_solver/proto.h"
#include "circuit_solver/solver.h"
#include "circuit_solver/vertex.h"

using circuitsolver::CircuitSolverError;
using circuitsolver::constants::solutionCostThreshold;
using circuitsolver::constants::unknownSeedStdDeviation;

// TODO: reorganize this file

// TODO: ensure that ternaryOpNodes will always add an expression that equates
// the basis with a valid expression as its constraint method

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
  auto solver = circuitsolver::solver::Solver{};
  auto expressions = getExpressions();
  auto solution = solver.Solve(expressions);
  if (!solution.has_value()) {
    return std::unexpected{solution.error()};
  }
  solution->apply();
  for (auto expression : expressions) {
    expression.markKnown();
  }
  return *this;
}

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

auto operator<<(std::ostream& out, const CircuitGraph& cg) -> std::ostream& {
  std::string output;
  (void)google::protobuf::json::MessageToJsonString(cg.toProto(), &output);
  out << output << '\n';
  return out;
}
