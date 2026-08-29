ARG VCPKG_CACHE_DIR=/cache/vcpkg

# TODO: use debian 13
FROM ubuntu:26.10 AS deps

ARG VCPKG_CACHE_DIR
ENV VCPKG_DOWNLOADS=${VCPKG_CACHE_DIR}
ARG TARGETARCH
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
  mkdir -p /circuitsolver/backend /circuitsolver/native_lib;

COPY ./backend/vcpkg.json ./backend/vcpkg-configuration.json /circuitsolver/backend/
COPY ./backend/external /circuitsolver/backend/external/
COPY ./native_lib/vcpkg.json ./native_lib/vcpkg-configuration.json /circuitsolver/native_lib/
COPY ./native_lib/vcpkg_port /circuitsolver/native_lib/vcpkg_port/

WORKDIR /circuitsolver/backend

FROM deps as builder

RUN \
  --mount=type=cache,target=/circuitsolver/backend/build \
  --mount=type=cache,target="$VCPKG_CACHE_DIR" \
  set -eux; \
  export VCPKG_ROOT="/vcpkg"; \
  mkdir -p build; \
  cd build; \
  if [ "$TARGETARCH" = "amd64" ]; then \
    triplet='x64-linux-release'; \
  elif [ "$TARGETARCH" = "arm64" ]; then \
    triplet='arm64-linux-release'; \
  else \
    echo 'Unknown target architecture. Supported architectures: [amd64, arm64]'; \
    exit 1; \
  fi; \
  /vcpkg/vcpkg install --triplet="$triplet" --x-feature="otlp";
  
COPY ./backend/CMakeLists.txt /circuitsolver/backend/
COPY ./native_lib/CMakeLists.txt /circuitsolver/native_lib/

RUN  \
  --mount=type=cache,target=/circuitsolver/backend/build \
  --mount=type=cache,target="$VCPKG_CACHE_DIR" \
  set -eux; \
  cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  ;

COPY backend native_lib /circuitsolver/

RUN \
  --mount=type=cache,target=/circuitsolver/backend/build \
  --mount=type=cache,target="$VCPKG_CACHE_DIR" \
  set -eux; \
  cmake --build . ;

FROM gcr.io/distroless/cc-debian13 AS base

COPY --from=builder /circuitsolver/backend/circuit-solver /
COPY --from=builder /usr/lib/aarch64-linux-gnu/libpistache.so.0.4 /usr/lib/aarch64-linux-gnu/
ENTRYPOINT [ "/circuit-solver" ]

