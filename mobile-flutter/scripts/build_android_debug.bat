@echo off
setlocal
cd /d %~dp0\..

where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter is not installed on this machine. Install Flutter + Android Studio first.
  exit /b 2
)

if "%SAWRNI_API_BASE_URL%"=="" set SAWRNI_API_BASE_URL=http://10.0.2.2:8010/api/v1

echo Using Sawrni API base URL: %SAWRNI_API_BASE_URL%
echo Preparing Android scaffold if missing...
flutter create --platforms=android . --project-name sawrni_mobile --org com.sawrni

echo Getting packages...
flutter pub get

where python >nul 2>nul
if not errorlevel 1 python scripts\patch_android_manifest.py

echo Building debug APK...
flutter build apk --debug --dart-define=SAWRNI_API_BASE_URL=%SAWRNI_API_BASE_URL% --dart-define=SAWRNI_FLAVOR=debug

echo DONE. APK path: build\app\outputs\flutter-apk\app-debug.apk
endlocal
