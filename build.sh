#!/bin/bash
set -e
cd "$(dirname "$0")"
BUILD_DIR="$(pwd)/build"
swift build -c release
mkdir -p "$BUILD_DIR"
cp .build/release/wintund "$BUILD_DIR"/
echo "Binary placed at $BUILD_DIR/wintund"
