#!/bin/bash

# Configuration
APP_NAME="Home Management App"
BINARY_NAME="homemanagement_app"
PACKAGE_NAME="homemanagement_app"
ICON_NAME="homemanagement-app"

# Determine base directory
# If this script is inside a folder with the application files
INSTALL_SOURCE_DIR=$(dirname "$(readlink -f "$0")")

# Target directories
INSTALL_DIR="$HOME/.local/bin/$PACKAGE_NAME"
ICON_DIR="$HOME/.local/share/icons/hicolor/1024x1024/apps"
DESKTOP_DIR="$HOME/.local/share/applications"

echo "Installing $APP_NAME for current user..."

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$ICON_DIR"
mkdir -p "$DESKTOP_DIR"

# Copy application files
echo "Copying application files to $INSTALL_DIR..."
cp -r "$INSTALL_SOURCE_DIR/"* "$INSTALL_DIR/"

# Copy icon
if [ -f "$INSTALL_SOURCE_DIR/icon.png" ]; then
    echo "Installing icon..."
    cp "$INSTALL_SOURCE_DIR/icon.png" "$ICON_DIR/$ICON_NAME.png"
    # Update icon cache (optional, but good practice)
    # gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
else
    echo "Warning: icon.png not found in $INSTALL_SOURCE_DIR"
fi

# Create desktop entry
echo "Creating desktop entry..."
CAT_PATH=$(which cat)
$CAT_PATH <<EOF > "$DESKTOP_DIR/$PACKAGE_NAME.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=Management application for home budgets and accounts
Exec="$INSTALL_DIR/$BINARY_NAME"
Icon=$ICON_NAME
Terminal=false
Categories=Office;Finance;
EOF

chmod +x "$DESKTOP_DIR/$PACKAGE_NAME.desktop"

echo "Installation complete!"
echo "You can now find $APP_NAME in your application menu."
