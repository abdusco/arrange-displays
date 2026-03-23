#!/bin/bash

# Build script for arrange_displays CLI
# Compiles Swift code without Xcode

set -e  # Exit on error

echo "Building arrange_displays CLI..."

# Compile the Swift file
swiftc ArrangeDisplays.swift \
    -o arrange_displays \
    -framework CoreGraphics \
    -framework Foundation

echo "✓ Build successful!"
echo "Executable created: ./arrange_displays"
echo ""
echo "Usage: ./arrange_displays {top|bottom|left|right}"
