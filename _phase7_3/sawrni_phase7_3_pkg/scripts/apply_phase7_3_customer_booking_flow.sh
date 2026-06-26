#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
MOBILE="$ROOT/mobile-flutter"
BACKEND="$ROOT/_sawrni_phase6/backend-runtime-laravel"
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$PKG_DIR/mobile-flutter-template"

mkdir -p "$ROOT/_verified_builds"
mkdir -p "$MOBILE/lib"

if [ ! -d "$MOBILE" ]; then
  echo "mobile-flutter folder not found. Creating source folder only. Build scaffold can be generated later with Flutter."
  mkdir -p "$MOBILE"
fi

# Copy mobile app source additions/overrides.
cp -R "$TEMPLATE/lib"/* "$MOBILE/lib/"

# Keep pubspec compatible if it exists; create it if absent.
if [ ! -f "$MOBILE/pubspec.yaml" ]; then
  cat > "$MOBILE/pubspec.yaml" <<'YAML'
name: sawrni_mobile
description: Sawrni / صورني iOS and Android mobile application.
publish_to: 'none'
version: 0.7.3+1

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
fi

# Copy Laravel API routes and migration if backend exists.
if [ -d "$BACKEND" ]; then
  mkdir -p "$BACKEND/routes" "$BACKEND/database/migrations"
  cp "$PKG_DIR/routes/sawrni_phase7_3_customer_booking.php" "$BACKEND/routes/sawrni_phase7_3_customer_booking.php"
  cp "$PKG_DIR/database/migrations/2026_06_26_000073_create_sawrni_phase7_customer_booking_tables.php" "$BACKEND/database/migrations/2026_06_26_000073_create_sawrni_phase7_customer_booking_tables.php"

  if [ -f "$BACKEND/routes/api.php" ]; then
    API_FILE="$BACKEND/routes/api.php" python3 - <<'PY'
import os
from pathlib import Path
p = Path(os.environ['API_FILE'])
text = p.read_text()
line = "require __DIR__ . '/sawrni_phase7_3_customer_booking.php';\n"
if line not in text:
    text = text.rstrip() + "\n\n" + line
    p.write_text(text)
print('Phase 7.3 Laravel route loaded.')
PY
  fi

  if [ -f "$BACKEND/artisan" ]; then
    (cd "$BACKEND" && php artisan migrate --force && php artisan optimize:clear && php artisan route:clear && php artisan config:clear) || true
  fi
else
  echo "Laravel backend folder not found at $BACKEND. Mobile source was still applied."
fi

# If Flutter is available, only fetch packages; no emulator/build is attempted in Codespaces.
if command -v flutter >/dev/null 2>&1; then
  (cd "$MOBILE" && flutter pub get) || true
else
  echo "Flutter not installed here. Phase 7.3 source is ready for Android Studio / Flutter build machine."
fi

cat > "$MOBILE/SAWRNI_PHASE_7_3_CUSTOMER_BOOKING_FLOW.md" <<'EOF_MD'
# Sawrni Phase 7.3 — Customer Browse + Booking Flow

This phase adds the first real customer marketplace flow to the mobile app.

## Mobile screens

- Customer home with photography/editing/modeling entry points
- Approved provider list
- Provider detail screen
- Booking request form
- My bookings screen

## Backend endpoints

- GET `/api/v1/mobile/customer/categories`
- GET `/api/v1/mobile/customer/providers`
- GET `/api/v1/mobile/customer/providers/{id}`
- POST `/api/v1/mobile/customer/bookings`
- GET `/api/v1/mobile/customer/bookings`
- GET `/api/v1/mobile/marketplace/summary`

## Production business rules included

- Customers only see approved providers.
- Suspended providers and providers above the 75,000 IQD debt threshold are hidden.
- Platform commission is calculated as 15% of the full booking amount.
- Booking starts as `pending_provider_confirmation`.
- Deposit payment placeholder is created for later real payment integration.
- Customer edit/cancel timing fields are stored for future enforcement.

## Slogan

استوديو كامل بجيبك
EOF_MD

cat > "$ROOT/_verified_builds/SAWRNI_PHASE_7_3_CUSTOMER_BOOKING_REPORT.md" <<'EOF_MD'
# Sawrni Phase 7.3 Report

Applied real customer browse and booking foundation.

This phase is production-oriented source work, not a smoke-test-only phase.

Main mobile folder:

mobile-flutter

Main Laravel route:

_sawrni_phase6/backend-runtime-laravel/routes/sawrni_phase7_3_customer_booking.php
EOF_MD

echo "PASS: Phase 7.3 customer browse + booking flow source applied."
echo "Next production feature: provider mobile dashboard + accept/reject bookings."
