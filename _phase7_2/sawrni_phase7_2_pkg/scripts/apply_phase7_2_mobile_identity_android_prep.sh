#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
MOBILE="$ROOT/mobile-flutter"
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$PKG_DIR/mobile-flutter-template"

mkdir -p "$MOBILE"
mkdir -p "$MOBILE/lib" "$MOBILE/assets/brand" "$ROOT/_verified_builds"

# Create Flutter scaffold if Flutter is installed and project does not exist.
if command -v flutter >/dev/null 2>&1; then
  if [ ! -f "$MOBILE/pubspec.yaml" ]; then
    echo "Flutter detected. Creating Flutter app scaffold..."
    (cd "$MOBILE" && flutter create . --project-name sawrni_mobile --org com.sawrni --platforms android,ios)
  fi
else
  echo "Flutter not installed in this environment. Source files will still be prepared."
fi

# Copy real app source.
cp -R "$TEMPLATE/lib"/* "$MOBILE/lib/"
cp -R "$TEMPLATE/assets"/* "$MOBILE/assets/"

# Copy any existing brand files from web public/brand into Flutter assets.
if [ -d "$ROOT/public/brand" ]; then
  find "$ROOT/public/brand" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.svg' \) -exec cp {} "$MOBILE/assets/brand/" \;
fi

# Create minimal pubspec if absent. If present, keep it and only append a clear note file.
if [ ! -f "$MOBILE/pubspec.yaml" ]; then
  cat > "$MOBILE/pubspec.yaml" <<'YAML'
name: sawrni_mobile
description: Sawrni / صورني iOS and Android mobile application.
publish_to: 'none'
version: 0.7.2+1

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

flutter:
  uses-material-design: true
  assets:
    - assets/brand/
YAML
else
  cp "$MOBILE/pubspec.yaml" "$MOBILE/pubspec.yaml.phase7_2_backup" || true
  if ! grep -q "http:" "$MOBILE/pubspec.yaml"; then
    cat >> "$MOBILE/PUBSPEC_PHASE7_2_REQUIRED_PATCH.md" <<'PATCH'
Add this dependency to pubspec.yaml under dependencies:

  http: ^1.2.2

Add this under flutter:

  assets:
    - assets/brand/
PATCH
  fi
fi

cat > "$MOBILE/SAWRNI_PHASE_7_2_ANDROID_BUILD.md" <<'EOF_MD'
# Sawrni Phase 7.2 — Mobile Visual Identity + Android Build Preparation

Brand slogan:

استوديو كامل بجيبك

## What this phase adds

- Sawrni Arabic-first mobile UI foundation
- Purple/gold/navy brand theme
- Splash screen with slogan
- Customer/provider role choice
- Phone login and OTP screens
- Customer home screen
- Provider home and provider profile submission screen
- API base URL build configuration
- Android/iOS-ready Flutter source structure

## Build APK on a machine with Flutter installed

```bash
cd mobile-flutter
flutter pub get
flutter run --dart-define=SAWRNI_API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1
```

For APK:

```bash
flutter build apk --release --dart-define=SAWRNI_API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1 --dart-define=SAWRNI_PRODUCTION=true
```

The APK will be in:

```text
mobile-flutter/build/app/outputs/flutter-apk/app-release.apk
```

## Important

Codespaces is useful for storing and editing this source code. Real Android/iOS testing should be done on Android Studio/physical Android phone, or Mac/Xcode for iOS.
EOF_MD

cat > "$ROOT/_verified_builds/SAWRNI_PHASE_7_2_MOBILE_IDENTITY_REPORT.md" <<EOF_MD
# Sawrni Phase 7.2 Report

Applied: mobile visual identity and Android build preparation.

Slogan locked:

استوديو كامل بجيبك

Main folder:

mobile-flutter

Source files created under:

mobile-flutter/lib

Brand assets folder:

mobile-flutter/assets/brand

EOF_MD

echo "PASS: Phase 7.2 mobile visual identity + Android build preparation applied."
echo "Next: build/run using Flutter on Android Studio or a machine with Flutter installed."
