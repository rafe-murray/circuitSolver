#ifndef CIRCUIT_GRAPH_H
#define CIRCUIT_GRAPH_H

#include <memory>
#include <ostream>
#include <unordered_map>

#include "edge.h"
#include "expression.h"
#include "proto.h"
#include "vertex.h"

// TODO: add error handling for:
//  - Cases where there are too few equations for the number of unknowns
//  - Cases where there is no solution (e.g. no possible intersection)
//  - Maybe include the relative tolerance in the printed results

struct partitionSolution {
  ceres::Solver::Summary summary;
  std::vector<Expression> expressions;
  std::vector<std::vector<double>> parameters;
};

class CircuitGraph {
 public:
  bool solveCircuit();

  /**
   * Creates a new graph instance
   */
  CircuitGraph()
      : adjacencyList(
            std::unordered_map<uuids::uuid, std::vector<uuids::uuid>>()) {}

  /**
   * Adds a vertex to the graph
   * @param v - the vertex to add
   * @return true on successful insertion
   */
  bool addVertex(const Vertex& v);

  bool hasVertex(const Vertex& v);

  /**
   * Removes a vertex from the graph
   * @param v - the vertex to remove
   * @return true if the vertex was part of the graph before and it is no longer
   */
  // bool removeVertex(const Vertex& v);

  /**
   * Adds an edge to the graph
   * @param e - the edge to add
   * @return true if the edge was not part of the graph before and now it is
   */
  bool addEdge(std::unique_ptr<Edge> e);

  bool addEdge(const Edge& e) { return addEdge(std::make_unique<Edge>(e)); };

  bool hasEdge(const Edge& e);

  /**
   * Removes an edge from the graph
   * @param e - the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  bool removeEdge(const Edge& e);

  /**
   * Removes an edge from the graph
   * @param v1 - one endpoint of the edge to remove
   * @param v2 - the other endpoint of the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  bool removeEdge(const Vertex& v1, const Vertex& v2);

  /**
   * Gets all edges incident on a vertex. An edge is considered incident on a
   * vertex v if one of the edge's endpoints is v
   * @param v - the vertex which the edges are incident on
   * @return a vector containing all incident edges
   */
  std::vector<Edge> getIncident(const Vertex& v);

  /**
   * Gets all vertices in the graph
   * @return a vector containing all the vertices in the graph
   */
  std::vector<Vertex> getVertices() const;

  std::vector<Edge> getEdges() const;
  // pre: the circuit is solved
  proto::CircuitGraph toProto() const;
  proto::CircuitGraph toProto(const double* parameters) const;
  static std::optional<std::unique_ptr<CircuitGraph>> fromProto(
      const proto::CircuitGraph& proto);
  /**
   * Compares two CircuitGraphs for equality.
   *
   * Two graphs, g1 and g2, are considered equal if
   * - For each vertex v in g1, there exists a vertex u in g2 with the same id
   * such that if v is known then u is known and has the same value; if v is not
   * known then u is not known either.
   * - For each Edge e in g1, there exists an edge f in g2 with the same id that
   * goes between vertices with the same ids and is of the same Branch type.
   */
  bool operator==(const CircuitGraph& other) const;

  partitionSolution solvePartition(const std::vector<double*>& basis,
                                   const std::vector<bool>& isHigh);
  void print(std::ostream& out, const CircuitGraph& cg,
             std::unordered_set<const double*> parameters);

 private:
  std::vector<double*> getDiscontinuities();
  void resetUnknowns();
  std::unordered_set<const double*> getUnknowns();
  /**
   * Get the sum of the currents going into/out of a node
   * @param node - the node to get the currents for
   * @param unknowns - a vector containing the unknowns for the graph
   * @return a function object for a function that takes in the necessary
   * arguments and return net current into the node
   * @pre node is in this.graph
   */
  Expression getNodeCurrents(Vertex node);

  std::vector<Expression> getExpressions();

  /**
   * Get the `Vertex` corresponding to `id`
   *
   * @param id the id of the `Vertex`
   * @throws std::out_of_range if no `Vertex` with `id` is a member of `this`
   */
  // Vertex getVertex(int id);

  /**
   * Get the `Edge` corresponding to `id`
   *
   * @param id the id of the `Edge`
   * @throws std::out_of_range if no `Edge` with `id` is a member of `this`
   */
  // Edge& getEdge(int id);

  /**
   * An adjacency list representation of the graph using vertex id -> edge id
   */
  std::unordered_map<uuids::uuid, std::vector<uuids::uuid>> adjacencyList;

  /**
   * Map of vertex id to vertex
   */
  VertexMap vertices;

  /**
   * Map of edge id to edge
   */
  EdgeMap edges;

  int solveAttempts = 0;
  const int maxSolveAttempts = 100;  // High but bounded
};

std::ostream& operator<<(std::ostream& out, const CircuitGraph& cg);

#endif  // CIRCUIT_GRAPH_H
