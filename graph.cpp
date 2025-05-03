#include "graph.h"
#include <unordered_map>

template <typename V, typename E>
Graph<V, E>::Graph() : adjacencyList(unordered_map<V, unordered_map<V, E>>()) {}

template <typename V, typename E> bool Graph<V, E>::addVertex(V v) {
  return adjacencyList.insert(make_pair(v, unordered_map<V, E>())).second;
}

template <typename V, typename E> bool Graph<V, E>::removeVertex(V v) {
  // TODO: implement this method
}

// TODO: implement remaining methods from graph.h
