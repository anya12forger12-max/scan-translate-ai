# Troubleshooting

## Installation

- **`./install.sh` fails** — ensure prerequisites (Flutter/Node/Python/.NET) are
  installed and on PATH. Re-run after installing.
- **Permission denied** — `chmod +x install.sh`.
- **Network errors** — check connectivity/proxy; retry.

## Runtime

- **App won't start** — check logs; verify `.env`/config files are present
  (copy from `.env.example`).
- **Tests fail locally but pass in CI** — ensure dependency versions match
  (use the lockfile).

## Web / Vercel deployment

- The Vercel project uses `vercel.json` and `scripts/vercel-build.sh`. The
  script installs the pinned Flutter SDK (`3.47.3`, same as CI) when the build
  image does not provide one and emits the static site to `build/web`.
- Override the SDK version with the `FLUTTER_VERSION` environment variable if
  the project is migrated to a newer Flutter release.
- Run `flutter build web --release --base-href / --no-wasm-dry-run` locally to
  reproduce the deployment build.

## Getting help

Open an issue with reproduction steps, environment details, and logs.
