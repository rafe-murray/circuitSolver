FROM ubuntu:20.04

RUN \
  apt-get update && \
  # CMake
  apt-get install -y cmake && \
  # google-glog + gflags
  apt-get install -y libgoogle-glog-dev libgflags-dev && \
  # Use ATLAS for BLAS & LAPACK
  apt-get install -y libatlas-base-dev && \
  # Eigen3
  apt-get install -y libeigen3-dev && \
  # SuiteSparse (optional)
  apt-get install -y libsuitesparse-dev && \
  # git
  apt-get install -y git && \
  apt-get install -y curl unzip &&\
  apt-get install -y g++
RUN mkdir circuitSolver
COPY . /circuitSolver
WORKDIR /circuitSolver

RUN \
  cmake . &&\
  mkdir build && cd build && \
  cmake --build ..
