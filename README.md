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

# Ceres Solver and dependencies
brew install ceres-solver
# google-glog and gflags
brew install glog gflags
# Eigen3
brew install eigen
# SuiteSparse
brew install suite-sparse

# Protoc (compiler for protobufs)
brew install protoc

# Pistache
brew install pistache
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
make
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
make
```

Finally, run the compiled executable

```bash
./solver
```

## Development Roadmap

The goal for this project is for it to be an interactive tool to allow users to
solve circuits.

The idea is to expose a REST api that accepts a JSON representation of a circuit,
parses that into a `CircuitGraph` object, and then solves the circuit for all
the voltages and currents. A response is then sent back to the client with all
the required information to map these values back onto the circuit they sent the
server.

On the client side, it will probably be a react app with drag and drop snap
controls to build a circuit. Once that is built, appropriate keyboard shortcuts
can be added to the interface to make it easier to use.
