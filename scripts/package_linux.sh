#!/bin/bash

# Configuration
APP_NAME="homemanagement_app"
BINARY_NAME="homemanagement_app"
VERSION=$(grep 'version: ' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)
BUILD_DIR="build/linux/x64/release/bundle"
DIST_DIR="dist"
TARBALL_NAME="${APP_NAME}-${VERSION}-linux-x64.tar.gz"

echo "Building Flutter Linux application..."
flutter build linux --release

if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory $BUILD_DIR not found."
    exit 1
fi

echo "Preparing distribution..."
mkdir -p "$DIST_DIR"

# Create a temporary directory for the tarball structure
TEMP_DIST="temp_dist"
rm -rf "$TEMP_DIST"
mkdir -p "$TEMP_DIST/$APP_NAME"

# Copy build bundle to temp dist
cp -r "$BUILD_DIR/"* "$TEMP_DIST/$APP_NAME/"

# Copy icon
ICON_SOURCE="ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"
if [ -f "$ICON_SOURCE" ]; then
    cp "$ICON_SOURCE" "$TEMP_DIST/$APP_NAME/icon.png"
else
    echo "Warning: Icon source not found at $ICON_SOURCE"
fi

# Copy install script
cp "scripts/install_linux.sh" "$TEMP_DIST/$APP_NAME/install.sh"
chmod +x "$TEMP_DIST/$APP_NAME/install.sh"

# Create the tarball
echo "Creating tarball $TARBALL_NAME..."
tar -czf "$DIST_DIR/$TARBALL_NAME" -C "$TEMP_DIST" "$APP_NAME"

# Clean up
rm -rf "$TEMP_DIST"

echo "Build and packaging complete! Tarball is at $DIST_DIR/$TARBALL_NAME"
