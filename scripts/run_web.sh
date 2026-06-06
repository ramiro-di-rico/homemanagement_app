#!/usr/bin/env bash
set -euo pipefail

# Reuse an explicit browser path when already configured.
if [[ -z "${CHROME_EXECUTABLE:-}" ]]; then
  candidates=(
    "/snap/bin/chromium"
    "$(command -v google-chrome || true)"
    "$(command -v chromium-browser || true)"
    "$(command -v chromium || true)"
  )

  for candidate in "${candidates[@]}"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      export CHROME_EXECUTABLE="$candidate"
      break
    fi
  done
fi

if [[ -z "${CHROME_EXECUTABLE:-}" ]]; then
  echo "No Chrome/Chromium executable found."
  echo "Install Chrome/Chromium or set CHROME_EXECUTABLE manually."
  exit 1
fi

exec flutter run -d chrome "$@"

