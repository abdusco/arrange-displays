#!/bin/bash

# Build script for arrange_displays CLI
# Compiles Swift code without Xcode
#
# Usage: Set ARCH and VERSION env vars before running, e.g.:
#   ARCH=arm64 VERSION=1.2.3 ./build.sh

set -e  # Exit on error

# Default to arm64 if ARCH not specified
ARCH="${ARCH:-arm64}"

# Default VERSION: use git tag if available, otherwise use dev-$shortCommitHash
if [ -z "${VERSION:-}" ]; then
    TAG=$(git describe --tags --exact-match 2>/dev/null || echo "")
    COMMIT_SHORT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    if [ -n "$TAG" ]; then
        VERSION="$TAG-$COMMIT_SHORT"
    else
        VERSION="dev-$COMMIT_SHORT"
    fi
fi

OUTPUT_NAME="arrange_displays-${ARCH}"

# Remove 'v' prefix if present in version
VERSION_CLEAN=${VERSION#v}

echo "Building arrange_displays CLI for ${ARCH}, version: ${VERSION_CLEAN}..."

# Replace currentVersion in ArrangeDisplays.swift with the build version
sed "s/let currentVersion = \".*\"/let currentVersion = \"$VERSION_CLEAN\"/" ArrangeDisplays.swift > ArrangeDisplays.build.swift

# Compile the Swift file
swiftc ArrangeDisplays.build.swift \
    -o "$OUTPUT_NAME" \
    -target "${ARCH}-apple-macosx11.0" \
    -framework CoreGraphics \
    -framework Foundation

# Clean up temporary build file
rm ArrangeDisplays.build.swift

echo "✓ Build successful!"
echo "Executable created: ./${OUTPUT_NAME}"
echo ""
echo "Usage: ./${OUTPUT_NAME} {top|bottom|left|right}"
