#!/bin/bash
set -e
cd "$(dirname "$0")"
BUILD_DIR="$(pwd)/build"
swift build -c release
mkdir -p "$BUILD_DIR"
cp .build/release/wintund "$BUILD_DIR"/
cp config.ini "$BUILD_DIR"/
tar -czf "$BUILD_DIR/wintund.tar.gz" -C "$BUILD_DIR" wintund config.ini
echo "Artifact at $BUILD_DIR/wintund.tar.gz"
