#include "components/edge.h"
#include "components/vertex.h"
#include "math/expression.h"
#include <unordered_map>

// TODO: add error handling for:
//  - Cases where there are too few equations for the number of unknowns
//  - Cases where there is no solution (e.g. no possible intersection)
//  - Maybe include the relative tolerance in the printed results

class CircuitGraph {
public:
  Expression getErrorExpression();
  void solveCircuit();

  /**
   * Creates a new graph instance
   */
  CircuitGraph()
      : adjacencyList(unordered_map<Vertex, unordered_map<Vertex, Edge>>()) {}

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
  bool addEdge(const Edge& e);

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
  vector<Edge> getIncident(const Vertex& v);

  /**
   * Gets all vertices in the graph
   * @return a vector containing all the vertices in the graph
   */
  vector<Vertex> getVertices() const;

  vector<Edge> getEdges() const;

  // pre: the circuit is solved
  string toJson() const;
  static CircuitGraph* fromJson(const string& json);

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
  Edge getEdge(int id);

  /**
   * Get the reference node for the graph
   */
  Expression getRef();

  /**
   * An adjacency list representation of the graph
   */
  unordered_map<Vertex, unordered_map<Vertex, Edge>> adjacencyList;

  /**
   * Map of vertex id to vertex
   */
  unordered_map<int, Vertex> vertices;

  /**
   * Map of edge id to edge
   */
  unordered_map<int, Edge> edges;
};
