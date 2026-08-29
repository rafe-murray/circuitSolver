FROM ubuntu:26.10 AS builder

RUN set -eux; \
  apt-get update; \
  apt-get install -y \
  clangd \
  cmake \
  ninja-build \
  libpistache-dev \
  build-essential \
  tar \
  git \
  zip \
  unzip \
  curl \
  pkg-config \
  clang \
  \
  ripgrep \
  ; \
  git clone https://github.com/microsoft/vcpkg.git --depth 1; \
  ./vcpkg/bootstrap-vcpkg.sh;
