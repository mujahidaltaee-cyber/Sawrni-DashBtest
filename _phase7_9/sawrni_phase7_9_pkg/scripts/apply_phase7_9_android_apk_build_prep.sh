#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
MOBILE="$ROOT/mobile-flutter"
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILES="$PKG_DIR/mobile-build-files"

mkdir -p "$MOBILE" "$MOBILE/lib/core/config" "$MOBILE/scripts" "$MOBILE/assets/brand" "$ROOT/_verified_builds"

# Keep existing app source safe.
if [ -f "$MOBILE/pubspec.yaml" ]; then
  cp "$MOBILE/pubspec.yaml" "$MOBILE/pubspec.yaml.phase7_9_backup" || true
fi

# Copy build/config source files.
cp -R "$FILES/lib"/* "$MOBILE/lib/"
cp -R "$FILES/scripts"/* "$MOBILE/scripts/"
cp -R "$FILES/assets"/* "$MOBILE/assets/" 2>/dev/null || true
chmod +x "$MOBILE/scripts/"*.sh 2>/dev/null || true

# Bring brand assets from Next/web side if they exist.
if [ -d "$ROOT/public/brand" ]; then
  find "$ROOT/public/brand" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.svg' \) -exec cp {} "$MOBILE/assets/brand/" \;
fi

# Create pubspec.yaml only if no Flutter pubspec exists yet.
if [ ! -f "$MOBILE/pubspec.yaml" ]; then
  cat > "$MOBILE/pubspec.yaml" <<'YAML'
name: sawrni_mobile
description: Sawrni / صورني mobile application. استوديو كامل بجيبك
publish_to: 'none'
version: 0.7.9+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.4.1

flutter:
  uses-material-design: true
  assets:
    - assets/brand/

flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/brand/icon.png
  adaptive_icon_background: '#071326'
  adaptive_icon_foreground: assets/brand/icon.png

flutter_native_splash:
  color: '#071326'
  image: assets/brand/splash.png
  android: true
  ios: true
YAML
else
  cat > "$MOBILE/PUBSPEC_PHASE7_9_REQUIRED_PATCH.md" <<'PATCH'
# Sawrni Phase 7.9 required pubspec additions

Make sure `mobile-flutter/pubspec.yaml` contains these sections before building APK:

```yaml
dependencies:
  http: ^1.2.2

dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.4.1

flutter:
  uses-material-design: true
  assets:
    - assets/brand/

flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/brand/icon.png
  adaptive_icon_background: '#071326'
  adaptive_icon_foreground: assets/brand/icon.png

flutter_native_splash:
  color: '#071326'
  image: assets/brand/splash.png
  android: true
  ios: true
```

If `icon.png` or `splash.png` are not ready yet, keep the files as placeholders and replace them later with the final visual identity export.
PATCH
fi

cat > "$MOBILE/SAWRNI_PHASE_7_9_ANDROID_APK_BUILD.md" <<'EOF_MD'
# Sawrni Phase 7.9 — Android APK Build Preparation

Brand slogan:

**استوديو كامل بجيبك**

## What this phase prepares

- Android package/build workflow for the real Flutter app.
- Environment configuration using `--dart-define`.
- Debug APK build script.
- Android manifest patch helper for app permissions.
- Local Windows build instructions.
- Brand asset folder for icon/splash/logo.

## Important

Codespaces usually cannot run the Android emulator. Use Codespaces for source code, then build/test APK on:

- Windows PC with Flutter + Android Studio, or
- Mac with Flutter + Android Studio/Xcode, or
- a cloud CI build service later.

## Recommended Android package name

```text
com.sawrni.app
```

## API base URL

For production later:

```text
https://api.sawrni.com/api/v1
```

For local testing from Android phone, use your computer LAN IP, not `localhost`:

```text
http://192.168.x.x:8010/api/v1
```

For Android emulator:

```text
http://10.0.2.2:8010/api/v1
```

## Build on Windows

From the repo root:

```powershell
cd mobile-flutter
flutter create --platforms=android . --project-name sawrni_mobile --org com.sawrni
flutter pub get
python scripts/patch_android_manifest.py
flutter build apk --debug --dart-define=SAWRNI_API_BASE_URL="http://10.0.2.2:8010/api/v1"
```

APK output:

```text
mobile-flutter/build/app/outputs/flutter-apk/app-debug.apk
```

Install it on Android:

```powershell
flutter install
```

or copy the APK to the phone and install it manually.

## Build with script

Linux/Mac/Git Bash:

```bash
cd mobile-flutter
SAWRNI_API_BASE_URL="http://10.0.2.2:8010/api/v1" bash scripts/build_android_debug.sh
```

Windows PowerShell:

```powershell
cd mobile-flutter
$env:SAWRNI_API_BASE_URL="http://10.0.2.2:8010/api/v1"
.\scripts\build_android_debug.bat
```

## Brand files

Put final exported visual identity files here:

```text
mobile-flutter/assets/brand/
```

Recommended names:

```text
logo.png
icon.png
splash.png
wordmark.png
```
EOF_MD

cat > "$ROOT/_verified_builds/phase7_9_android_apk_build_prep.txt" <<EOF_STATUS
PASS: Phase 7.9 Android APK build preparation source applied.
Root: $ROOT
Mobile: $MOBILE
Slogan: استوديو كامل بجيبك
Next: build debug APK on a machine with Flutter + Android SDK.
EOF_STATUS

if command -v flutter >/dev/null 2>&1; then
  echo "Flutter detected. You can run: cd mobile-flutter && SAWRNI_API_BASE_URL=\"http://10.0.2.2:8010/api/v1\" bash scripts/build_android_debug.sh"
else
  echo "Flutter not installed in this Codespace. Android build prep files were still applied. Build the APK on Windows/Android Studio or a Flutter build environment."
fi

echo "PASS: Phase 7.9 Android APK build preparation source applied."
