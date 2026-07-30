ARG VCPKG_CACHE_DIR=/cache/vcpkg

FROM ubuntu:26.10 AS builder

ARG VCPKG_CACHE_DIR
ENV VCPKG_DOWNLOADS=${VCPKG_CACHE_DIR}

# TODO: improve caching

RUN set -eux; \
  mkdir -p "$VCPKG_CACHE_DIR"; \
  apt-get update; \
  apt-get install -y \
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
  ; \
  git clone https://github.com/microsoft/vcpkg.git --depth 1; \
  ./vcpkg/bootstrap-vcpkg.sh; \
  mkdir -p /circuitsolver;

COPY . /circuitsolver

WORKDIR /circuitsolver/backend

RUN \
  --mount=type=cache,target=/circuitsolver/backend/build \
  --mount=type=cache,target="$VCPKG_CACHE_DIR" \
  set -eux; \
  export VCPKG_ROOT="/vcpkg"; \
  mkdir -p build; \
  cd build; \
  cmake .. \
  --preset=vcpkg \
  -DVCPKG_MANIFEST_FEATURES="otlp" \
  -DCMAKE_BUILD_TYPE=Release \
  -DVCPKG_BUILD_TYPE=release \
  ; \
  cmake --build . ; \
  cp circuit-solver ../ ; \
  cp compile_commands.json ../

FROM scratch as exporter
COPY --from=builder /circuitsolver/backend/compile_commands.json /

FROM gcr.io/distroless/cc-debian13 AS base

COPY --from=builder /circuitsolver/backend/circuit-solver /
COPY --from=builder /usr/lib/aarch64-linux-gnu/libpistache.so.0.4 /usr/lib/aarch64-linux-gnu/
ENTRYPOINT [ "/circuit-solver" ]

