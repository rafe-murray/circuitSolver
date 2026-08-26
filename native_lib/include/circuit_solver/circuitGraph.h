#pragma once

#include <ceres/solver.h>
#include <stduuid/uuid.h>

#include <expected>
#include <functional>
#include <memory>
#include <optional>
#include <ostream>
#include <span>
#include <unordered_map>
#include <vector>

#include "circuit_solver/edge.h"
#include "circuit_solver/errors.h"
#include "circuit_solver/expression.h"
#include "circuit_solver/proto.h"
#include "circuit_solver/vertex.h"

// TODO: add error handling for:
//  - Cases where there are too few equations for the number of unknowns
//  - Cases where there is no solution (e.g. no possible intersection)
//  - Maybe include the relative tolerance in the printed results

/// The solution to a single partition of the solution space
struct partitionSolution {
  ceres::Solver::Summary summary;
  std::vector<Expression> expressions;
  std::vector<std::vector<double>> parameters;
};

class CircuitGraph {
 public:
  /// Solves a circuit
  ///
  /// @return a reference to `this` or an error
  auto solveCircuit() -> std::expected<std::reference_wrapper<CircuitGraph>,
                                       circuitsolver::CircuitSolverError>;

  /**
   * Creates a new graph instance
   */
  CircuitGraph() = default;

  /**
   * Adds a vertex to the graph
   * @param v - the vertex to add
   * @return true on successful insertion
   */
  auto addVertex(const Vertex& v) -> bool;

  /// Checks if a `Vertex` is present in the graph
  /// @param v the `Vertex` to check
  auto hasVertex(const Vertex& v) -> bool;

  /**
   * Adds an edge to the graph
   * @param e - the edge to add
   * @return true if the edge was not part of the graph before and now it is
   */
  auto addEdge(std::unique_ptr<Edge> e) -> bool;

  /**
   * Adds an edge to the graph
   * @param e - the edge to add
   * @return true if the edge was not part of the graph before and now it is
   */
  auto addEdge(const Edge& e) -> bool {
    return addEdge(std::make_unique<Edge>(e));
  };

  /// Checks if an `Edge` is present in this graph
  /// @param e the edge to check
  auto hasEdge(const Edge& e) -> bool;

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

  /// Gets all `Edges` in the graph
  /// @return a list of `Edges` present in the graph. Each `Edge` will only
  /// appear once.
  [[nodiscard]] auto getEdges() const -> std::vector<Edge>;
  /// Converts a `CircuitGraph` to its protobuf representation
  /// @pre: the circuit is solved
  [[nodiscard]] auto toProto() const -> proto::CircuitGraph;
  /// Converts a `CircuitGraph` to its protobuf representation
  /// @param parameters the parameters to use for the unknowns
  [[nodiscard]] auto toProto(std::span<const double> parameters) const
      -> proto::CircuitGraph;
  /// Creates a `CircuitGraph` from a protobuf message
  ///
  /// @param proto the protobuf representation of the circuit
  /// @return the circuit from the message or `std::nullopt`
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

  /// Solves a single partition of the solution space
  ///
  /// @param basis a list of variables that act as optimization constraints; for
  /// a given partition each one will be constrained to either above or below 0
  /// @param isHigh a list of `bool`s that correspond to whether a particular
  /// value in `basis` should be held above 0
  /// @return a solution summary. This does not indicate that a solution is
  /// correct
  auto solvePartition(const std::vector<double*>& basis,
                      const std::vector<bool>& isHigh) -> partitionSolution;

  /// Prints a circuit
  ///
  /// @param out the stream to write to
  /// @param cg the circuit to print
  /// @param parameters a list of values to use for the unknowns
  static void print(std::ostream& out, const CircuitGraph& cg,
                    std::span<const double> parameters);
  // TODO: replace with std::ostream implementation

 private:
  /// Get the list of discontinuities for the circuit
  auto getDiscontinuities() -> std::vector<double*>;
  /// Reset the unknowns
  ///
  /// This will seed the unknowns from a random distribution so that different
  /// attempts are more likely to succeed
  void resetUnknowns();
  /**
   * Get the sum of the currents going into/out of a node
   *
   * @param node the node to get the currents for
   * @return a function object for a function that takes in the necessary
   * arguments and return net current into the node
   * @pre node is in `this.vertices`
   */
  auto getNodeCurrents(const Vertex& node) -> Expression;

  /// Get a list of `Expression`s to optimize
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
  static constexpr int maxSolveAttempts = 100;  // High but bounded
};

/// Writes a string representation of a graph
/// @param out the stream to write to
/// @param cg the graph to write
/// @return `out`
auto operator<<(std::ostream& out, const CircuitGraph& cg) -> std::ostream&;
