#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "error: macOS required" >&2
  exit 2
fi
BUILD_DIR="$(pwd)/build"
swift build -c release
mkdir -p "$BUILD_DIR"
cp .build/release/wintund "$BUILD_DIR"/
cp config.ini "$BUILD_DIR"/
tar -czf "$BUILD_DIR/wintund.tar.gz" -C "$BUILD_DIR" wintund config.ini
echo "Artifact at $BUILD_DIR/wintund.tar.gz"
