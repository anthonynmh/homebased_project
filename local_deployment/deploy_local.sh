#!/bin/bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Serve the build/web folder on localhost:8000
BUILD_DIR="$SCRIPT_DIR/../build/web"

if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: $BUILD_DIR not found. Please run the build script first."
    exit 1
fi

cd "$BUILD_DIR" || exit 1
python3 -m http.server 8000
