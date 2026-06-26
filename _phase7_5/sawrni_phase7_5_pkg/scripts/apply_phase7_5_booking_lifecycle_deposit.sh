#!/usr/bin/env bash
set -euo pipefail

ROOT="${SAWRNI_ROOT:-$(pwd)}"
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Applying Sawrni Phase 7.5 Booking Lifecycle + Deposit Rules..."
echo "Root: $ROOT"

MOBILE_DIR="$ROOT/mobile-flutter"
mkdir -p "$MOBILE_DIR/lib" "$MOBILE_DIR/assets/brand"

if [ ! -f "$MOBILE_DIR/pubspec.yaml" ]; then
  cat > "$MOBILE_DIR/pubspec.yaml" <<'YAML'
name: sawrni_mobile
description: Sawrni mobile app
publish_to: "none"
version: 0.7.5+75

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/brand/
YAML
else
  if ! grep -q "http:" "$MOBILE_DIR/pubspec.yaml"; then
    python3 - "$MOBILE_DIR/pubspec.yaml" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
text = p.read_text()
if "dependencies:" in text and "http:" not in text:
    text = text.replace("dependencies:\n", "dependencies:\n  http: ^1.2.2\n", 1)
if "assets/brand/" not in text:
    if "flutter:" not in text:
        text += "\nflutter:\n  uses-material-design: true\n  assets:\n    - assets/brand/\n"
    elif "uses-material-design:" not in text:
        text += "\n  uses-material-design: true\n  assets:\n    - assets/brand/\n"
    else:
        text += "\n  assets:\n    - assets/brand/\n"
p.write_text(text)
PY
  fi
fi

# Preserve existing main before applying mobile source.
if [ -f "$MOBILE_DIR/lib/main.dart" ] && [ ! -f "$MOBILE_DIR/lib/main.phase7_4.backup.dart" ]; then
  cp "$MOBILE_DIR/lib/main.dart" "$MOBILE_DIR/lib/main.phase7_4.backup.dart"
fi

cp -R "$PKG_DIR/mobile-flutter-template/lib/." "$MOBILE_DIR/lib/"

# Backend integration if Laravel runtime exists.
BACKEND_DIR="$ROOT/_sawrni_phase6/backend-runtime-laravel"
if [ -d "$BACKEND_DIR" ]; then
  echo "Laravel backend found. Installing Phase 7.5 API routes..."
  mkdir -p "$BACKEND_DIR/routes" "$BACKEND_DIR/database/migrations"
  cp "$PKG_DIR/backend/routes/sawrni_phase7_5_booking_lifecycle.php" "$BACKEND_DIR/routes/"
  cp "$PKG_DIR/backend/database/migrations/2026_06_26_000075_create_sawrni_phase7_5_booking_lifecycle_tables.php" "$BACKEND_DIR/database/migrations/"

  API_FILE="$BACKEND_DIR/routes/api.php"
  if [ ! -f "$API_FILE" ]; then
    cat > "$API_FILE" <<'PHP'
<?php

use Illuminate\Support\Facades\Route;

Route::get('/v1/health', function () {
    return response()->json(['status' => 'ok', 'app' => 'Sawrni']);
});
PHP
  fi

  if ! grep -q "sawrni_phase7_5_booking_lifecycle.php" "$API_FILE"; then
    cat >> "$API_FILE" <<'PHP'

require __DIR__ . '/sawrni_phase7_5_booking_lifecycle.php';
PHP
  fi

  (cd "$BACKEND_DIR" && php artisan optimize:clear || true)
  (cd "$BACKEND_DIR" && php artisan migrate --force || true)
else
  echo "Laravel backend folder not found. Mobile source was still applied."
fi

mkdir -p "$ROOT/_verified_builds"
cp "$PKG_DIR/docs/SAWRNI_PHASE_7_5_BOOKING_LIFECYCLE.md" "$ROOT/_verified_builds/" 2>/dev/null || true

if command -v flutter >/dev/null 2>&1; then
  echo "Flutter found. Running dart format/analyze where possible..."
  (cd "$MOBILE_DIR" && dart format lib || true)
  (cd "$MOBILE_DIR" && flutter pub get || true)
  (cd "$MOBILE_DIR" && flutter analyze || true)
else
  echo "Flutter not installed in this environment. Source files are ready for Android Studio / Flutter build machine."
fi

echo "PASS: Phase 7.5 booking lifecycle + deposit rules source applied."
echo "Next production feature: Phase 7.6 delivery upload + signed customer access from mobile."
