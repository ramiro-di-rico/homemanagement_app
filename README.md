# Home Management App

A Flutter-based application for managing home budgets and accounts.

## Run in Browser (Web)

Web support is enabled for this repository. On Linux, Flutter usually expects
`google-chrome`, but this setup can also work with Chromium.

Use the helper script:

```bash
./scripts/run_web.sh
```

The script auto-detects a local Chrome/Chromium binary and runs:

```bash
flutter run -d chrome
```

You can still set a custom browser explicitly:

```bash
CHROME_EXECUTABLE=/path/to/chrome ./scripts/run_web.sh
```

## Linux Support

This project provides a single script (`scripts/package_linux.sh`) for building a self-extracting Linux distributable package and optionally installing it for the current user.

### Building the Linux Distributable

To build a release version of the application and create a self-extracting installer script in `dist/`, run:

```bash
./scripts/package_linux.sh
```

**What it does:**
- Builds the Flutter application in release mode.
- Bundles the binary, libraries, and application icon.
- Generates a standalone, self-extracting single-file installer in `dist/` (e.g., `dist/homemanagement_app-1.0.10-linux-x64.sh`) as well as a compressed tarball (`.tar.gz`).

### Installing the Application

#### Option 1: Build and Install in One Step
From the repository root:

```bash
./scripts/package_linux.sh --install
```

#### Option 2: Run the Distributable Installer File
Execute the generated standalone installer script:

```bash
./dist/homemanagement_app-1.0.10-linux-x64.sh
```

**What installation does:**
- Copies the application files to `~/.local/bin/homemanagement_app`.
- Installs the application icon to `~/.local/share/icons/hicolor/1024x1024/apps`.
- Creates a `.desktop` launcher in `~/.local/share/applications/homemanagement_app.desktop`.

After installation, you can launch **Home Management App** from your application menu or directly run `~/.local/bin/homemanagement_app/homemanagement_app`.
