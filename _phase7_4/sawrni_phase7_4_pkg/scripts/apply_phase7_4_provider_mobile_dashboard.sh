#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="$ROOT/mobile-flutter"
BACKEND_DIR="$ROOT/_sawrni_phase6/backend-runtime-laravel"

echo "Applying Sawrni Phase 7.4 Provider Mobile Dashboard..."

mkdir -p "$MOBILE_DIR/lib/features/provider"
mkdir -p "$MOBILE_DIR/lib/features/customer"
mkdir -p "$MOBILE_DIR/lib/core/network"
mkdir -p "$MOBILE_DIR/lib/core/session"

cp -R "$PHASE_DIR/mobile-flutter-template/lib/"* "$MOBILE_DIR/lib/"

if [ -f "$MOBILE_DIR/pubspec.yaml" ]; then
  if ! grep -q "Sawrni Phase 7.4" "$MOBILE_DIR/pubspec.yaml"; then
    cat "$PHASE_DIR/mobile-flutter-template/pubspec.phase7_4_additions.yaml" >> "$MOBILE_DIR/pubspec.yaml"
  fi
else
  cp "$PHASE_DIR/mobile-flutter-template/pubspec.yaml" "$MOBILE_DIR/pubspec.yaml"
fi

if [ -d "$BACKEND_DIR" ]; then
  echo "Laravel backend found. Installing Phase 7.4 mobile provider API routes."
  mkdir -p "$BACKEND_DIR/routes"
  mkdir -p "$BACKEND_DIR/database/migrations"

  cp "$PHASE_DIR/backend/routes/sawrni_phase7_4_provider_mobile.php" "$BACKEND_DIR/routes/sawrni_phase7_4_provider_mobile.php"
  cp "$PHASE_DIR/backend/database/migrations/2026_06_26_000074_create_sawrni_phase7_provider_dashboard_tables.php" "$BACKEND_DIR/database/migrations/2026_06_26_000074_create_sawrni_phase7_provider_dashboard_tables.php"

  if [ -f "$BACKEND_DIR/routes/api.php" ]; then
    if ! grep -q "sawrni_phase7_4_provider_mobile.php" "$BACKEND_DIR/routes/api.php"; then
      cat >> "$BACKEND_DIR/routes/api.php" <<'PHPREQ'

require __DIR__ . '/sawrni_phase7_4_provider_mobile.php';
PHPREQ
    fi
  else
    cat > "$BACKEND_DIR/routes/api.php" <<'PHPAPI'
<?php

use Illuminate\Support\Facades\Route;

Route::get('/v1/health', function () {
    return response()->json([
        'status' => 'ok',
        'app' => 'Sawrni',
        'phase' => 'phase-7-runtime',
        'backend' => 'laravel',
    ]);
});

require __DIR__ . '/sawrni_phase7_4_provider_mobile.php';
PHPAPI
  fi

  cd "$BACKEND_DIR"
  php artisan optimize:clear >/dev/null || true
  php artisan route:clear >/dev/null || true
  php artisan config:clear >/dev/null || true
  php artisan migrate --force || true
  cd "$ROOT"
else
  echo "Laravel backend folder not found at $BACKEND_DIR. Mobile source was still applied."
fi

mkdir -p "$ROOT/_verified_builds"
cp "$PHASE_DIR/docs/SAWRNI_PHASE_7_4_PROVIDER_DASHBOARD_NOTES.md" "$ROOT/_verified_builds/SAWRNI_PHASE_7_4_PROVIDER_DASHBOARD_NOTES.md"

echo "PASS: Phase 7.4 provider mobile dashboard source applied."
echo "Next production feature: Phase 7.5 customer booking status + provider acceptance sync."
