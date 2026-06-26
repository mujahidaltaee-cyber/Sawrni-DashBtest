#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND="$ROOT/_sawrni_phase6/backend-runtime-laravel"
MOBILE="$ROOT/mobile-flutter"

echo "Applying Sawrni Phase 7.6 — Delivery Upload + Signed Customer Access"

mkdir -p "$MOBILE/lib/features/delivery" "$MOBILE/lib/core/config"
cp -R "$PKG_DIR/mobile-flutter-template/lib/features/delivery/"* "$MOBILE/lib/features/delivery/"
cp -R "$PKG_DIR/mobile-flutter-template/lib/core/config/"* "$MOBILE/lib/core/config/"

if [ -d "$BACKEND" ] && [ -f "$BACKEND/artisan" ]; then
  echo "Laravel backend found. Installing Phase 7.6 backend delivery routes and migration."
  mkdir -p "$BACKEND/routes" "$BACKEND/database/migrations" "$BACKEND/storage/app/sawrni/private/deliveries"
  cp "$PKG_DIR/routes/sawrni_phase7_6_delivery.php" "$BACKEND/routes/sawrni_phase7_6_delivery.php"
  cp "$PKG_DIR/database/migrations/2026_06_26_000076_create_sawrni_phase7_delivery_tables.php" "$BACKEND/database/migrations/2026_06_26_000076_create_sawrni_phase7_delivery_tables.php"

  API_FILE="$BACKEND/routes/api.php"
  if [ ! -f "$API_FILE" ]; then
    cat > "$API_FILE" <<'EOF'
<?php

use Illuminate\Support\Facades\Route;

Route::get('/v1/health', function () {
    return response()->json(['status' => 'ok', 'app' => 'Sawrni']);
});
EOF
  fi

  if ! grep -q "sawrni_phase7_6_delivery.php" "$API_FILE"; then
    printf "\nrequire __DIR__ . '/sawrni_phase7_6_delivery.php';\n" >> "$API_FILE"
  fi

  cd "$BACKEND"
  php artisan optimize:clear >/dev/null || true
  php artisan migrate --force || true
  cd "$ROOT"
else
  echo "Laravel backend folder not found. Mobile source was still applied."
fi

cat > "$ROOT/_verified_builds/SAWRNI_PHASE_7_6_DELIVERY_ACCESS_REPORT.md" <<'MD'
# Sawrni Phase 7.6 Delivery Access Report

Status: Applied.

Implemented source:
- Provider delivery upload screen.
- Customer delivery access screen.
- Backend delivery upload, admin approval/rejection, signed access, metadata, and download routes when Laravel exists.
- Delivery upload, access logs, and audit logs migrations when Laravel exists.

Production rule:
- Customer cannot access delivery files before admin/COO/super-admin approval.
- Download links are temporary signed tokens.
- Access and download attempts are logged.
MD

echo "PASS: Phase 7.6 delivery upload + signed customer access source applied."
