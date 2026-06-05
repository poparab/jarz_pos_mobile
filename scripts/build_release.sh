#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

usage() {
  cat <<'EOF'
Usage: ./scripts/build_release.sh <staging|prod|production> <web|apk|all>

Examples:
  ./scripts/build_release.sh staging web
  ./scripts/build_release.sh prod apk
  ./scripts/build_release.sh production all
EOF
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

environment="$1"
target="$2"

case "${environment,,}" in
  staging)
    env_define="staging"
    env_file=".env.staging"
    flavor="staging"
    sentry_environment="staging"
    ;;
  prod|production)
    env_define="prod"
    env_file=".env.prod"
    flavor="production"
    sentry_environment="production"
    ;;
  *)
    echo "Unsupported environment: $environment" >&2
    usage
    exit 1
    ;;
esac

build_args=(
  --dart-define="ENV=$env_define"
  --dart-define="SENTRY_ENVIRONMENT=$sentry_environment"
  --dart-define-from-file="$env_file"
)

if [ -n "${SENTRY_RELEASE:-}" ]; then
  build_args+=(--dart-define="SENTRY_RELEASE=$SENTRY_RELEASE")
fi

if [ -n "${SENTRY_DIST:-}" ]; then
  build_args+=(--dart-define="SENTRY_DIST=$SENTRY_DIST")
fi

build_web() {
  echo "[build_release] Building web for $env_define using $env_file"
  flutter build web --release \
    "${build_args[@]}" \
    --base-href /pos/

  dart --disable-dart-dev tool/write_web_push_config.dart \
    --env-file "$env_file" \
    --output-file build/web/firebase-web-config.js

  # Bundle Firebase compat scripts locally so firebase-messaging-sw.js has no
  # CDN dependency at service worker activation time (required for iOS PWA).
  local firebase_version="10.12.5"
  local firebase_cdn="https://www.gstatic.com/firebasejs/${firebase_version}"
  echo "[build_release] Bundling Firebase compat scripts (v${firebase_version}) locally..."
  curl -sSfL "${firebase_cdn}/firebase-app-compat.js" \
    -o build/web/firebase-app-compat.js
  curl -sSfL "${firebase_cdn}/firebase-messaging-compat.js" \
    -o build/web/firebase-messaging-compat.js
  echo "[build_release] Firebase scripts bundled."
}

build_apk() {
  echo "[build_release] Building APK for $env_define using $env_file"
  flutter build apk --release \
    --flavor "$flavor" \
    "${build_args[@]}"

  local built_apk="build/app/outputs/flutter-apk/app-$flavor-release.apk"
  local named_apk="build/app/outputs/flutter-apk/jarz-pos-$flavor-release.apk"
  if [ -f "$built_apk" ]; then
    cp "$built_apk" "$named_apk"
    echo "[build_release] Named APK copied to $named_apk"
  fi
}

case "${target,,}" in
  web)
    build_web
    ;;
  apk)
    build_apk
    ;;
  all)
    build_web
    build_apk
    ;;
  *)
    echo "Unsupported target: $target" >&2
    usage
    exit 1
    ;;
esac