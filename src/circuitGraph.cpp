#include "circuitGraph.h"

#include <memory>
#include <vector>

#include "circuitGraphMessage.pb.h"
#include "edge.h"
#include "expression.h"
#include "vertex.h"

// TODO: reorganize this file
Expression CircuitGraph::getErrorExpression() {
  Expression error = 0;
  for (Vertex& node : getVertices()) {
    Expression netCurrent = getNodeCurrents(node);
    error += netCurrent * netCurrent;
  }
  for (Edge& edge : getEdges()) {
    Expression constraint = edge.getConstraint();
    error += constraint * constraint;
  }
  return error;
}

ceres::Solver::Summary CircuitGraph::solveCircuit() {
  ceres::Problem problem;
  std::vector<Expression> expressions;
  for (Vertex& node : getVertices()) {
    if (node.getVoltage().isConstant()) continue;
    Expression netCurrent = getNodeCurrents(node);
    netCurrent.addToProblem(problem);
    expressions.push_back(netCurrent);
  }
  for (Edge& edge : getEdges()) {
    Expression constraint = edge.getConstraint();
    constraint.addToProblem(problem);
    expressions.push_back(constraint);
  }
  ceres::Solver::Options options = getDefaultOptions();
  ceres::Solver::Summary summary;
  ceres::Solve(options, &problem, &summary);
  for (auto& expression : expressions) {
    expression.markKnown();
  }
  return summary;
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
