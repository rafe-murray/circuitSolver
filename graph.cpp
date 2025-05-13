#include "graph.h"
#include <vector>

template <typename V, typename E>
Graph<V, E>::Graph() : adjacencyList(unordered_map<V, unordered_map<V, E>>()) {}

template <typename V, typename E> bool Graph<V, E>::addVertex(V v) {
  // Only add the vertex if it doesn't already exist
  if (adjacencyList.count(v) == 0) {
    adjacencyList[v] = unordered_map<V, E>();
    return true;
  }
  return false;
}

template <typename V, typename E> bool Graph<V, E>::removeVertex(V v) {
  if (adjacencyList.count(v) == 0)
    return false;

  // Remove the vertex from all adjacency lists
  for (auto &[otherV, neighbors] : adjacencyList) {
    neighbors.erase(v);
  }

  // Remove the vertex itself
  adjacencyList.erase(v);
  return true;
}

template <typename V, typename E> bool Graph<V, E>::addEdge(E e) {
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

template <typename V, typename E> bool Graph<V, E>::removeEdge(E e) {
  return removeEdge(e.v1, e.v2);
}

template <typename V, typename E> bool Graph<V, E>::removeEdge(V v1, V v2) {
  if (adjacencyList.count(v1) && adjacencyList[v1].count(v2)) {
    adjacencyList[v1].erase(v2);
    adjacencyList[v2].erase(v1);
    return true;
  }
  return false;
}

template <typename V, typename E> vector<E> Graph<V, E>::getIncident(V v) {
  vector<E> edges;
  if (adjacencyList.count(v)) {
    for (const auto &[neighbor, edge] : adjacencyList[v]) {
      edges.push_back(edge);
    }
  }
  return edges;
}

template <typename V, typename E> vector<V> Graph<V, E>::getVertices() const {
  vector<V> vertices;
  for (const auto &[v, _] : adjacencyList) {
    vertices.push_back(v);
  }
  return vertices;
}
