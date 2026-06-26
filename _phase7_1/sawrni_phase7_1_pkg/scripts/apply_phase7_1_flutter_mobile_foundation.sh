#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/workspaces/Sawrni-DashBtest}"
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND="$ROOT/_sawrni_phase6/backend-runtime-laravel"
MOBILE="$ROOT/mobile-flutter"

echo "Applying Sawrni Phase 7.1 Flutter mobile foundation..."
echo "ROOT=$ROOT"

if [ ! -d "$ROOT" ]; then
  echo "ERROR: Project root not found: $ROOT"
  exit 1
fi

if [ ! -f "$BACKEND/artisan" ]; then
  echo "ERROR: Laravel backend not found at $BACKEND"
  echo "Create/restore _sawrni_phase6/backend-runtime-laravel first, then rerun."
  exit 1
fi

mkdir -p "$BACKEND/routes" "$BACKEND/database/migrations"
cp "$PKG_DIR/backend/routes/sawrni_phase7_1_mobile_api.php" "$BACKEND/routes/sawrni_phase7_1_mobile_api.php"
cp "$PKG_DIR/backend/database/migrations/2026_06_26_000071_create_sawrni_phase7_mobile_tables.php" "$BACKEND/database/migrations/2026_06_26_000071_create_sawrni_phase7_mobile_tables.php"

python3 - <<PY
from pathlib import Path
p = Path('$BACKEND/routes/api.php')
p.parent.mkdir(parents=True, exist_ok=True)
if not p.exists():
    p.write_text('<?php\n\n')
text = p.read_text()
line = "require __DIR__ . '/sawrni_phase7_1_mobile_api.php';\n"
if line not in text:
    if text.startswith('<?php'):
        text = text.replace('<?php', '<?php\n\n' + line, 1)
    else:
        text = '<?php\n\n' + line + text
p.write_text(text)
print('Laravel mobile API route loaded.')
PY

(
  cd "$BACKEND"
  php artisan migrate --force
  php artisan optimize:clear
  php artisan route:clear
  php artisan config:clear
)

if command -v flutter >/dev/null 2>&1; then
  if [ ! -f "$MOBILE/pubspec.yaml" ]; then
    echo "Creating Flutter project at $MOBILE"
    (cd "$ROOT" && flutter create --org com.sawrni.app --project-name sawrni mobile-flutter)
  fi
else
  echo "Flutter CLI not found in this Codespace. Creating source tree only."
  echo "Install Flutter later, then run: flutter create --org com.sawrni.app --project-name sawrni mobile-flutter"
  mkdir -p "$MOBILE"
fi

mkdir -p "$MOBILE/lib"
cp "$PKG_DIR/mobile-flutter/pubspec.yaml" "$MOBILE/pubspec.yaml"
cp -R "$PKG_DIR/mobile-flutter/lib/." "$MOBILE/lib/"

cat > "$MOBILE/README.md" <<'EOF'
# Sawrni Flutter Mobile App — Phase 7.1

This is the real iOS/Android app foundation for Sawrni.

Run locally after Flutter is installed:

```bash
cd mobile-flutter
flutter pub get
flutter run --dart-define=SAWRNI_API_BASE_URL=http://127.0.0.1:8010/api/v1/mobile
```

For Codespaces or a public backend, replace the API URL with your public Laravel URL ending in `/api/v1/mobile`.

Development OTP in non-production Laravel is `123456`.
Production must connect a real SMS provider and must not expose OTP in responses.
EOF

echo "Phase 7.1 applied. Backend API + Flutter source foundation installed."
echo "Next: start Laravel on 8010, then run Flutter where Flutter SDK exists."
