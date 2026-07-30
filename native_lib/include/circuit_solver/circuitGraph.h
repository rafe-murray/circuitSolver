#ifndef CIRCUIT_GRAPH_H
#define CIRCUIT_GRAPH_H

#include <memory>
#include <ostream>
#include <unordered_map>

#include "circuit_solver/edge.h"
#include "circuit_solver/expression.h"
#include "circuit_solver/proto.h"
#include "circuit_solver/vertex.h"

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
  auto solveCircuit() -> bool;

  /**
   * Creates a new graph instance
   */
  CircuitGraph() {}

  /**
   * Adds a vertex to the graph
   * @param v - the vertex to add
   * @return true on successful insertion
   */
  auto addVertex(const Vertex& v) -> bool;

  auto hasVertex(const Vertex& v) -> bool;

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
  auto addEdge(std::unique_ptr<Edge> e) -> bool;

  auto addEdge(const Edge& e) -> bool {
    return addEdge(std::make_unique<Edge>(e));
  };

  auto hasEdge(const Edge& e) -> bool;

  /**
   * Removes an edge from the graph
   * @param e - the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  auto removeEdge(const Edge& e) -> bool;

  /**
   * Removes an edge from the graph
   * @param v1 - one endpoint of the edge to remove
   * @param v2 - the other endpoint of the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  auto removeEdge(const Vertex& v1, const Vertex& v2) -> bool;

  /**
   * Gets all edges incident on a vertex. An edge is considered incident on a
   * vertex v if one of the edge's endpoints is v
   * @param v - the vertex which the edges are incident on
   * @return a vector containing all incident edges
   */
  auto getIncident(const Vertex& v) -> std::vector<Edge>;

  /**
   * Gets all vertices in the graph
   * @return a vector containing all the vertices in the graph
   */
  [[nodiscard]] auto getVertices() const -> std::vector<Vertex>;

  [[nodiscard]] auto getEdges() const -> std::vector<Edge>;
  // pre: the circuit is solved
  [[nodiscard]] auto toProto() const -> proto::CircuitGraph;
  auto toProto(const double* parameters) const -> proto::CircuitGraph;
  static auto fromProto(const proto::CircuitGraph& proto)
      -> std::optional<std::unique_ptr<CircuitGraph>>;
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
  auto operator==(const CircuitGraph& other) const -> bool;

  auto solvePartition(const std::vector<double*>& basis,
                      const std::vector<bool>& isHigh) -> partitionSolution;
  static void print(std::ostream& out, const CircuitGraph& cg,
                    const std::unordered_set<const double*>& parameters);

 private:
  auto getDiscontinuities() -> std::vector<double*>;
  void resetUnknowns();
  // std::unordered_set<const double*> getUnknowns();
  /**
   * Get the sum of the currents going into/out of a node
   * @param node - the node to get the currents for
   * @param unknowns - a vector containing the unknowns for the graph
   * @return a function object for a function that takes in the necessary
   * arguments and return net current into the node
   * @pre node is in this.graph
   */
  auto getNodeCurrents(const Vertex& node) -> Expression;

  auto getExpressions() -> std::vector<Expression>;

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

auto operator<<(std::ostream& out, const CircuitGraph& cg) -> std::ostream&;

#endif  // CIRCUIT_GRAPH_H
