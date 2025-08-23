#!/bin/bash
set -e
BUILD_DIR="$(pwd)/build"
swift build -c release
mkdir -p "$BUILD_DIR"
cp .build/release/wintund "$BUILD_DIR"/
echo "Binary placed at $BUILD_DIR/wintund"
