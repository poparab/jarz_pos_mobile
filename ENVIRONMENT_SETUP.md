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
flutter run --dart-define=ENV=staging -d <deviceId>

# Production
flutter run --dart-define=ENV=prod -d <deviceId>
```

## Build APKs (optional, not required to run)

```powershell
scripts\build_release.bat staging apk
scripts\build_release.bat prod apk
```

If you later add Android product flavors, append `--flavor staging|prod` accordingly.

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
