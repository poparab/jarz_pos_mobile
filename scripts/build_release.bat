@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0.."

if "%~1"=="" goto :usage
if "%~2"=="" goto :usage

set "ENV_INPUT=%~1"
set "TARGET=%~2"

if /I "%ENV_INPUT%"=="staging" (
  set "ENV_DEFINE=staging"
  set "ENV_FILE=.env.staging"
  set "FLAVOR=staging"
) else if /I "%ENV_INPUT%"=="prod" (
  set "ENV_DEFINE=prod"
  set "ENV_FILE=.env.prod"
  set "FLAVOR=production"
) else if /I "%ENV_INPUT%"=="production" (
  set "ENV_DEFINE=prod"
  set "ENV_FILE=.env.prod"
  set "FLAVOR=production"
) else (
  echo Unsupported environment: %ENV_INPUT%
  goto :usage_fail
)

if /I "%TARGET%"=="web" goto :build_web
if /I "%TARGET%"=="apk" goto :build_apk
if /I "%TARGET%"=="all" goto :build_all

echo Unsupported target: %TARGET%
goto :usage_fail

:build_web
echo [build_release] Building web for %ENV_DEFINE% using %ENV_FILE%
call flutter build web --release --dart-define=ENV=%ENV_DEFINE% --dart-define-from-file=%ENV_FILE% --base-href /pos/
goto :eof

:build_apk
echo [build_release] Building APK for %ENV_DEFINE% using %ENV_FILE%
call flutter build apk --release --flavor %FLAVOR% --dart-define=ENV=%ENV_DEFINE% --dart-define-from-file=%ENV_FILE%
if exist "build\app\outputs\flutter-apk\app-%FLAVOR%-release.apk" (
  copy /Y "build\app\outputs\flutter-apk\app-%FLAVOR%-release.apk" "build\app\outputs\flutter-apk\jarz-pos-%FLAVOR%-release.apk" >nul
  echo [build_release] Named APK copied to build\app\outputs\flutter-apk\jarz-pos-%FLAVOR%-release.apk
)
goto :eof

:build_all
call :build_web || exit /b 1
call :build_apk || exit /b 1
goto :eof

:usage
echo Usage: scripts\build_release.bat ^<staging^|prod^|production^> ^<web^|apk^|all^>
echo.
echo Examples:
echo   scripts\build_release.bat staging web
echo   scripts\build_release.bat prod apk
echo   scripts\build_release.bat production all
exit /b 1

:usage_fail
call :usage