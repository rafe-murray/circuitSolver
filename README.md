# Circuit Solver

Solve arbitrary circuits for their voltages and currents. This project is
currently still in development, so the code will not be working yet.
To test it out for yourself or check out the direction of the project, see below.

## Compiling from Source

Note: these instructions are for unix-based machines; no guarantees are made
that they will work on windows. Additionally, the source code requires a C++17
compliant compiler.

Circuit Solver is dependent on several external libraries, so you must first
install them on your system.

### MacOS (using homebrew)

```bash
# CMake
brew install cmake

# Ceres Solver and its dynamically linked dependencies
brew install ceres-solver
# google-glog and gflags
brew install glog gflags
# Eigen3
brew install eigen
# SuiteSparse
brew install suite-sparse

# Protoc (compiler for protobufs)
brew install protoc
```

Next, clone the repo on your local machine

```bash
git clone https://github.com/rafe-murray/circuitSolver.git
```

Then generate the compilation commands and run them

```bash
cd circuitSolver
mkdir build
cd build
cmake ..
cmake --build .
```

Finally, run the compiled executable

```bash
./solver
```

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install rapidjson
sudo apt-get install pistache
```

Note: there is a package for ceres on ubuntu but it isn't mentioned in the documentation
instead they recommend compiling/installing yourself from the source code
If you use another package manager, refer to each project's respective documentation:

- [Ceres Solver](https://github.com/ceres-solver/ceres-solver)
- [RapidJSON](https://github.com/Tencent/rapidjson)
- [Pistache](https://github.com/pistacheio/pistache)

Next, clone the repo on your local machine

```bash
git clone https://github.com/rafe-murray/circuitSolver.git
```

Then generate the compilation commands and run them

```bash
cd circuitSolver
mkdir build
cd build
cmake ..
cmake --build .
```

Finally, run the compiled executable

```bash
./solver
```

## Usage
Circuit Solver exposes a C API for broad compatibility with other languages. It takes in a serialized protobuf, solves the given circuit, and returns a newly serialized protobuf representing the solved circuit. The protobuf interface is defined in [circuitGraphMessage.proto](circuitGraphMessage.proto). The recommended usage pattern is to create a `circuitGraphMessage` using the protobuf bindings in the language of your choice, pass it to the C API, and then read the results back in another `circuitGraphMessage`.

For example, in C++:
```cpp
#include <absl/status/status.h>
#include <circuitGraph/api.h>
#include <cstddef>
#include <google/protobuf/util/json_util.h>
#include "circuitGraphMessage.pb.h" // You need to generate this file with protoc

int main() {
      const std::string circuit = R"({
                                       "edges": [
                                         {
                                           "id": 0,
                                           "fromId": 0,
                                           "toId": 1,
                                           "voltageSource": {
                                             "voltage": 5
                                           }
                                         },
                                         {
                                           "id": 1,
                                           "fromId": 1,
                                           "toId": 2,
                                           "resistor": {
                                             "resistance": 2
                                           }
                                         },
                                         {
                                           "id": 2,
                                           "fromId": 2,
                                           "toId": 0,
                                           "resistor": {
                                             "resistance": 3
                                           }
                                         }
                                       ],
                                       "vertices": [
                                         {
                                           "id": 0,
                                           "voltage": 0
                                         },
                                         {
                                           "id": 1
                                         },
                                         {
                                           "id": 2
                                         }
                                       ]
                                     }
                                     )";
      circuitsolver::CircuitGraphMessage cgm;
      absl::Status status =
      google::protobuf::json::JsonStringToMessage(circuit, &cgm);
      if (!status.ok()) {
    std::cout << "Could not parse circuit graph from JSON" << std::endl;
    return 1;
  }
  size_t bufferLength = cgm.ByteSizeLong();
      void *buffer = operator new(bufferLength);
      void *output;
      size_t outputLength;
      int result = processGraph(buffer, bufferLength, &output, &outputLength);
      if (result) {
    std::cout << "Could not solve circuit: " << getErrorMessage(result) << std::endl;
    return 1;
  }
  circuitsolver::CircuitGraphMessage solvedMessage;
      solvedMessage.ParseFromArray(output, outputLength);
  std::string solvedCircuitJson;
      status =
      google::protobuf::json::MessageToJsonString(solvedMessage, &solvedCircuitJson);
  if (!status.ok()) {
    std::cout << "Could not convert solution to JSON" << std::endl;
  }
  std::cout << solvedCircuitJson << std::endl;
  return 0;
}
```


## Development Roadmap

The goal for this project is for it to be an interactive tool to allow users to
solve circuits.

The idea is to expose a REST API that accepts a JSON representation of a circuit,
parses that into a `CircuitGraph` object, and then solves the circuit for all
the voltages and currents. A response is then sent back to the client with all
the required information to map these values back onto the circuit they sent the
server.

On the client side, it will probably be a react app with drag and drop snap
controls to build a circuit. Once that is built, appropriate keyboard shortcuts
can be added to the interface to make it easier to use.
