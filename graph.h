#include <cstdlib>
#include <unordered_map>
using namespace std;
/**
 * An adjacency list representation of a graph
 */
template <typename V, typename E> class Graph {
public:
  /**
   * Creates a new graph instance
   */
  Graph();

  /**
   * Adds a vertex to the graph
   * @param v - the vertex to add
   * @return true on succesful insertion
   */
  bool addVertex(V v);

  /**
   * Removes a vertex from the graph
   * @param v - the vertex to remove
   * @return true if the vertex was part of the graph before and it is no longer
   */
  bool removeVertex(V v);

  /**
   * Adds an edge to the graph
   * @param e - the edge to add
   * @return true if the edge was not part of the graph before and now it is
   */
  bool addEdge(E e);

  /**
   * Removes an edge from the graph
   * @param e - the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  bool removeEdge(E e);

  /**
   * Removes an edge from the graph
   * @param v1 - one endpoint of the edge to remove
   * @param v2 - the other endpoint of the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  bool removeEdge(V v1, V v2);

  /**
   * Gets all edges incident on a vertex. An edge is considered incident on a
   * vertex v if one of the edge's endpoints is v
   * @param v - the vertex which the edges are incident on
   * @return a vector containing all incident edges
   */
  vector<E> getIncident(V v);

  /**
   * Gets all vertices in the graph
   * @return a vector containing all the vertices in the graph
   */
  vector<V> getVertices();

private:
  /**
   * An adjacency list representation of the graph
   */
  unordered_map<V, unordered_map<V, E>> adjacencyList;
};
