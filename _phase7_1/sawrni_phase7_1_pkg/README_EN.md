# Sawrni Phase 7.1 — Flutter Mobile Foundation

This package moves Sawrni from web-preview into a real mobile-app foundation for iOS and Android using Flutter.

## Includes

- Laravel mobile API routes under `/api/v1/mobile/*`
- Secure hashed OTP storage
- Secure hashed mobile session tokens
- Mobile audit events
- Provider profile table support
- Customer home API
- Provider home API
- Provider profile submission API
- Flutter source app:
  - Role selection
  - Phone login
  - OTP verification
  - Customer home
  - Provider home
  - Provider profile submission

## Production rules covered

- Provider profile is hidden from customers until admin/COO approval.
- Customer-facing provider list only returns approved, non-suspended providers.
- Sensitive provider contact information is not returned to customer home.
- OTP is hashed in DB.
- Session token is hashed in DB.
- Development OTP is shown only outside production.

## Apply

```bash
cd /workspaces/Sawrni-DashBtest
unzip -o Sawrni_Phase_7_1_Flutter_Mobile_Foundation.zip -d _phase7_1
bash _phase7_1/sawrni_phase7_1_pkg/scripts/apply_phase7_1_flutter_mobile_foundation.sh
```

## Run Laravel

```bash
cd /workspaces/Sawrni-DashBtest/_sawrni_phase6/backend-runtime-laravel
php artisan serve --host=0.0.0.0 --port=8010
```

## Run Flutter

Flutter SDK is required.

```bash
cd /workspaces/Sawrni-DashBtest/mobile-flutter
flutter pub get
flutter run --dart-define=SAWRNI_API_BASE_URL=http://127.0.0.1:8010/api/v1/mobile
```
