#!/usr/bin/env bash
# ============================================================
#  Full Test Suite Runner — Jarz POS Mobile
#
#  Usage:
#    ./scripts/run_full_test_suite.sh
#
#  For integration tests, set env vars first:
#    export STAGING_USER=myuser
#    export STAGING_PASSWORD=mypassword
#    export STAGING_POS_PROFILE=MyProfile   (optional)
#
#  Options:
#    --skip-e2e      Skip integration tests
#    --skip-unit     Skip unit tests
#    --coverage      Generate lcov coverage report
# ============================================================
set -euo pipefail

cd "$(dirname "$0")/.."

# Load local test credentials from .env.test.local if present.
if [ -f .env.test.local ]; then
  while IFS='=' read -r key value || [ -n "$key" ]; do
    case "$key" in
      ''|\#*) continue ;;
    esac
    if [ -z "${!key:-}" ]; then
      export "$key=$value"
    fi
  done < .env.test.local
fi

SKIP_E2E=0
SKIP_UNIT=0
COVERAGE=0
EXIT_CODE=0

for arg in "$@"; do
  case "$arg" in
    --skip-e2e)  SKIP_E2E=1 ;;
    --skip-unit) SKIP_UNIT=1 ;;
    --coverage)  COVERAGE=1 ;;
  esac
done

echo "============================================================"
echo " Jarz POS Mobile — Full Test Suite"
echo "============================================================"
echo

# --------------------------------------------------
#  Step 1: Unit Tests
# --------------------------------------------------
if [ "$SKIP_UNIT" -eq 1 ]; then
  echo "[SKIP] Unit tests skipped via --skip-unit"
  echo
else
  echo "[1/3] Running unit tests..."
  echo
  if [ "$COVERAGE" -eq 1 ]; then
    flutter test --coverage || { echo; echo "[FAIL] Unit tests failed. Aborting."; exit 1; }
    echo
    echo "[1b] Coverage report generated at coverage/lcov.info"
    if command -v genhtml &>/dev/null && [ -f coverage/lcov.info ]; then
      genhtml coverage/lcov.info -o coverage/html --quiet
      echo "     HTML report: coverage/html/index.html"
    fi
  else
    flutter test || { echo; echo "[FAIL] Unit tests failed. Aborting."; exit 1; }
  fi
  echo
  echo "[PASS] Unit tests passed."
  echo
fi

# --------------------------------------------------
#  Step 2: Static Analysis
# --------------------------------------------------
echo "[2/3] Running flutter analyze..."
echo
flutter analyze || echo "[WARN] Analysis found issues. Continuing..."
echo

# --------------------------------------------------
#  Step 3: Integration / E2E Tests
# --------------------------------------------------
if [ "$SKIP_E2E" -eq 1 ]; then
  echo "[SKIP] Integration tests skipped via --skip-e2e"
  echo
elif [ -z "${STAGING_USER:-}" ]; then
  echo "[SKIP] Integration tests skipped — STAGING_USER not set."
  echo "       Set STAGING_USER and STAGING_PASSWORD env vars to run E2E tests."
  echo
elif [ -z "${STAGING_PASSWORD:-}" ]; then
  echo "[SKIP] Integration tests skipped — STAGING_PASSWORD not set."
  echo "       Set STAGING_USER and STAGING_PASSWORD env vars to run E2E tests."
  echo
else
  TEST_DEVICE_ARGS=()
  if [ -n "${STAGING_TEST_DEVICE:-}" ]; then
    TEST_DEVICE_ARGS=(-d "$STAGING_TEST_DEVICE")
    echo "[INFO] Using test device: $STAGING_TEST_DEVICE"
  fi

  TEST_DEFINE_ARGS=(
    --dart-define="STAGING_USER=$STAGING_USER"
    --dart-define="STAGING_PASSWORD=$STAGING_PASSWORD"
  )
  if [ -n "${STAGING_POS_PROFILE:-}" ]; then
    TEST_DEFINE_ARGS+=(--dart-define="STAGING_POS_PROFILE=$STAGING_POS_PROFILE")
  fi

  echo "[3/3] Running integration tests against staging..."
  echo

  echo "--- API Smoke Tests ---"
  flutter test integration_test/api_smoke_test.dart "${TEST_DEVICE_ARGS[@]}" "${TEST_DEFINE_ARGS[@]}" || { EXIT_CODE=1; echo "[FAIL] API smoke tests failed."; }

  if [ "$EXIT_CODE" -eq 0 ]; then
    echo "--- Auth Flow ---"
    flutter test integration_test/auth_flow_test.dart "${TEST_DEVICE_ARGS[@]}" "${TEST_DEFINE_ARGS[@]}" || { EXIT_CODE=1; echo "[FAIL] Auth flow tests failed."; }
  fi

  if [ "$EXIT_CODE" -eq 0 ]; then
    echo "--- Shift Flow ---"
    flutter test integration_test/shift_flow_test.dart "${TEST_DEVICE_ARGS[@]}" "${TEST_DEFINE_ARGS[@]}" || { EXIT_CODE=1; echo "[FAIL] Shift flow tests failed."; }
  fi

  if [ "$EXIT_CODE" -eq 0 ]; then
    echo "--- Full-Cycle E2E (POS + Kanban with backend verification) ---"
    flutter test integration_test/full_cycle/ "${TEST_DEVICE_ARGS[@]}" "${TEST_DEFINE_ARGS[@]}" || { EXIT_CODE=1; echo "[FAIL] Full-cycle E2E tests failed."; }
  fi

  if [ "$EXIT_CODE" -eq 0 ]; then
    echo
    echo "[PASS] All integration tests passed."
  fi
  echo
fi

echo "============================================================"
if [ "$EXIT_CODE" -eq 0 ]; then
  echo " RESULT: ALL TESTS PASSED"
else
  echo " RESULT: SOME TESTS FAILED"
fi
echo "============================================================"

exit "$EXIT_CODE"
