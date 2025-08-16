#include "circuitsolver/circuitGraph.h"

#include <rapidjson/document.h>
#include <rapidjson/filereadstream.h>
#include <rapidjson/rapidjson.h>
#include <rapidjson/reader.h>
#include <rapidjson/schema.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

#include <memory>
#include <stdexcept>
#include <vector>

#include "circuitsolver/edge.h"
#include "circuitsolver/expression.h"
#include "circuitsolver/vertex.h"

// TODO: reorganize this file
Expression CircuitGraph::getErrorExpression() {
  Expression error = 0;
  for (Vertex node : getVertices()) {
    Expression netCurrent = getNodeCurrents(node);
    error += netCurrent * netCurrent;
  }
  for (EdgePtr edge : getEdges()) {
    Expression constraint = edge->getConstraint();
    error += constraint * constraint;
  }
  return error;
}

ceres::Solver::Summary CircuitGraph::solveCircuit() {
  ceres::Problem problem;
  for (Vertex node : getVertices()) {
    if (node.getVoltage().isConstant()) continue;
    Expression netCurrent = getNodeCurrents(node);
    netCurrent.addToProblem(problem);
  }
  for (EdgePtr edge : getEdges()) {
    Expression constraint = edge->getConstraint();
    constraint.addToProblem(problem);
  }
  ceres::Solver::Options options = getDefaultOptions();
  ceres::Solver::Summary summary;
  ceres::Solve(options, &problem, &summary);
  return summary;
}
Expression CircuitGraph::getNodeCurrents(Vertex node) {
  Expression nodeCurrents = 0;
  for (EdgePtr branch : getIncident(node)) {
    Expression current = branch->getCurrent();
    if (branch->getV1() == node) {
      nodeCurrents -= current;
    } else {
      nodeCurrents += current;
    }
  }
  return nodeCurrents;
}
Vertex CircuitGraph::getVertex(int id) { return vertices.at(id); }
EdgePtr CircuitGraph::getEdge(int id) { return edges.at(id); }
bool CircuitGraph::addVertex(const Vertex& v) {
  // Only add the vertex if it doesn't already exist
  if (adjacencyList.count(v) == 0) {
    adjacencyList[v] = std::unordered_map<Vertex, EdgePtr>();
    vertices[v.getId()] = v;
    return true;
  }
  return false;
}

bool CircuitGraph::removeVertex(const Vertex& v) {
  if (adjacencyList.count(v) == 0) return false;

  // Remove the vertex from all adjacency lists
  for (auto it = adjacencyList.begin(); it != adjacencyList.end(); it++) {
    it->second.erase(v);
  }

  // Remove the vertex itself
  adjacencyList.erase(v);
  vertices.erase(v.getId());
  return true;
}

bool CircuitGraph::addEdge(EdgePtr e) {
  Vertex v1 = e->getV1();
  Vertex v2 = e->getV2();

  // If either vertex is not present return false
  if (!adjacencyList.count(v1) || !adjacencyList.count(v2)) return false;

  // If the edge already exists, return false
  if (adjacencyList[v1].count(v2) > 0) return false;

  // Add the edge in both directions
  adjacencyList[v1][v2] = e;
  adjacencyList[v2][v1] = e;
  edges[e->getId()] = e;
  return true;
}

// NOTE: this is probably slightly less efficient since we have to fetch the
// Edge again, but it is easier to maintain
bool CircuitGraph::removeEdge(EdgePtr e) {
  return removeEdge(e->getV1(), e->getV2());
}

bool CircuitGraph::removeEdge(const Vertex& v1, const Vertex& v2) {
  if (adjacencyList.count(v1) && adjacencyList[v1].count(v2)) {
    int id = adjacencyList[v1][v2]->getId();
    adjacencyList[v1].erase(v2);
    adjacencyList[v2].erase(v1);
    edges.erase(id);
    return true;
  }
  return false;
}

std::vector<EdgePtr> CircuitGraph::getIncident(const Vertex& v) {
  std::vector<EdgePtr> edges;
  auto it1 = adjacencyList.find(v);
  if (it1 != adjacencyList.end()) {
    std::unordered_map<Vertex, EdgePtr> edgeMap = it1->second;
    for (auto it2 = edgeMap.begin(); it2 != edgeMap.end(); it2++) {
      edges.push_back(it2->second);
    }
  }
  return edges;
}

std::vector<Vertex> CircuitGraph::getVertices() const {
  std::vector<Vertex> vertexList;
  vertexList.reserve(adjacencyList.size());
  for (auto el : vertices) {
    vertexList.push_back(el.second);
  }
  return vertexList;
}

std::vector<EdgePtr> CircuitGraph::getEdges() const {
  std::vector<EdgePtr> edgeList;
  edgeList.reserve(edges.size());
  for (auto el : edges) {
    edgeList.push_back(el.second);
  }
  return edgeList;
}

CircuitGraph* CircuitGraph::fromJson(const std::string& json) {
  // Read the schema from a file
  FILE* fp = fopen("circuitGraphSchema.json", "rb");

  char readBuffer[4096];
  rapidjson::FileReadStream is(fp, readBuffer, sizeof(readBuffer));

  rapidjson::Document sd;
  sd.ParseStream(is);
  fclose(fp);
  if (sd.HasParseError()) {
    throw std::runtime_error("Invalid JSON schema");
  }
  rapidjson::SchemaDocument schema(sd);

  rapidjson::Document doc;
  doc.Parse(json.c_str());
  if (doc.HasParseError()) {
    throw std::invalid_argument("Invalid JSON syntax for graph");
  }

  rapidjson::SchemaValidator validator(schema);
  if (!doc.Accept(validator)) {
    rapidjson::StringBuffer sb;
    validator.GetInvalidSchemaPointer().StringifyUriFragment(sb);
    std::string errorMessage =
        (std::string) "Invalid schema: " + sb.GetString() + "\n" +
        "Invalid keyword: " + validator.GetInvalidSchemaKeyword() + "\n";
    sb.Clear();
    validator.GetInvalidDocumentPointer().StringifyUriFragment(sb);
    errorMessage += (std::string) "Invalid document: " + sb.GetString() + "\n";
    throw std::invalid_argument(errorMessage);
  }
  // Since we have validated against the schema we don't need additional
  // validation NOTE: this assumes the schema is strict and up-to-date
  CircuitGraph* cg = new CircuitGraph();
  auto vertices = doc["vertices"].GetArray();
  for (size_t i = 0; i < vertices.Size(); i++) {
    int id = vertices[i]["id"].GetInt();
    auto voltage = vertices[i].FindMember("voltage");
    if (voltage != vertices[i].MemberEnd()) {
      Vertex v(id, voltage->value.GetDouble());
      cg->addVertex(v);
    } else {
      Vertex v(id);
      cg->addVertex(v);
    }
  }
  auto edges = doc["edges"].GetArray();
  for (size_t i = 0; i < edges.Size(); i++) {
    int id = edges[i]["id"].GetInt();
    Vertex from = cg->getVertex(edges[i]["from"].GetInt());
    Vertex to = cg->getVertex(edges[i]["to"].GetInt());
    std::string type = edges[i]["type"].GetString();
    if (type == "voltageSource") {
      auto voltage = edges[i].FindMember("voltage");
      if (voltage != edges[i].MemberEnd()) {
        auto vs = std::make_shared<VoltageSource>(id, from, to,
                                                  voltage->value.GetDouble());
        cg->addEdge(vs);
      } else {
        auto vs = std::make_shared<VoltageSource>(id, from, to);
        cg->addEdge(vs);
      }
    } else if (type == "currentSource") {
      auto current = edges[i].FindMember("current");
      if (current != edges[i].MemberEnd()) {
        auto cs = std::make_shared<CurrentSource>(id, from, to,
                                                  current->value.GetDouble());
        cg->addEdge(cs);
      } else {
        auto cs = std::make_shared<CurrentSource>(id, from, to);
        cg->addEdge(cs);
      }
    } else if (type == "resistor") {
      auto resistance = edges[i].FindMember("resistance");
      if (resistance != edges[i].MemberEnd()) {
        auto cs = std::make_shared<CurrentSource>(
            id, from, to, resistance->value.GetDouble());
        cg->addEdge(cs);
      } else {
        auto cs = std::make_shared<CurrentSource>(id, from, to);
        cg->addEdge(cs);
      }
    } else {
      throw std::invalid_argument("Invalid branch type: " + type);
    }
    // add the edges to the graph
  }
  return cg;
}

std::string CircuitGraph::toJson() const {
  rapidjson::Document doc;
  doc.SetObject();
  auto& allocator = doc.GetAllocator();
  rapidjson::Value vertexList(rapidjson::kArrayType);
  for (Vertex vertex : getVertices()) {
    vertexList.PushBack(vertex.toJson(allocator), allocator);
  }
  rapidjson::Value edgeList(rapidjson::kArrayType);
  for (EdgePtr edge : getEdges()) {
    edgeList.PushBack(edge->toJson(allocator), allocator);
  }
  doc.AddMember("vertices", vertexList, allocator);
  doc.AddMember("edges", edgeList, allocator);

  rapidjson::StringBuffer buffer;
  rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
  doc.Accept(writer);
  return buffer.GetString();
  // Test against schema for validation in tests
}
