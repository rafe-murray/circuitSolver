#ifndef CIRCUIT_GRAPH_H
#define CIRCUIT_GRAPH_H

#include <memory>
#include <unordered_map>

#include "edge.h"
#include "expression.h"
#include "vertex.h"

// TODO: add error handling for:
//  - Cases where there are too few equations for the number of unknowns
//  - Cases where there is no solution (e.g. no possible intersection)
//  - Maybe include the relative tolerance in the printed results
//  TODO: update this
//  Ideas:
//    - use vector<vector<int>> for adjacencyList (vertex -> edge) since we have
//    control over ids and can make them *very* dense
//    - make ids unsigned
//    - Keep two unordered_maps for Vertex and Edge lookup
//    - Store the vertices for an edge as ids
//    - Make Edge a wrapper for the polymorphic branch types -> easier
//    serialization
//      - Use std::variant() with a list of all the types

typedef std::shared_ptr<Edge> EdgePtr;
class CircuitGraph {
 public:
  Expression getErrorExpression();
  ceres::Solver::Summary solveCircuit();

  /**
   * Creates a new graph instance
   */
  CircuitGraph()
      : adjacencyList(
            std::unordered_map<Vertex, std::unordered_map<Vertex, EdgePtr>>()) {
  }

  /**
   * Adds a vertex to the graph
   * @param v - the vertex to add
   * @return true on successful insertion
   */
  bool addVertex(const Vertex& v);

  /**
   * Removes a vertex from the graph
   * @param v - the vertex to remove
   * @return true if the vertex was part of the graph before and it is no longer
   */
  bool removeVertex(const Vertex& v);

  /**
   * Adds an edge to the graph
   * @param e - the edge to add
   * @return true if the edge was not part of the graph before and now it is
   */
  bool addEdge(EdgePtr e);

  /**
   * Removes an edge from the graph
   * @param e - the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  bool removeEdge(EdgePtr e);

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
  std::vector<EdgePtr> getIncident(const Vertex& v);

  /**
   * Gets all vertices in the graph
   * @return a vector containing all the vertices in the graph
   */
  std::vector<Vertex> getVertices() const;

  std::vector<EdgePtr> getEdges() const;

  // pre: the circuit is solved
  std::string toJson() const;
  static CircuitGraph* fromJson(const std::string& json);

 private:
  /**
   * Get the sum of the currents going into/out of a node
   * @param node - the node to get the currents for
   * @param unknowns - a vector containing the unknowns for the graph
   * @return a function object for a function that takes in the necessary
   * arguments and return net current into the node
   * @pre node is in this.graph
   */
  Expression getNodeCurrents(Vertex node);

  /**
   * Get the `Vertex` corresponding to `id`
   *
   * @param id the id of the `Vertex`
   * @throws std::out_of_range if no `Vertex` with `id` is a member of `this`
   */
  Vertex getVertex(int id);

  /**
   * Get the `Edge` corresponding to `id`
   *
   * @param id the id of the `Edge`
   * @throws std::out_of_range if no `Edge` with `id` is a member of `this`
   */
  EdgePtr getEdge(int id);

  /**
   * Get the reference node for the graph
   */
  Expression getRef();

  /**
   * An adjacency list representation of the graph
   */
  std::unordered_map<Vertex, std::unordered_map<Vertex, EdgePtr>> adjacencyList;

  /**
   * Map of vertex id to vertex
   */
  std::unordered_map<int, Vertex> vertices;

  /**
   * Map of edge id to edge
   */
  std::unordered_map<int, EdgePtr> edges;
};

#endif  // !CIRCUIT_GRAPH_H
