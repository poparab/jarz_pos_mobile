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