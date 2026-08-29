#!/usr/bin/env bash

cd -- "$(dirname ${BASH_SOURCE[0]})/.."
repo_root="$PWD"
dockerfile="${repo_root}/backend/Dockerfile"
build_context="${repo_root}"
docker_build_target="-f $dockerfile $build_context"

docker build $docker_build_target -t circuitsolver:latest
