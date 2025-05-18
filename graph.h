#ifndef GRAPH_H
#define GRAPH_H

#include <unordered_map>
#include <unordered_set>
#include <vector>

using namespace std;

/**
 * An adjacency list representation of a graph
 */
template <typename V, typename E> class Graph {
public:
  /**
   * Creates a new graph instance
   */
  Graph() : adjacencyList(unordered_map<V, unordered_map<V, E>>()) {}

  /**
   * Adds a vertex to the graph
   * @param v - the vertex to add
   * @return true on succesful insertion
   */
  bool addVertex(const V &v) {
    // Only add the vertex if it doesn't already exist
    if (adjacencyList.count(v) == 0) {
      adjacencyList[v] = unordered_map<V, E>();
      return true;
    }
    return false;
  }

  /**
   * Removes a vertex from the graph
   * @param v - the vertex to remove
   * @return true if the vertex was part of the graph before and it is no longer
   */
  bool removeVertex(const V &v) {
    if (adjacencyList.count(v) == 0)
      return false;

    // Remove the vertex from all adjacency lists
    for (auto it = adjacencyList.begin(); it != adjacencyList.end(); it++) {
      it->second.erase(v);
    }

    // Remove the vertex itself
    adjacencyList.erase(v);
    return true;
  }

  /**
   * Adds an edge to the graph
   * @param e - the edge to add
   * @return true if the edge was not part of the graph before and now it is
   */
  bool addEdge(const E &e) {
    V v1 = e.v1;
    V v2 = e.v2;

    // If either vertex is not present return false
    if (!adjacencyList.count(v1) || !adjacencyList.count(v2))
      return false;

    // If the edge already exists, return false
    if (adjacencyList[v1].count(v2) > 0)
      return false;

    // Add the edge in both directions
    adjacencyList[v1][v2] = e;
    adjacencyList[v2][v1] = e;
    return true;
  }

  /**
   * Removes an edge from the graph
   * @param e - the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  bool removeEdge(const E &e) { return removeEdge(e.v1, e.v2); }

  /**
   * Removes an edge from the graph
   * @param v1 - one endpoint of the edge to remove
   * @param v2 - the other endpoint of the edge to remove
   * @return true if the edge was in the graph before and it is no longer
   */
  bool removeEdge(const V &v1, const V &v2) {
    if (adjacencyList.count(v1) && adjacencyList[v1].count(v2)) {
      adjacencyList[v1].erase(v2);
      adjacencyList[v2].erase(v1);
      return true;
    }
    return false;
  }

  /**
   * Gets all edges incident on a vertex. An edge is considered incident on a
   * vertex v if one of the edge's endpoints is v
   * @param v - the vertex which the edges are incident on
   * @return a vector containing all incident edges
   */
  vector<E> getIncident(const V &v) const {
    vector<E> edges;
    auto it1 = adjacencyList.find(v);
    if (it1 != adjacencyList.end()) {
      unordered_map<V, E> edgeMap = it1->second;
      for (auto it2 = edgeMap.begin(); it2 != edgeMap.end(); it2++) {
        edges.push_back(it2->second);
      }
    }
    return edges;
  }

  /**
   * Gets all vertices in the graph
   * @return a vector containing all the vertices in the graph
   */
  vector<V> getVertices() const {
    vector<V> vertices;
    for (auto it = adjacencyList.begin(); it != adjacencyList.end(); it++) {
      vertices.push_back(it->first);
    }
    return vertices;
  }

  unordered_set<E> getEdges() const {
    unordered_set<E> edges;
    for (auto it1 = adjacencyList.begin(); it1 != adjacencyList.end(); it1++) {
      for (auto it2 = it1->second.begin(); it2 != it1->second.end(); it2++) {
        edges.insert(it2->second);
      }
    }
    return edges;
  }

private:
  /**
   * An adjacency list representation of the graph
   */
  unordered_map<V, unordered_map<V, E>> adjacencyList;
};

#endif
