#!/usr/bin/env bash
# Vercel build entrypoint for the Flutter web target.
#
# Vercel does not ship a Flutter SDK, so install the same pinned version used
# by CI unless the build image already provides one. The SDK and pub packages
# are kept in the Vercel cache directory so repeat deployments stay fast.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.3}"
CACHE_ROOT="${VERCEL_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}}/scan-translate-ai"
FLUTTER_DIR="$CACHE_ROOT/flutter-$FLUTTER_VERSION"
export PUB_CACHE="$CACHE_ROOT/pub-cache"
mkdir -p "$PUB_CACHE"

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="$(command -v flutter)"
else
  if [ ! -x "$FLUTTER_DIR/bin/flutter" ] || [ ! -x "$FLUTTER_DIR/bin/cache/dart-sdk/bin/dart" ]; then
    echo "Installing Flutter $FLUTTER_VERSION into $FLUTTER_DIR"
    rm -rf "$FLUTTER_DIR"
    mkdir -p "$(dirname "$FLUTTER_DIR")"
    git clone --depth 1 --single-branch --branch "$FLUTTER_VERSION" \
      https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  fi
  FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"
fi

"$FLUTTER_BIN" config --no-analytics >/dev/null
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" build web --release --base-href / --no-wasm-dry-run
