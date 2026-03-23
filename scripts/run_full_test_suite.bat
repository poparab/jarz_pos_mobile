@echo off
REM ============================================================
REM  Full Test Suite Runner — Jarz POS Mobile
REM
REM  Usage:
REM    scripts\run_full_test_suite.bat
REM
REM  For integration tests, set env vars first:
REM    set STAGING_USER=myuser
REM    set STAGING_PASSWORD=mypassword
REM    set STAGING_POS_PROFILE=MyProfile   (optional)
REM
REM  Options (pass as arguments):
REM    --skip-e2e      Skip integration tests
REM    --skip-unit     Skip unit tests
REM    --coverage      Generate lcov coverage report
REM ============================================================
setlocal enabledelayedexpansion

cd /d "%~dp0\.."

REM Load local test credentials from .env.test.local if present
if exist ".env.test.local" (
    for /f "usebackq tokens=1,* delims==" %%A in (".env.test.local") do (
        if not "%%A"=="" (
            if not "%%A:~0,1"=="#" (
                if not defined %%A set "%%A=%%B"
            )
        )
    )
)

set SKIP_E2E=0
set SKIP_UNIT=0
set COVERAGE=0
set EXIT_CODE=0

REM Parse arguments
for %%a in (%*) do (
    if "%%a"=="--skip-e2e" set SKIP_E2E=1
    if "%%a"=="--skip-unit" set SKIP_UNIT=1
    if "%%a"=="--coverage" set COVERAGE=1
)

echo ============================================================
echo  Jarz POS Mobile — Full Test Suite
echo ============================================================
echo.

REM --------------------------------------------------
REM  Step 1: Unit Tests
REM --------------------------------------------------
if %SKIP_UNIT%==1 (
    echo [SKIP] Unit tests skipped via --skip-unit
    echo.
) else (
    echo [1/3] Running unit tests...
    echo.
    if %COVERAGE%==1 (
        call flutter test --coverage
    ) else (
        call flutter test
    )
    if errorlevel 1 (
        echo.
        echo [FAIL] Unit tests failed. Aborting.
        set EXIT_CODE=1
        goto :report
    )
    echo.
    echo [PASS] Unit tests passed.
    echo.

    if %COVERAGE%==1 (
        echo [1b] Coverage report generated at coverage\lcov.info
        if exist coverage\lcov.info (
            echo      To view: genhtml coverage\lcov.info -o coverage\html
            echo      Then open coverage\html\index.html
        )
        echo.
    )
)

REM --------------------------------------------------
REM  Step 2: Static Analysis
REM --------------------------------------------------
echo [2/3] Running flutter analyze...
echo.
call flutter analyze
if errorlevel 1 (
    echo.
    echo [WARN] Analysis found issues. Continuing...
    echo.
) else (
    echo.
    echo [PASS] Analysis clean.
    echo.
)

REM --------------------------------------------------
REM  Step 3: Integration / E2E Tests
REM --------------------------------------------------
if %SKIP_E2E%==1 (
    echo [SKIP] Integration tests skipped via --skip-e2e
    echo.
    goto :report
)

if "%STAGING_USER%"=="" (
    echo [SKIP] Integration tests skipped — STAGING_USER not set.
    echo        Set STAGING_USER and STAGING_PASSWORD env vars to run E2E tests.
    echo.
    goto :report
)

if "%STAGING_PASSWORD%"=="" (
    echo [SKIP] Integration tests skipped — STAGING_PASSWORD not set.
    echo        Set STAGING_USER and STAGING_PASSWORD env vars to run E2E tests.
    echo.
    goto :report
)

set TEST_DEVICE_ARG=
if not "%STAGING_TEST_DEVICE%"=="" (
    set "TEST_DEVICE_ARG=-d %STAGING_TEST_DEVICE%"
    echo [INFO] Using test device: %STAGING_TEST_DEVICE%
)

set TEST_DEFINE_ARGS=--dart-define=STAGING_USER=%STAGING_USER% --dart-define=STAGING_PASSWORD=%STAGING_PASSWORD%
if not "%STAGING_POS_PROFILE%"=="" (
    set TEST_DEFINE_ARGS=%TEST_DEFINE_ARGS% --dart-define=STAGING_POS_PROFILE=%STAGING_POS_PROFILE%
)

echo [3/3] Running integration tests against staging...
echo.

REM Run individual flow tests first (faster, catch regressions early)
echo --- API Smoke Tests ---
call flutter test integration_test\api_smoke_test.dart %TEST_DEVICE_ARG% %TEST_DEFINE_ARGS%
if errorlevel 1 (
    echo [FAIL] API smoke tests failed.
    set EXIT_CODE=1
    goto :report
)

echo --- Auth Flow ---
call flutter test integration_test\auth_flow_test.dart %TEST_DEVICE_ARG% %TEST_DEFINE_ARGS%
if errorlevel 1 (
    echo [FAIL] Auth flow tests failed.
    set EXIT_CODE=1
    goto :report
)

echo --- Shift Flow ---
call flutter test integration_test\shift_flow_test.dart %TEST_DEVICE_ARG% %TEST_DEFINE_ARGS%
if errorlevel 1 (
    echo [FAIL] Shift flow tests failed.
    set EXIT_CODE=1
    goto :report
)

echo --- Full-Cycle E2E (POS + Kanban with backend verification) ---
call flutter test integration_test\full_cycle\ %TEST_DEVICE_ARG% %TEST_DEFINE_ARGS%
if errorlevel 1 (
    echo [FAIL] Full-cycle E2E tests failed.
    set EXIT_CODE=1
    goto :report
)

echo.
echo [PASS] All integration tests passed.
echo.

:report
echo ============================================================
if %EXIT_CODE%==0 (
    echo  RESULT: ALL TESTS PASSED
) else (
    echo  RESULT: SOME TESTS FAILED
)
echo ============================================================

exit /b %EXIT_CODE%
