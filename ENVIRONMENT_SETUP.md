# Environment Setup (Local / Staging / Production)

This project supports three environments via `--dart-define=ENV=...`:

- `local` → loads `.env.local`
- `staging` → loads `.env.staging`
- `prod` → loads `.env.prod`

If no `ENV` is provided, the app falls back to `.env` (legacy) or `.env.local` via loader fallback.

## Files

- `.env.local` – developer machine or LAN instance
- `.env.staging` – staging server
- `.env.prod` – production server

## Run without building (Android device/emulator)

```powershell
# Local
flutter run --dart-define=ENV=local -d <deviceId>

# Staging
flutter run --flavor staging --dart-define=ENV=staging -d <deviceId>

# Production
flutter run --flavor production --dart-define=ENV=prod -d <deviceId>
```

## Build APKs (optional, not required to run)

```powershell
scripts\build_release.bat staging apk
scripts\build_release.bat prod apk
```

## Shorebird Android Bootstrap

Shorebird is used for Dart-only Android patches after the first Shorebird-enabled APK is installed on devices.

```powershell
# One-time local setup after installing the Shorebird CLI
shorebird init --display-name "Jarz POS"

# Create a Shorebird-enabled full release
scripts\shorebird_android.ps1 -Environment staging -Action release
scripts\shorebird_android.ps1 -Environment production -Action release

# Publish a Dart-only patch after the Shorebird-enabled APK is already installed
scripts\shorebird_android.ps1 -Environment staging -Action patch -Track staging
scripts\shorebird_android.ps1 -Environment production -Action patch -Track stable
```

Notes:

- `shorebird.yaml` must be committed after `shorebird init`.
- CI authentication now uses a Shorebird API key in `SHOREBIRD_TOKEN`; `shorebird login:ci` is deprecated.
- Patch-safe changes are Dart-only; native/plugin/permission/assets/env/versioning changes still require a full APK.
- On Windows, Shorebird may warn about Git long paths until `git config --system core.longpaths true` is set in an elevated shell.

Android APK builds now use product flavors so both apps can be installed on one device:

- `staging` → package `com.example.jarz_pos.staging`, launcher name `Jarz POS Staging`
- `production` → package `com.example.jarz_pos`, launcher name `Jarz POS`

Named APK copies are written to:

- `build/app/outputs/flutter-apk/jarz-pos-staging-release.apk`
- `build/app/outputs/flutter-apk/jarz-pos-production-release.apk`

## Flutter Web

```powershell
flutter config --enable-web

# Local web dev server using staging env
flutter run -d chrome --dart-define=ENV=staging

# Hardened release bundles (outputs to build/web)
scripts\build_release.bat staging web
scripts\build_release.bat prod web
```

Deploy `build/web` to any static host (Nginx, S3+CloudFront, GitHub Pages, etc.).

## Notes

- The loader is at `lib/src/core/env/env.dart` and selects the file based on `ENV`.
- Release builds should use `scripts/build_release.sh` or `scripts\build_release.bat` so both `ENV` and the matching `.env.*` file are passed together.
- WebSocket settings come from the chosen `.env.*` file; override `SOCKET_IO_URL` if your Socket.IO server is on a separate port/domain.
- Ensure ERPNext CORS allows your web origin for cookie-based sessions.
