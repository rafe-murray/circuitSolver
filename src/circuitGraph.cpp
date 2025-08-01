#include "circuitsolver/circuitGraph.h"
#include "circuitsolver/components/currentSource.h"
#include "circuitsolver/components/edge.h"
#include "circuitsolver/components/resistor.h"
#include "circuitsolver/components/vertex.h"
#include "circuitsolver/components/voltageSource.h"
#include "circuitsolver/math/expression.h"
#include "circuitsolver/math/expressionCostFunction.h"
#include <memory>
#include <rapidjson/document.h>
#include <rapidjson/filereadstream.h>
#include <rapidjson/rapidjson.h>
#include <rapidjson/reader.h>
#include <rapidjson/schema.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>
#include <stdexcept>
#include <vector>

Expression CircuitGraph::getErrorExpression() {
  Expression error(0.0);
  for (Vertex node : getVertices()) {
    Expression netCurrent = getNodeCurrents(node);
    error = error + netCurrent * netCurrent;
  }
  for (shared_ptr<Edge> edge : getEdges()) {
    Expression constraint = edge->getConstraint();
    error = error + constraint * constraint;
  }
  return error;
}

void CircuitGraph::solveCircuit() {
  ceres::Problem problem;
  cout << "Current expressions: " << endl;
  for (Vertex node : getVertices()) {
    if (node.getVoltage().isConstant())
      continue;
    Expression netCurrent = getNodeCurrents(node);
    vector<double*> unknowns = netCurrent.getUnknownVals();
    ceres::CostFunction* costFunction = netCurrent.getCostFunction();
    problem.AddResidualBlock(costFunction, nullptr, unknowns);
    cout << netCurrent << endl;
  }
  cout << "Constraint expressions: " << endl;
  for (shared_ptr<Edge> edge : getEdges()) {
    Expression constraint = edge->getConstraint();
    vector<double*> unknowns = constraint.getUnknownVals();
    ceres::CostFunction* costFunction = constraint.getCostFunction();
    problem.AddResidualBlock(costFunction, nullptr, unknowns);
    cout << constraint << endl;
  }
  ceres::Solver::Options options;
  options.linear_solver_type = ceres::DENSE_QR;
  options.minimizer_type = ceres::TRUST_REGION;
  /*options.use_nonmonotonic_steps = true;*/
  options.logging_type = ceres::SILENT;
  /*options.minimizer_progress_to_stdout = true;*/
  /*options.function_tolerance = 0;*/
  /*options.gradient_tolerance = 0;*/
  /*options.parameter_tolerance = 0;*/
  /*options.max_num_iterations = INT_MAX;*/
  ceres::Solver::Summary summary;
  Solve(options, &problem, &summary);
  cout << summary.FullReport() << endl;
}
Expression CircuitGraph::getNodeCurrents(Vertex node) {
  Expression nodeCurrents(0.0);
  for (shared_ptr<Edge> branch : getIncident(node)) {
    Expression current = branch->getCurrent();
    if (branch->getV1() == node) {
      nodeCurrents = nodeCurrents - current;
    } else {
      nodeCurrents = nodeCurrents + current;
    }
  }
  return nodeCurrents;
}
Vertex CircuitGraph::getVertex(int id) { return vertices.at(id); }
shared_ptr<Edge> CircuitGraph::getEdge(int id) { return edges.at(id); }
bool CircuitGraph::addVertex(const Vertex& v) {
  // Only add the vertex if it doesn't already exist
  if (adjacencyList.count(v) == 0) {
    adjacencyList[v] = unordered_map<Vertex, shared_ptr<Edge>>();
    vertices[v.getId()] = v;
    return true;
  }
  return false;
}

bool CircuitGraph::removeVertex(const Vertex& v) {
  if (adjacencyList.count(v) == 0)
    return false;

  // Remove the vertex from all adjacency lists
  for (auto it = adjacencyList.begin(); it != adjacencyList.end(); it++) {
    it->second.erase(v);
  }

  // Remove the vertex itself
  adjacencyList.erase(v);
  vertices.erase(v.getId());
  return true;
}

bool CircuitGraph::addEdge(shared_ptr<Edge> e) {
  Vertex v1 = e->getV1();
  Vertex v2 = e->getV2();

  // If either vertex is not present return false
  if (!adjacencyList.count(v1) || !adjacencyList.count(v2))
    return false;

  // If the edge already exists, return false
  if (adjacencyList[v1].count(v2) > 0)
    return false;

  // Add the edge in both directions
  adjacencyList[v1][v2] = e;
  adjacencyList[v2][v1] = e;
  edges[e->getId()] = e;
  return true;
}

// NOTE: this is probably slightly less efficient since we have to fetch the
// Edge again, but it is easier to maintain
bool CircuitGraph::removeEdge(shared_ptr<Edge> e) {
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

vector<shared_ptr<Edge>> CircuitGraph::getIncident(const Vertex& v) {
  vector<shared_ptr<Edge>> edges;
  auto it1 = adjacencyList.find(v);
  if (it1 != adjacencyList.end()) {
    unordered_map<Vertex, shared_ptr<Edge>> edgeMap = it1->second;
    for (auto it2 = edgeMap.begin(); it2 != edgeMap.end(); it2++) {
      edges.push_back(it2->second);
    }
  }
  return edges;
}

vector<Vertex> CircuitGraph::getVertices() const {
  vector<Vertex> vertexList;
  vertexList.reserve(adjacencyList.size());
  for (auto el : vertices) {
    vertexList.push_back(el.second);
  }
  return vertexList;
}

vector<shared_ptr<Edge>> CircuitGraph::getEdges() const {
  vector<shared_ptr<Edge>> edgeList;
  edgeList.reserve(edges.size());
  for (auto el : edges) {
    edgeList.push_back(el.second);
  }
  return edgeList;
}

CircuitGraph* CircuitGraph::fromJson(const string& json) {
  // Read the schema from a file
  FILE* fp = fopen("circuitGraphSchema.json", "rb");

  char readBuffer[4096];
  rapidjson::FileReadStream is(fp, readBuffer, sizeof(readBuffer));

  rapidjson::Document sd;
  sd.ParseStream(is);
  fclose(fp);
  if (sd.HasParseError()) {
    throw runtime_error("Invalid JSON schema");
  }
  rapidjson::SchemaDocument schema(sd);

  rapidjson::Document doc;
  doc.Parse(json.c_str());
  if (doc.HasParseError()) {
    throw invalid_argument("Invalid JSON syntax for graph");
  }

  rapidjson::SchemaValidator validator(schema);
  if (!doc.Accept(validator)) {
    rapidjson::StringBuffer sb;
    validator.GetInvalidSchemaPointer().StringifyUriFragment(sb);
    string errorMessage =
        (string) "Invalid schema: " + sb.GetString() + "\n" +
        "Invalid keyword: " + validator.GetInvalidSchemaKeyword() + "\n";
    sb.Clear();
    validator.GetInvalidDocumentPointer().StringifyUriFragment(sb);
    errorMessage += (string) "Invalid document: " + sb.GetString() + "\n";
    throw invalid_argument(errorMessage);
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
    string type = edges[i]["type"].GetString();
    if (type == "voltageSource") {
      auto voltage = edges[i].FindMember("voltage");
      if (voltage != edges[i].MemberEnd()) {
        auto vs = make_shared<VoltageSource>(id, from, to,
                                             voltage->value.GetDouble());
        cg->addEdge(vs);
      } else {
        auto vs = make_shared<VoltageSource>(id, from, to);
        cg->addEdge(vs);
      }
    } else if (type == "currentSource") {
      auto current = edges[i].FindMember("current");
      if (current != edges[i].MemberEnd()) {
        auto cs = make_shared<CurrentSource>(id, from, to,
                                             current->value.GetDouble());
        cg->addEdge(cs);
      } else {
        auto cs = make_shared<CurrentSource>(id, from, to);
        cg->addEdge(cs);
      }
    } else if (type == "resistor") {
      auto resistance = edges[i].FindMember("resistance");
      if (resistance != edges[i].MemberEnd()) {
        auto cs = make_shared<CurrentSource>(id, from, to,
                                             resistance->value.GetDouble());
        cg->addEdge(cs);
      } else {
        auto cs = make_shared<CurrentSource>(id, from, to);
        cg->addEdge(cs);
      }
    } else {
      throw invalid_argument("Invalid branch type: " + type);
    }
    // add the edges to the graph
  }
  return cg;
}

string CircuitGraph::toJson() const {
  rapidjson::Document doc;
  doc.SetObject();
  auto& allocator = doc.GetAllocator();
  rapidjson::Value vertexList(rapidjson::kArrayType);
  for (Vertex vertex : getVertices()) {
    vertexList.PushBack(vertex.toJson(allocator), allocator);
  }
  rapidjson::Value edgeList(rapidjson::kArrayType);
  for (shared_ptr<Edge> edge : getEdges()) {
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
