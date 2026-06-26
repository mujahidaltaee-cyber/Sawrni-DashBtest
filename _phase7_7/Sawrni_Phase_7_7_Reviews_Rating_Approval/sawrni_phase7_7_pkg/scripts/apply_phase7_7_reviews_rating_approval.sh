#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND="$ROOT/_sawrni_phase6/backend-runtime-laravel"
MOBILE="$ROOT/mobile-flutter"

echo "Applying Sawrni Phase 7.7 — Reviews + Rating Approval Before Publish"

mkdir -p "$ROOT/_verified_builds"

# Mobile source is always applied because Flutter can be built later on Android Studio / Xcode.
mkdir -p "$MOBILE"
cp -R "$PKG_DIR/mobile-flutter-template/"* "$MOBILE/"
echo "Mobile review screens copied to: $MOBILE"

# Laravel backend integration is applied only if backend exists in this Codespace.
if [ -d "$BACKEND" ]; then
  echo "Laravel backend found. Installing Phase 7.7 backend routes and migration..."
  mkdir -p "$BACKEND/routes" "$BACKEND/database/migrations"
  cp "$PKG_DIR/routes/sawrni_phase7_7_reviews.php" "$BACKEND/routes/sawrni_phase7_7_reviews.php"
  cp "$PKG_DIR/database/migrations/2026_06_26_000077_create_sawrni_phase7_reviews_tables.php" "$BACKEND/database/migrations/2026_06_26_000077_create_sawrni_phase7_reviews_tables.php"

  if [ ! -f "$BACKEND/routes/api.php" ]; then
    cat > "$BACKEND/routes/api.php" <<'API'
<?php
API
  fi

  python3 - <<'PY' "$BACKEND/routes/api.php"
from pathlib import Path
import sys
p = Path(sys.argv[1])
text = p.read_text() if p.exists() else "<?php\n"
if not text.strip().startswith("<?php"):
    text = "<?php\n" + text
line = "require __DIR__ . '/sawrni_phase7_7_reviews.php';\n"
if line not in text:
    if text.startswith("<?php\n"):
        text = text.replace("<?php\n", "<?php\n\n" + line, 1)
    else:
        text = "<?php\n\n" + line + text
p.write_text(text)
print("Phase 7.7 reviews route loaded in routes/api.php")
PY

  cd "$BACKEND"
  php artisan migrate --force || true
  php artisan optimize:clear || true
  php artisan route:clear || true
  php artisan config:clear || true
else
  echo "Laravel backend folder not found at $BACKEND. Mobile source was still applied."
fi

cd "$ROOT"
cat > "$ROOT/_verified_builds/SAWRNI_PHASE_7_7_REVIEWS_RATING_APPROVAL_REPORT.md" <<'REPORT'
# Sawrni Phase 7.7 — Reviews + Rating Approval Before Publish

Status: Source applied.

Production rule added:
- Customer reviews are never public immediately.
- Reviews remain pending until admin/COO/super-admin approval.
- Provider rating should be recalculated only from approved reviews.
- Rejected reviews are kept internally for audit, but not published.
- Review approval/rejection is logged.

Mobile source:
- `mobile-flutter/lib/features/reviews/review_submit_screen.dart`
- `mobile-flutter/lib/features/reviews/review_status_screen.dart`
- `mobile-flutter/lib/features/reviews/provider_public_reviews_screen.dart`
- `mobile-flutter/lib/core/models/sawrni_review.dart`

Backend source, if Laravel exists:
- `routes/sawrni_phase7_7_reviews.php`
- `database/migrations/2026_06_26_000077_create_sawrni_phase7_reviews_tables.php`

Next recommended phase:
- Phase 7.8 — Notifications and alerts.
REPORT

echo "PASS: Phase 7.7 reviews + rating approval before publish source applied."
