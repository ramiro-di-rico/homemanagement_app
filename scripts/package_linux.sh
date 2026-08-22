#!/bin/bash
set -e

# Base configuration
APP_TITLE="Home Management App"
APP_NAME="homemanagement_app"
BINARY_NAME="homemanagement_app"
ICON_NAME="homemanagement-app"

# Resolve repo root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Parse arguments
DO_INSTALL=false
SKIP_BUILD=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Builds the Linux release binary and creates a self-extracting single-file installer.

Options:
  -i, --install    Install the application immediately after building and packaging
  --no-build       Skip flutter build step (use existing build files)
  -h, --help       Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--install)
            DO_INSTALL=true
            shift
            ;;
        --no-build)
            SKIP_BUILD=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //' | tr -d ' ' | cut -d'+' -f1)
BUILD_DIR="build/linux/x64/release/bundle"
DIST_DIR="dist"
INSTALLER_NAME="${APP_NAME}-${VERSION}-linux-x64.sh"
TARBALL_NAME="${APP_NAME}-${VERSION}-linux-x64.tar.gz"

if [ "$SKIP_BUILD" = false ]; then
    echo "==> Building Flutter Linux application (release)..."
    flutter build linux --release
fi

if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory $BUILD_DIR not found. Run without --no-build to compile first." >&2
    exit 1
fi

echo "==> Packaging Linux distributable..."
mkdir -p "$DIST_DIR"

TEMP_STAGING=$(mktemp -d)
cleanup_staging() {
    rm -rf "$TEMP_STAGING"
}
trap cleanup_staging EXIT

# Prepare staging directory
mkdir -p "$TEMP_STAGING/bundle"
cp -r "$BUILD_DIR/"* "$TEMP_STAGING/bundle/"

ICON_SOURCE="assets/icon/app_icon.png"
if [ -f "$ICON_SOURCE" ]; then
    cp "$ICON_SOURCE" "$TEMP_STAGING/icon.png"
else
    echo "Warning: Icon source not found at $ICON_SOURCE"
fi

# Create tarball payload
PAYLOAD_TAR="$TEMP_STAGING/payload.tar.gz"
tar -czf "$PAYLOAD_TAR" -C "$TEMP_STAGING" bundle $([ -f "$TEMP_STAGING/icon.png" ] && echo "icon.png")

# Also copy standard tarball to dist for traditional archive distribution
cp "$PAYLOAD_TAR" "$DIST_DIR/$TARBALL_NAME"

# Build self-extracting installer script
INSTALLER_PATH="$DIST_DIR/$INSTALLER_NAME"
cat << 'EOF' > "$INSTALLER_PATH"
#!/bin/bash
set -e

APP_TITLE="Home Management App"
BINARY_NAME="homemanagement_app"
PACKAGE_NAME="homemanagement_app"
ICON_NAME="homemanagement-app"

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin/$PACKAGE_NAME}"
ICON_DIR="${ICON_DIR:-$HOME/.local/share/icons/hicolor/1024x1024/apps}"
DESKTOP_DIR="${DESKTOP_DIR:-$HOME/.local/share/applications}"

echo "Installing $APP_TITLE for current user..."

TEMP_EXTRACT=$(mktemp -d)
cleanup_extract() {
    rm -rf "$TEMP_EXTRACT"
}
trap cleanup_extract EXIT

ARCHIVE_LINE=$(grep -a -n '^__PAYLOAD_BELOW__$' "$0" | head -n1 | cut -d: -f1)
if [ -z "$ARCHIVE_LINE" ]; then
    echo "Error: Corrupted installer, payload marker not found." >&2
    exit 1
fi

tail -n +$((ARCHIVE_LINE + 1)) "$0" | tar -xz -C "$TEMP_EXTRACT"

mkdir -p "$INSTALL_DIR"
mkdir -p "$ICON_DIR"
mkdir -p "$DESKTOP_DIR"

echo "Copying application files to $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"/*
cp -r "$TEMP_EXTRACT/bundle/"* "$INSTALL_DIR/"

if [ -f "$TEMP_EXTRACT/icon.png" ]; then
    echo "Installing application icon..."
    cp "$TEMP_EXTRACT/icon.png" "$ICON_DIR/$ICON_NAME.png"
fi

echo "Creating desktop entry..."
cat << DESKTOP_ENTRY > "$DESKTOP_DIR/$PACKAGE_NAME.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_TITLE
Comment=Management application for home budgets and accounts
Exec="$INSTALL_DIR/$BINARY_NAME"
Icon=$ICON_NAME
Terminal=false
Categories=Office;Finance;
DESKTOP_ENTRY

chmod +x "$DESKTOP_DIR/$PACKAGE_NAME.desktop"

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi

echo "Installation complete!"
echo "You can launch $APP_TITLE from your application menu, or run:"
echo "  $INSTALL_DIR/$BINARY_NAME"

exit 0
__PAYLOAD_BELOW__
EOF

cat "$PAYLOAD_TAR" >> "$INSTALLER_PATH"
chmod +x "$INSTALLER_PATH"

echo "==> Distributable installer created successfully at:"
echo "    $INSTALLER_PATH"
echo "    $DIST_DIR/$TARBALL_NAME"

if [ "$DO_INSTALL" = true ]; then
    echo ""
    echo "==> Running installation..."
    "$INSTALLER_PATH"
fi
