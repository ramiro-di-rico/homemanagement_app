# Home Management App

A Flutter-based application for managing home budgets and accounts.

## Linux Support

This project provides scripts for building a self-contained Linux package and installing it for the current user.

### Building the Linux Package

To build a release version of the application and bundle it into a distributable tarball, run the `package_linux.sh` script:

```bash
./scripts/package_linux.sh
```

**What it does:**
- Builds the Flutter application in release mode.
- Bundles the binary, libraries, and assets into a temporary directory.
- Includes a high-resolution icon from the iOS assets.
- Includes an installation script (`install.sh`).
- Generates a compressed tarball in the `dist/` directory (e.g., `dist/homemanagement_app-1.0.10-linux-x64.tar.gz`).

### Installing the Application

To install the application for the current user (requires no root privileges), follow these steps:

1. Extract the generated tarball:
   ```bash
   tar -xzf dist/homemanagement_app-1.0.10-linux-x64.tar.gz -C /tmp
   ```
2. Run the installation script:
   ```bash
   cd /tmp/homemanagement_app
   ./install.sh
   ```

**What it does:**
- Copies the application files to `~/.local/bin/homemanagement_app`.
- Installs the application icon to `~/.local/share/icons`.
- Creates a `.desktop` launcher in `~/.local/share/applications/homemanagement_app.desktop`.

After installation, you can launch **Home Management App** from your application menu.