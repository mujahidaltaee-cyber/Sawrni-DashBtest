#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: Flutter is not installed on this machine. Install Flutter + Android Studio first."
  exit 2
fi

API_BASE="${SAWRNI_API_BASE_URL:-http://10.0.2.2:8010/api/v1}"

echo "Using Sawrni API base URL: $API_BASE"
echo "Preparing Android scaffold if missing..."
flutter create --platforms=android . --project-name sawrni_mobile --org com.sawrni

echo "Getting packages..."
flutter pub get

if command -v python3 >/dev/null 2>&1; then
  python3 scripts/patch_android_manifest.py || true
elif command -v python >/dev/null 2>&1; then
  python scripts/patch_android_manifest.py || true
fi

echo "Building debug APK..."
flutter build apk --debug --dart-define=SAWRNI_API_BASE_URL="$API_BASE" --dart-define=SAWRNI_FLAVOR=debug

echo "DONE. APK path: build/app/outputs/flutter-apk/app-debug.apk"
