# Circuit Solver

[![codecov](https://codecov.io/github/rafe-murray/circuitsolver/graph/badge.svg?token=E7B6WRPST1)](https://codecov.io/github/rafe-murray/circuitsolver)

Circuit Solver is a cross-platform app to solve circuits

## Components

| Component                            | Status    | Directory                 |
| ------------------------------------ | --------- | ------------------------- |
| C++ Solving Library                  | Alpha     | [native_lib](/native_lib) |
| Solver service                       | Alpha     | [backend](/backend)       |
| Dart FFI wrapper for solving library | Alpha     | [ffi_bridge](/ffi_bridge) |
| Frontend                             | Pre-Alpha | [frontend](/frontend)     |

## Installing

Once the frontend is in alpha, releases will be made to GitHub. Until then, you
will have to build from source.

### Building from source

This is a flutter project, but it also requires an up-to-date Clang compiler
toolchain to build the C++ library.

You'll need a copy of the source code regardless of OS:

```sh
git clone git@github.com:rafe-murray/circuitSolver.git
```

#### macOs

Install prerequisites:

```sh
brew install cmake llvm flutter vcpkg
```

Build the application:

```sh
cd circuitSolver/frontend
flutter build macos
```

Install it:

```sh
flutter install
```

And open it (you can also use spotlight search):

```sh
open -a frontend
```
