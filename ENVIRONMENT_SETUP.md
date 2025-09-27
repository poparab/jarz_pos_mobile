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
flutter build apk --dart-define=ENV=staging -t lib/main.dart
flutter build apk --dart-define=ENV=prod -t lib/main.dart
```

If you later add Android product flavors, append `--flavor staging|prod` accordingly.

## Flutter Web

```powershell
flutter config --enable-web

# Local web dev server using staging env
flutter run -d chrome --dart-define=ENV=staging

# Production bundle (outputs to build/web)
flutter build web --release --dart-define=ENV=prod
```

Deploy `build/web` to any static host (Nginx, S3+CloudFront, GitHub Pages, etc.).

## Notes

- The loader is at `lib/src/core/env/env.dart` and selects the file based on `ENV`.
- WebSocket settings come from the chosen `.env.*` file; override `SOCKET_IO_URL` if your Socket.IO server is on a separate port/domain.
- Ensure ERPNext CORS allows your web origin for cookie-based sessions.
