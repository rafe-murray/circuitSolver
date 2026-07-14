#!/usr/bin/env bash
# Regenerates Dart protobuf classes from the canonical proto source at
# proto/circuit_solver/v1/circuit_graph_message.proto.
#
# Prerequisites:
#   - protoc installed (https://grpc.io/docs/protoc-installation/)
#   - Run `dart pub get` in this directory first, or have protoc-gen-dart
#     already activated via `dart pub global activate protoc_plugin`
#
# Usage (run from the circuit_solver_proto directory):
#   tool/generate_proto.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"
PROTO_DIR="$PACKAGE_DIR/../proto"
OUT_DIR="$PACKAGE_DIR/lib/src"

# Ensure the protoc-gen-dart plugin is on PATH via dart pub global
export PATH="$PATH:$HOME/.pub-cache/bin"

if ! command -v protoc-gen-dart &>/dev/null; then
	echo "protoc-gen-dart not found. Activating protoc_plugin..."
	dart pub global activate protoc_plugin
fi

echo "Generating Dart protobuf classes..."
protoc \
	--dart_out="$OUT_DIR" \
	--proto_path="$PROTO_DIR" \
	"$PROTO_DIR/circuit_solver/v1/circuit_graph_message.proto"

echo "Formatting generated files..."
dart format "$OUT_DIR"

echo "Done. Generated files in $OUT_DIR/circuit_solver/v1/"
