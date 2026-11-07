#!/usr/bin/env bash
#
# Vercel build entry point for the Radhika Flutter web app.
#
# Vercel's build image does not ship the Flutter SDK, so this script
# provisions the exact SDK version pinned by the local toolchain
# (see `flutter --version` / .metadata) and then produces the static
# web bundle in build/web, which vercel.json publishes as the output
# directory.
#
# The Flutter SDK is cached between builds under $HOME so repeat
# deployments skip the ~700 MB download.
set -euo pipefail

FLUTTER_VERSION="3.47.5"
FLUTTER_HOME="${HOME}/flutter-sdk"
ARCHIVE="/tmp/flutter_${FLUTTER_VERSION}.tar.xz"
DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
    echo "==> Provisioning Flutter ${FLUTTER_VERSION}"
    curl -fsSL --retry 3 --retry-delay 5 -o "${ARCHIVE}" "${DOWNLOAD_URL}"
    mkdir -p "${FLUTTER_HOME}"
    tar -xJf "${ARCHIVE}" -C "${FLUTTER_HOME}" --strip-components=1
    rm -f "${ARCHIVE}"
  fi
  export PATH="${FLUTTER_HOME}/bin:${PATH}"
fi

# The Flutter SDK is a git checkout; Vercel runs builds as a different
# user than the one that extracted it, so mark it as safe.
git config --global --add safe.directory "${FLUTTER_HOME}" 2>/dev/null || true

echo "==> Toolchain"
flutter --version
dart --version

echo "==> Resolving dependencies"
flutter pub get

echo "==> Building release web bundle"
# Web Firebase credentials are optional. When the Vercel project has them
# configured they are compiled into the bundle; otherwise the app boots
# signed-out and the login screen explains that web sign-in is not
# configured yet.
DEFINES=()
for name in FIREBASE_API_KEY FIREBASE_APP_ID FIREBASE_MESSAGING_SENDER_ID \
            FIREBASE_PROJECT_ID FIREBASE_AUTH_DOMAIN FIREBASE_STORAGE_BUCKET \
            GOOGLE_WEB_CLIENT_ID; do
  value="${!name:-}"
  if [ -n "${value}" ]; then
    DEFINES+=("--dart-define=${name}=${value}")
    echo "    ${name}: set"
  else
    echo "    ${name}: not set"
  fi
done

flutter build web \
  --release \
  --no-wasm-dry-run \
  --source-maps \
  "${DEFINES[@]}"

echo "==> Build complete: build/web"
du -sh build/web
